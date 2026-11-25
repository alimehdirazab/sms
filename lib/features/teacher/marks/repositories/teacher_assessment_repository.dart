import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_error_handler.dart';

class TeacherAssessmentRepository {
  final ApiClient apiClient;

  TeacherAssessmentRepository({required this.apiClient});

  /// 1. GET /teacher/tests
  Future<List<Map<String, dynamic>>> getTests({
    String? courseId,
    String? search,
    String? type,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (courseId != null && courseId.isNotEmpty) query['courseId'] = courseId;
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (type != null && type.isNotEmpty) query['type'] = type;
      if (status != null && status.isNotEmpty) query['status'] = status;

      final response = await apiClient.dio.get(
        ApiConstants.teacherTests,
        queryParameters: query,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch tests'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. POST /teacher/tests
  Future<Map<String, dynamic>> createTest({
    required String courseId,
    required String title,
    required String type,
    required String examDate,
    required num totalMarks,
    required num passMarks,
  }) async {
    try {
      final payload = {
        'courseId': courseId,
        'title': title,
        'type': type,
        'examDate': examDate,
        'totalMarks': totalMarks,
        'passMarks': passMarks,
      };

      final response = await apiClient.dio.post(
        ApiConstants.teacherTests,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'success': true};
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to create test'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 3. PUT /teacher/marks/tests/:id (Draft/Save Students Mark)
  Future<Map<String, dynamic>> saveDraftMarks({
    required String testId,
    required List<Map<String, dynamic>> entries,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiConstants.teacherTestMarksDraft(testId),
        data: {'entries': entries},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'success': true};
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to save marks draft'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 4. POST /teacher/marks/tests/:id/submit (Submit Students Mark)
  Future<Map<String, dynamic>> submitFinalMarks({
    required String testId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.teacherTestMarksSubmit(testId),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'success': true};
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to submit marks'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _extractErrorMessage(dynamic e, String fallback) {
    return ApiErrorHandler.extract(e, fallback: fallback);
  }
}
