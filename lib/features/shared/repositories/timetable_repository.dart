import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_error_handler.dart';
import '../models/timetable_item_model.dart';

class TimetableRepository {
  final ApiClient apiClient;

  TimetableRepository({required this.apiClient});

  /// 1. GET /academic-calendar/sessions
  Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.academicCalendarSessions);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Resolve active academic session ID
  Future<String?> getActiveSessionId() async {
    final sessions = await getSessions();
    if (sessions.isEmpty) return null;
    final active = sessions.firstWhere(
      (s) => s['status']?.toString().toLowerCase() == 'active',
      orElse: () => sessions.first,
    );
    return active['id']?.toString();
  }

  /// 2. GET /timetable/?academicYearId={{academicYearId}}
  Future<List<TimetableItemModel>> getTimetable({String? academicYearId}) async {
    try {
      var sessionId = academicYearId;
      if (sessionId == null || sessionId.isEmpty) {
        sessionId = await getActiveSessionId();
      }

      final queryParams = <String, dynamic>{};
      if (sessionId != null && sessionId.isNotEmpty) {
        queryParams['academicYearId'] = sessionId;
      }

      final response = await apiClient.dio.get(
        ApiConstants.timetable,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => TimetableItemModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch timetable entries'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Groups timetable entries by weekday (Monday - Saturday)
  Future<Map<String, List<TimetableItemModel>>> getWeeklyTimetableGrouped({
    String? academicYearId,
  }) async {
    final entries = await getTimetable(academicYearId: academicYearId);

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    final Map<String, List<TimetableItemModel>> grouped = {
      for (final day in weekdays) day: <TimetableItemModel>[],
    };

    for (final entry in entries) {
      final dayKey = weekdays.firstWhere(
        (w) => w.toLowerCase() == entry.day.toLowerCase(),
        orElse: () => 'Monday',
      );
      grouped[dayKey]?.add(entry);
    }

    // Sort entries within each day by startTime
    for (final day in weekdays) {
      grouped[day]?.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  /// Download timetable PDF as bytes
  Future<List<int>> exportTimetablePdf({required String academicYearId}) async {
    try {
      final response = await apiClient.dio.get<List<int>>(
        ApiConstants.timetableExportPdf,
        queryParameters: {'academicYearId': academicYearId},
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to export timetable PDF'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _extractErrorMessage(dynamic e, String fallback) {
    return ApiErrorHandler.extract(e, fallback: fallback);
  }
}
