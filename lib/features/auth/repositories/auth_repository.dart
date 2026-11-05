import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/notifications/fcm_service.dart';
import '../../../core/storage/session_storage_service.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SessionStorageService storageService;

  AuthRepository({
    required this.apiClient,
    required this.storageService,
  });

  /// 1. POST /auth/login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final token = fcmToken ?? await FcmService.getToken(storageService: storageService);
      final body = <String, dynamic>{
        'email': email.trim(),
        'password': password,
      };
      if (token != null && token.isNotEmpty) {
        body['fcmToken'] = token;
      }

      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: body,
      );

      final authModel = AuthResponseModel.fromJson(response.data);

      if (authModel.accessToken.isNotEmpty) {
        await storageService.saveTokens(
          accessToken: authModel.accessToken,
          refreshToken: authModel.refreshToken,
        );
        if (authModel.user != null) {
          await storageService.saveUserRole(authModel.user!.role);
          await storageService.saveUserProfile(authModel.user!.toJson());
          if (authModel.user!.activeStudentId != null) {
            await storageService.saveActiveStudentId(
              authModel.user!.activeStudentId!,
            );
          }
        }
      }

      return authModel;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, 'Login failed');
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. POST /auth/refresh
  Future<String?> refreshToken() async {
    try {
      final currentRefresh = await storageService.getRefreshToken();
      if (currentRefresh == null || currentRefresh.isEmpty) return null;

      final response = await apiClient.dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': currentRefresh},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'] ?? data;
        final newAccess = payload['accessToken']?.toString();
        final newRefresh = payload['refreshToken']?.toString();
        if (newAccess != null && newAccess.isNotEmpty) {
          await storageService.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return newAccess;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 3. POST /auth/forgot-password
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email.trim()},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            'Password reset link/token sent successfully.';
      }
      return 'Instructions sent to your email.';
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Unable to request password reset'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 4. POST /auth/reset-password
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.resetPassword,
        data: {
          'token': token.trim(),
          'password': newPassword,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            'Password has been reset successfully.';
      }
      return 'Password has been reset successfully.';
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to reset password'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 5. POST /auth/logout
  Future<void> logout({String? fcmToken}) async {
    try {
      final token = fcmToken ?? await FcmService.getToken(storageService: storageService);
      final body = <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        body['fcmToken'] = token;
      }
      await apiClient.dio.post(
        ApiConstants.logout,
        data: body.isNotEmpty ? body : null,
      );
    } catch (_) {
      // Ignore network errors on logout to guarantee client-side cleanup
    } finally {
      await storageService.clearSession();
    }
  }

  /// Check current authenticated session
  Future<UserModel?> getCachedUser() async {
    final token = await storageService.getAccessToken();
    if (token == null || token.isEmpty) return null;

    final userMap = await storageService.getUserProfile();
    if (userMap != null) {
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  String _extractErrorMessage(DioException e, String fallback) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      return data['message']?.toString() ??
          data['error']?.toString() ??
          fallback;
    }
    return e.message ?? fallback;
  }
}
