import 'dart:io';
import 'package:dio/dio.dart';

class ApiErrorHandler {
  static const String noInternetMessage =
      'No internet connection. Please check your network and try again.';

  static bool isNetworkError(dynamic e) {
    if (e is SocketException) return true;
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return true;
      }
      if (e.error is SocketException) return true;
      final msg = e.message?.toLowerCase() ?? '';
      if (msg.contains('failed host lookup') ||
          msg.contains('socketexception') ||
          msg.contains('network is unreachable') ||
          msg.contains('connection errored') ||
          msg.contains('connection refused') ||
          msg.contains('no address associated with hostname')) {
        return true;
      }
    }
    final str = e.toString().toLowerCase();
    return str.contains('failed host lookup') ||
        str.contains('socketexception') ||
        str.contains('network is unreachable');
  }

  static String extract(dynamic e, {String fallback = 'An unexpected error occurred'}) {
    if (isNetworkError(e)) {
      return noInternetMessage;
    }

    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
          final serverMsg = data['message'].toString();
          // If server returns validation errors array, append them
          if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            final errorList = (data['errors'] as List)
                .map((err) => err is Map ? err['message']?.toString() : null)
                .whereType<String>()
                .toList();
            if (errorList.isNotEmpty) {
              return errorList.first;
            }
          }
          return serverMsg;
        }
        if (data['error'] != null && data['error'].toString().trim().isNotEmpty) {
          return data['error'].toString();
        }
      }

      if (statusCode == 401) {
        return 'Session expired. Please log in again.';
      } else if (statusCode == 403) {
        return 'Access denied. You do not have permission to perform this action.';
      } else if (statusCode == 404) {
        return 'The requested resource was not found.';
      } else if (statusCode != null && statusCode >= 500) {
        return 'Server error. Please try again in a few moments.';
      }

      if (e.message != null && e.message!.isNotEmpty && !isNetworkError(e)) {
        return e.message!;
      }
    }

    return fallback;
  }
}
