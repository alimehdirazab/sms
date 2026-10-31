import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
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
