import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../auth/models/marks_model.dart';

class ParentExamRepository {
  final ApiClient apiClient;

  ParentExamRepository({required this.apiClient});

  /// GET /parent/exams?studentId={{studentId}}&status=all&page=1&limit=100
  Future<Map<String, dynamic>> getStudentExamsRaw(String studentId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.parentExams,
        queryParameters: {
          'studentId': studentId,
          'status': 'all',
          'page': 1,
          'limit': 100,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch student exams'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Converts raw exams into ExamModel items
  Future<List<ExamModel>> getUpcomingExams(String studentId) async {
    try {
      final raw = await getStudentExamsRaw(studentId);
      final list = raw['data'];
      if (list is List && list.isNotEmpty) {
        return list.whereType<Map<String, dynamic>>().map((e) {
          final examDateStr = e['examDate']?.toString() ?? '';
          DateTime parsedDate;
          try {
            parsedDate = DateTime.parse(examDateStr);
          } catch (_) {
            parsedDate = DateTime.now().add(const Duration(days: 3));
          }

          final statusStr = e['status']?.toString().toLowerCase() ?? '';
          final markStatus = statusStr == 'submitted' || statusStr == 'published'
              ? MarkStatus.published
              : MarkStatus.draft;

          return ExamModel(
            id: e['examId']?.toString() ?? '',
            name: e['title']?.toString() ?? 'Assessment',
            className: e['className']?.toString() ?? '',
            subjectId: e['subjectId']?.toString() ?? '',
            subjectName: e['subjectName']?.toString() ?? 'Subject',
            date: parsedDate,
            status: markStatus,
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Converts raw exams into StudentMarkModel items
  Future<List<StudentMarkModel>> getStudentMarks(String studentId) async {
    try {
      final raw = await getStudentExamsRaw(studentId);
      final list = raw['data'];
      final studentInfo = raw['student'] is Map<String, dynamic>
          ? raw['student'] as Map<String, dynamic>
          : <String, dynamic>{};

      final studentName = studentInfo['firstName'] != null
          ? '${studentInfo['firstName']} ${studentInfo['lastName'] ?? ''}'.trim()
          : 'Student';
      final rollNo = studentInfo['admissionNumber']?.toString() ??
          studentInfo['studentId']?.toString() ??
          '';

      if (list is List && list.isNotEmpty) {
        final List<StudentMarkModel> marks = [];
        for (final item in list.whereType<Map<String, dynamic>>()) {
          final marksObj = item['marks'] is Map<String, dynamic>
              ? item['marks'] as Map<String, dynamic>
              : null;

          final totalMarks = (item['totalMarks'] is num)
              ? (item['totalMarks'] as num).toDouble()
              : 100.0;

          final obtainedMarks = marksObj != null && marksObj['marksObtained'] is num
              ? (marksObj['marksObtained'] as num).toDouble()
              : 0.0;

          marks.add(
            StudentMarkModel(
              id: item['examId']?.toString() ?? '',
              examId: item['examId']?.toString() ?? '',
              studentId: studentId,
              studentName: studentName,
              rollNumber: rollNo,
              obtainedMarks: obtainedMarks,
              totalMarks: totalMarks,
              status: MarkStatus.published,
              teacherRemarks: marksObj?['remarks']?.toString(),
            ),
          );
        }
        return marks;
      }
      return [];
    } catch (_) {
      return [];
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
