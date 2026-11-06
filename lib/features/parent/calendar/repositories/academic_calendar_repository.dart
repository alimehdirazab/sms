import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/models/academic_calendar_model.dart';

class AcademicCalendarRepository {
  final ApiClient apiClient;

  AcademicCalendarRepository({required this.apiClient});

  /// 1. GET /academic-calendar/events
  /// Optional filters: sessionId, from (YYYY-MM-DD), to (YYYY-MM-DD), type (holiday, event, etc.)
  Future<List<AcademicCalendarEvent>> getEvents({
    String? sessionId,
    String? from,
    String? to,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (sessionId != null && sessionId.isNotEmpty) {
        queryParams['sessionId'] = sessionId;
      }
      if (from != null && from.isNotEmpty) {
        queryParams['from'] = from;
      }
      if (to != null && to.isNotEmpty) {
        queryParams['to'] = to;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await apiClient.dio.get(
        ApiConstants.academicCalendarEvents,
        queryParameters: queryParams,
      );

      final data = response.data;
      final List<dynamic> list;
      if (data is Map<String, dynamic> && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => AcademicCalendarEvent.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch calendar events'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. GET /academic-calendar/sessions
  Future<List<AcademicCalendarSessionModel>> getSessions() async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.academicCalendarSessions,
      );

      final data = response.data;
      final List<dynamic> list;
      if (data is Map<String, dynamic> && data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => AcademicCalendarSessionModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch academic sessions'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 3. GET /academic-calendar/events/{{eventId}}
  Future<AcademicCalendarEvent> getEventDetails(String eventId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.academicCalendarEventDetails(eventId),
      );

      final data = response.data;
      final Map<String, dynamic>? itemMap;
      if (data is Map<String, dynamic>) {
        itemMap = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
      } else {
        itemMap = null;
      }

      return AcademicCalendarEvent.fromJson(itemMap);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch event details'));
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

