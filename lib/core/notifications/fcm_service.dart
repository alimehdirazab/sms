// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import '../storage/session_storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  log('FCM Background message: ${message.messageId}', name: 'FCM');
}

class FcmService {
  static String? _currentToken;
  static bool _initialized = false;
  static final List<void Function(String)> _tokenListeners = [];
  static Timer? _retryTimer;
  static int _retryAttempts = 0;

  /// Register a listener that fires whenever a valid FCM token is retrieved or refreshed.
  static void addTokenListener(void Function(String) listener) {
    _tokenListeners.add(listener);
    if (_currentToken != null && _currentToken!.isNotEmpty) {
      listener(_currentToken!);
    }
  }

  /// Remove a token listener
  static void removeTokenListener(void Function(String) listener) {
    _tokenListeners.remove(listener);
  }

  static void _notifyTokenListeners(String token, SessionStorageService? storageService) {
    _currentToken = token;
    if (storageService != null) {
      storageService.saveFcmToken(token);
    }
    log('====================================================', name: 'FCM');
    log('🔥 [FCM TOKEN OBTAINED]: $token', name: 'FCM');
    log('====================================================', name: 'FCM');
    for (final listener in List.of(_tokenListeners)) {
      try {
        listener(token);
      } catch (e) {
        log('Error notifying FCM token listener: $e', name: 'FCM', error: e);
      }
    }
  }

  /// Initialize Firebase & Firebase Messaging and cache token
  static Future<void> initialize({SessionStorageService? storageService}) async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions
      try {
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        log('User notification permission status: ${settings.authorizationStatus}', name: 'FCM');
      } catch (e) {
        log('Error requesting notification permissions: $e', name: 'FCM', error: e);
      }

      // Listen for token refresh events
      messaging.onTokenRefresh.listen((newToken) {
        if (newToken.isNotEmpty) {
          _notifyTokenListeners(newToken, storageService);
        }
      });

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('FCM message received in foreground: ${message.notification?.title} - ${message.notification?.body}', name: 'FCM');
      });

      // Attempt to retrieve token immediately
      await _attemptFetchToken(storageService);
    } catch (e, stack) {
      log('Firebase/FCM initialization warning: $e\n$stack', name: 'FCM', error: e, stackTrace: stack);
    }
  }

  static Future<void> _attemptFetchToken(SessionStorageService? storageService) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        _retryTimer?.cancel();
        _retryTimer = null;
        _notifyTokenListeners(token, storageService);
        return;
      }
    } catch (e) {
      log('ℹ️ [FCM] Token not immediately available (device offline or Firebase Installations connecting...): $e', name: 'FCM');
    }

    // Schedule exponential backoff retries if token not yet acquired
    _scheduleRetry(storageService);
  }

  static void _scheduleRetry(SessionStorageService? storageService) {
    _retryTimer?.cancel();
    if (_currentToken != null && _currentToken!.isNotEmpty) return;
    if (_retryAttempts >= 10) return; // Cap retries

    _retryAttempts++;
    final delaySeconds = (_retryAttempts * 5).clamp(5, 60);
    _retryTimer = Timer(Duration(seconds: delaySeconds), () async {
      await _attemptFetchToken(storageService);
    });
  }

  /// Get current FCM token with fallback to storage or fresh fetch
  static Future<String?> getToken({SessionStorageService? storageService}) async {
    if (_currentToken != null && _currentToken!.isNotEmpty) {
      return _currentToken;
    }

    if (storageService != null) {
      final savedToken = await storageService.getFcmToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        _currentToken = savedToken;
        return savedToken;
      }
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        if (storageService != null) {
          await storageService.saveFcmToken(token);
        }
        return token;
      }
    } catch (e) {
      log('Error retrieving FCM token: $e', name: 'FCM', error: e);
    }

    return null;
  }
}
