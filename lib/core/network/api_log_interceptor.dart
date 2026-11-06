import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

/// High-visibility API logger for debug console using dart:developer log().
/// Prints every HTTP request, response, query param, body, and error.
class AppApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🌐 [API REQ] [${options.method}] ${options.uri}');

    if (options.headers.isNotEmpty) {
      final safeHeaders = Map<String, dynamic>.from(options.headers);
      if (safeHeaders.containsKey('Authorization')) {
        final authVal = safeHeaders['Authorization'].toString();
        safeHeaders['Authorization'] = authVal.length > 25
            ? '${authVal.substring(0, 18)}...[TRUNCATED]'
            : authVal;
      }
      buffer.writeln('   📋 Headers: $safeHeaders');
    }

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('   🔍 Query: ${options.queryParameters}');
    }

    if (options.data != null) {
      try {
        final bodyStr = options.data is Map || options.data is List
            ? jsonEncode(options.data)
            : options.data.toString();
        buffer.writeln('   📦 Body: $bodyStr');
      } catch (_) {
        buffer.writeln('   📦 Body: ${options.data}');
      }
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log(buffer.toString(), name: 'API');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(
        '✅ [API RESP] [${response.statusCode}] [${response.requestOptions.method}] ${response.requestOptions.uri}');
    try {
      final dataStr = response.data is Map || response.data is List
          ? jsonEncode(response.data)
          : response.data.toString();
      buffer.writeln('   📄 Data: $dataStr');
    } catch (_) {
      buffer.writeln('   📄 Data: ${response.data}');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log(buffer.toString(), name: 'API');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(
        '❌ [API ERR] [${err.response?.statusCode ?? 'NO_STATUS'}] [${err.requestOptions.method}] ${err.requestOptions.uri}');
    buffer.writeln('   ⚠️ Message: ${err.message}');
    if (err.response?.data != null) {
      try {
        final errStr = err.response!.data is Map || err.response!.data is List
            ? jsonEncode(err.response!.data)
            : err.response!.data.toString();
        buffer.writeln('   🛑 Error Data: $errStr');
      } catch (_) {
        buffer.writeln('   🛑 Error Data: ${err.response?.data}');
      }
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log(buffer.toString(), name: 'API', error: err);
    super.onError(err, handler);
  }
}

