import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/models/notification_model.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  /// 1. GET /notifications
  Future<NotificationListResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
    bool onlyUnread = false,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (onlyUnread) 'onlyUnread': true,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final response = await apiClient.dio.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      final data = response.data;
      return NotificationListResponseModel.fromJson(
        data is Map<String, dynamic> ? data : null,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch notifications'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. GET /notifications?sentByMe=true
  Future<NotificationListResponseModel> getSentByMeNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.notifications,
        queryParameters: {
          'sentByMe': true,
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;
      return NotificationListResponseModel.fromJson(
        data is Map<String, dynamic> ? data : null,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch sent notifications'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 3. PATCH /notifications/{{id}}/read
  Future<bool> markAsRead(String id) async {
    try {
      final response = await apiClient.dio.patch(
        ApiConstants.markNotificationRead(id),
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['success'] == true;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to mark notification as read'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 4. PATCH /notifications/mark-all-read
  Future<bool> markAllAsRead() async {
    try {
      final response = await apiClient.dio.patch(
        ApiConstants.markAllNotificationsRead,
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['success'] == true;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to mark all notifications as read'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 5. POST /notifications/fcm-token
  Future<bool> registerFcmToken(
    String token, {
    String? platform,
    String? userAgent,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.notificationFcmToken,
        data: {
          'token': token,
          'platform': platform ?? (Platform.isAndroid ? 'ANDROID' : (Platform.isIOS ? 'IOS' : 'WEB')),
          'userAgent': userAgent ?? 'Flutter School Mobile App (${Platform.operatingSystem})',
        },
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['success'] == true;
    } on DioException catch (_) {
      // Don't crash app if token registration fails
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 6. DELETE /notifications/fcm-token
  Future<bool> unregisterFcmToken(String token) async {
    try {
      final response = await apiClient.dio.delete(
        ApiConstants.notificationFcmToken,
        data: {'token': token},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['success'] == true;
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 7. POST /notifications/broadcast (Teacher/Admin broadcast announcement)
  Future<bool> broadcastAnnouncement({
    required String title,
    required String message,
    String category = 'ANNOUNCEMENT',
    String? actionUrl,
    required int schoolId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.notificationBroadcast,
        data: {
          'title': title,
          'message': message,
          'category': category,
          'actionUrl': actionUrl ?? '/announcements',
          'schoolId': schoolId,
        },
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['success'] == true;
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

