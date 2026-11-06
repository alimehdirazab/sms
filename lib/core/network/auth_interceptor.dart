import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../storage/session_storage_service.dart';
import 'api_constants.dart';

/// Interceptor to automatically attach Bearer token and refresh expired tokens seamlessly
class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final SessionStorageService storageService;
  final void Function()? onSessionExpired;

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  AuthInterceptor({
    required this.dio,
    required this.storageService,
    this.onSessionExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Endpoints that do not need access token
    final path = options.path;
    final isPublic = path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.refresh) ||
        path.contains(ApiConstants.forgotPassword) ||
        path.contains(ApiConstants.resetPassword);

    if (!isPublic) {
      final token = await storageService.getAccessToken();
      if (token == null || token.isEmpty) {
        log('⛔ [AuthInterceptor] Prevented pre-login API call to "$path" (No active access token).');
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'Cannot call authenticated API before login. Access token is missing.',
          ),
        );
      }
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    // Detect 401 Unauthorized
    if (response?.statusCode == 401 &&
        !requestOptions.path.contains(ApiConstants.login) &&
        !requestOptions.path.contains(ApiConstants.refresh)) {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        // User is not logged in; do not attempt refresh loop
        return handler.next(err);
      }

      try {
        final newAccessToken = await _handleTokenRefresh();

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Retry the failed request with new access token
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        } else {
          _triggerLogout();
          return handler.next(err);
        }
      } catch (e) {
        _triggerLogout();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<String?> _handleTokenRefresh() async {
    if (_isRefreshing) {
      return _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
        _refreshCompleter?.complete(null);
        return null;
      }

      // Create an independent Dio instance to avoid circular interceptor calls
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      String? newAccessToken;
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final payload = data['data'] ?? data;
          if (payload is Map<String, dynamic>) {
            newAccessToken = payload['accessToken']?.toString();
            final newRefreshToken = payload['refreshToken']?.toString();
            if (newAccessToken != null) {
              await storageService.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );
            }
          }
        }
      }

      _refreshCompleter?.complete(newAccessToken);
      return newAccessToken;
    } catch (e) {
      _refreshCompleter?.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  void _triggerLogout() {
    storageService.clearSession();
    onSessionExpired?.call();
  }
}
