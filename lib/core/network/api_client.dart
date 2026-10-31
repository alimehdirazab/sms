import 'package:dio/dio.dart';
import '../storage/session_storage_service.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;
  final SessionStorageService storageService;

  ApiClient({
    required this.storageService,
    Dio? customDio,
    void Function()? onSessionExpired,
  }) : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.defaultBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _initInterceptors(onSessionExpired);
  }

  void _initInterceptors(void Function()? onSessionExpired) {
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storageService: storageService,
        onSessionExpired: onSessionExpired,
      ),
    );

    // Optional logger interceptor
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
  }
}
