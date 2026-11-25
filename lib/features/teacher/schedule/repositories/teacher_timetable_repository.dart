import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_error_handler.dart';
import '../models/teacher_timetable_model.dart';

class TeacherTimetableRepository {
  final ApiClient apiClient;

  TeacherTimetableRepository({required this.apiClient});

  /// GET /teacher/timetable/today
  Future<TodayTimetableModel> getTodayTimetable() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.timetableToday);
      return TodayTimetableModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch timetable schedule'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _extractErrorMessage(dynamic e, String fallback) {
    return ApiErrorHandler.extract(e, fallback: fallback);
  }
}
