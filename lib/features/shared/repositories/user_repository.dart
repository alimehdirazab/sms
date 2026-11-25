import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_error_handler.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  /// 1. GET /users/:id
  Future<Map<String, dynamic>> getUserProfile(dynamic userId) async {
    try {
      final response = await apiClient.dio.get(ApiConstants.user(userId));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        return data;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch user profile'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. PUT /users/:id
  Future<Map<String, dynamic>> updateUserProfile({
    required dynamic userId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConstants.user(userId),
        data: payload,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'success': true};
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to update profile'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _extractErrorMessage(dynamic e, String fallback) {
    return ApiErrorHandler.extract(e, fallback: fallback);
  }
}
