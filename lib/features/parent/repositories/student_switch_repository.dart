import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/storage/session_storage_service.dart';

class SwitchStudentResult {
  final bool success;
  final String activeStudentId;
  final String message;

  SwitchStudentResult({
    required this.success,
    required this.activeStudentId,
    required this.message,
  });
}

class StudentSwitchRepository {
  final ApiClient apiClient;
  final SessionStorageService storageService;

  StudentSwitchRepository({
    required this.apiClient,
    required this.storageService,
  });

  /// POST /parent/switch-student
  Future<SwitchStudentResult> switchActiveStudent(String studentId) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.switchStudent,
        data: {'studentId': studentId},
      );

      final data = response.data;
      String newActiveId = studentId;
      String message = 'Active student updated';

      if (data is Map<String, dynamic>) {
        final payload = data['data'] ?? data;
        if (payload is Map<String, dynamic>) {
          newActiveId = payload['activeStudentId']?.toString() ??
              payload['studentId']?.toString() ??
              studentId;
        }
        message = data['message']?.toString() ?? message;
      }

      await storageService.saveActiveStudentId(newActiveId);

      return SwitchStudentResult(
        success: true,
        activeStudentId: newActiveId,
        message: message,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e, 'Failed to switch active student');
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String?> getCurrentActiveStudentId() async {
    return await storageService.getActiveStudentId();
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
