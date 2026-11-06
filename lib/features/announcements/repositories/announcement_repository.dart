import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/announcement_model.dart';

class AnnouncementRepository {
  final ApiClient apiClient;

  AnnouncementRepository({required this.apiClient});

  /// 1. GET /announcements?page=1&limit=10 (Teacher / Parent)
  Future<AnnouncementListResponseModel> getAnnouncements({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.announcements,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;
      return AnnouncementListResponseModel.fromJson(
        data is Map<String, dynamic> ? data : null,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch announcements'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. POST /announcements (Teacher: Create Announcement for Parents/Students)
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String message,
    required List<String> recipient,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.announcements,
        data: {
          'title': title.trim(),
          'message': message.trim(),
          'recipient': recipient.isNotEmpty ? recipient : ['parents'],
        },
      );

      final data = response.data;
      final payload = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic> ? data['data'] : data)
          : null;

      return AnnouncementModel.fromJson(payload as Map<String, dynamic>?);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to broadcast announcement'));
    } catch (e) {
      throw Exception(e.toString());
    }
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

