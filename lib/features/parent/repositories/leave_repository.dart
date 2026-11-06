import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/leave_api_model.dart';

class LeaveRepository {
  final ApiClient apiClient;

  LeaveRepository({required this.apiClient});

  /// Check if a string is a valid UUID format
  static bool isValidUuid(String? id) {
    if (id == null || id.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(id.trim());
  }

  /// 1. POST /leaves (Teacher leave application)
  Future<LeaveItemModel> createTeacherLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String description,
    String? attachment,
  }) async {
    try {
      final payload = <String, dynamic>{
        'leaveType': leaveType,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };
      if (attachment != null &&
          attachment.isNotEmpty &&
          attachment != 'null' &&
          attachment != 'base64-attachment-demo') {
        payload['attachment'] = attachment;
      }

      final response = await apiClient.dio.post(
        ApiConstants.leaves,
        data: payload,
      );

      final data = response.data;
      final payloadData = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic> ? data['data'] : data)
          : null;

      return LeaveItemModel.fromJson(payloadData as Map<String, dynamic>?);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to submit leave application'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. POST /leaves (Parent leave application for Student)
  Future<LeaveItemModel> createParentLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String description,
    String? studentId,
    String? attachment,
  }) async {
    try {
      final payload = <String, dynamic>{
        'leaveType': leaveType,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };

      // Only include studentId if it's a valid UUID.
      // If omitted or non-UUID, the backend automatically uses the parent's currently active child.
      if (studentId != null && isValidUuid(studentId)) {
        payload['studentId'] = studentId.trim();
      }

      if (attachment != null &&
          attachment.isNotEmpty &&
          attachment != 'null' &&
          attachment != 'base64-attachment-demo') {
        payload['attachment'] = attachment;
      }

      final response = await apiClient.dio.post(
        ApiConstants.leaves,
        data: payload,
      );

      final data = response.data;
      final payloadData = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic> ? data['data'] : data)
          : null;

      return LeaveItemModel.fromJson(payloadData as Map<String, dynamic>?);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to submit student leave application'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 3. GET /leaves (List with Filters & Pagination)
  Future<LeavePaginationModel> getLeaves({
    String? status,
    int page = 1,
    int limit = 10,
    String? startDate,
    String? endDate,
    String? search,
    String? applicantType,
    String? studentId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (startDate != null && startDate.isNotEmpty) queryParams['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['endDate'] = endDate;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (applicantType != null && applicantType.isNotEmpty) {
        final typeVal = applicantType == 'STUDENT' ? 'STUDEN' : applicantType;
        queryParams['aplicantType'] = typeVal;
        queryParams['applicantType'] = typeVal;
      }
      if (studentId != null && isValidUuid(studentId)) {
        queryParams['studentId'] = studentId.trim();
      }

      final response = await apiClient.dio.get(
        ApiConstants.leaves,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return LeavePaginationModel.fromJson(data);
      }
      return const LeavePaginationModel(
        items: [],
        totalCount: 0,
        currentPage: 1,
        totalPages: 1,
        hasNextPage: false,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch leaves'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 4. GET /leaves/{leaveId}
  Future<LeaveItemModel> getLeaveById(String leaveId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.leaveDetails(leaveId),
      );

      final data = response.data;
      final payload = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic> ? data['data'] : data)
          : null;

      return LeaveItemModel.fromJson(payload as Map<String, dynamic>?);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch leave details'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 5. PATCH /leaves/{leaveId}/status (Approve or Reject)
  Future<LeaveItemModel> updateLeaveStatus({
    required String leaveId,
    required String status, // 'APPROVED' or 'REJECTED'
    required String reason,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        ApiConstants.updateLeaveStatus(leaveId),
        data: {
          'status': status.toUpperCase(),
          'reason': reason,
        },
      );

      final data = response.data;
      final payload = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic> ? data['data'] : data)
          : null;

      return LeaveItemModel.fromJson(payload as Map<String, dynamic>?);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to update leave status'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 6. DELETE /leaves/{leaveId} (Pending only)
  Future<bool> deleteLeave(String leaveId) async {
    try {
      await apiClient.dio.delete(
        ApiConstants.deleteLeave(leaveId),
      );
      return true;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to delete leave request'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _extractErrorMessage(DioException e, String fallback) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      final msg = data['message'];
      if (msg is List && msg.isNotEmpty) {
        return msg.join(', ');
      }
      if (msg is String && msg.isNotEmpty) {
        return msg;
      }
      final err = data['error'];
      if (err is String && err.isNotEmpty) {
        return err;
      }
      return fallback;
    }
    return e.message ?? fallback;
  }
}
