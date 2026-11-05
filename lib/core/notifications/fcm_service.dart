// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
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
  debugPrint('FCM Background message: ${message.messageId}');
}

class FcmService {
  static String? _currentToken;
  static bool _initialized = false;

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
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('User notification permission status: ${settings.authorizationStatus}');

      // Fetch FCM Token
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        if (storageService != null) {
          await storageService.saveFcmToken(token);
        }
        debugPrint('FCM Token obtained: $token');
      }

      // Listen for token refresh events
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        if (storageService != null) {
          storageService.saveFcmToken(newToken);
        }
        debugPrint('FCM Token refreshed: $newToken');
      });

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM message received in foreground: ${message.notification?.title} - ${message.notification?.body}');
      });
    } catch (e, stack) {
      debugPrint('Firebase/FCM initialization warning: $e\n$stack');
    }
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
      debugPrint('Error retrieving FCM token: $e');
    }

    return null;
  }
}
