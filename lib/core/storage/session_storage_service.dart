import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorageService {
  static const String _keyAccessToken = 'sms_access_token';
  static const String _keyRefreshToken = 'sms_refresh_token';
  static const String _keyActiveStudentId = 'sms_active_student_id';
  static const String _keyUserRole = 'sms_user_role';
  static const String _keyUserProfile = 'sms_user_profile';
  static const String _keyCustomBaseUrl = 'sms_custom_base_url';
  static const String _keyFcmToken = 'sms_fcm_token';

  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  SessionStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Base URL Configuration ---
  Future<void> setCustomBaseUrl(String url) async {
    await init();
    await _prefs?.setString(_keyCustomBaseUrl, url);
  }

  Future<String?> getCustomBaseUrl() async {
    await init();
    return _prefs?.getString(_keyCustomBaseUrl);
  }

  // --- Tokens (Stored Securely) ---
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  // --- Active Student ID ---
  Future<void> saveActiveStudentId(String studentId) async {
    await init();
    await _prefs?.setString(_keyActiveStudentId, studentId);
  }

  Future<String?> getActiveStudentId() async {
    await init();
    return _prefs?.getString(_keyActiveStudentId);
  }

  // --- User Role ---
  Future<void> saveUserRole(String role) async {
    await init();
    await _prefs?.setString(_keyUserRole, role);
  }

  Future<String?> getUserRole() async {
    await init();
    return _prefs?.getString(_keyUserRole);
  }

  // --- User Profile JSON ---
  Future<void> saveUserProfile(Map<String, dynamic> userMap) async {
    await init();
    await _prefs?.setString(_keyUserProfile, jsonEncode(userMap));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    await init();
    final raw = _prefs?.getString(_keyUserProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // --- FCM Token ---
  Future<void> saveFcmToken(String token) async {
    await init();
    await _prefs?.setString(_keyFcmToken, token);
  }

  Future<String?> getFcmToken() async {
    await init();
    return _prefs?.getString(_keyFcmToken);
  }

  // --- Clear Session on Logout / Expiry ---
  Future<void> clearSession() async {
    await init();
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _prefs?.remove(_keyActiveStudentId);
    await _prefs?.remove(_keyUserRole);
    await _prefs?.remove(_keyUserProfile);
  }
}
