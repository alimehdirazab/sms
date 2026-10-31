import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/attendance_api_model.dart';

class TeacherAttendanceRepository {
  final ApiClient apiClient;

  TeacherAttendanceRepository({required this.apiClient});

  /// 1. POST /attendance/check-in
  /// Accepts real GPS latitude, longitude, accuracy and selfie image as file in multipart/form-data with key 'image' (not base64)
  Future<AttendanceRecordModel> checkIn({
    required double latitude,
    required double longitude,
    required double accuracy,
    File? selfieImage,
    String? deviceId,
    String? deviceModel,
    String? platform,
    String? osVersion,
    String? appVersion,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'accuracy': accuracy.toString(),
        'deviceId': deviceId ?? 'device-${Platform.operatingSystem}',
        'deviceModel': deviceModel ?? Platform.operatingSystem,
        'platform': platform ?? (Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'mobile')),
        'osVersion': osVersion ?? Platform.operatingSystemVersion,
        'appVersion': appVersion ?? '1.0.0',
      };

      if (selfieImage != null && await selfieImage.exists()) {
        final mimeType = lookupMimeType(selfieImage.path) ?? 'image/jpeg';
        final mimeSplit = mimeType.split('/');
        final fileName = selfieImage.path.split(Platform.pathSeparator).last;

        formDataMap['image'] = await MultipartFile.fromFile(
          selfieImage.path,
          filename: fileName,
          contentType: MediaType(mimeSplit.first, mimeSplit.last),
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await apiClient.dio.post(
        ApiConstants.attendanceCheckIn,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;
      final recordMap = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic> ? data['data'] : data)
          : null;

      return AttendanceRecordModel.fromJson(recordMap as Map<String, dynamic>?);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to complete check-in'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. POST /attendance/check-out
  Future<AttendanceRecordModel> checkOut({
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.attendanceCheckOut,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
        },
      );

      final data = response.data;
      final recordMap = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic> ? data['data'] : data)
          : null;

      return AttendanceRecordModel.fromJson(recordMap as Map<String, dynamic>?);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to complete check-out'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 3. GET /attendance/recent
  Future<AttendanceHistoryResponseModel?> getRecentAttendance() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.attendanceRecent);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AttendanceHistoryResponseModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to load recent attendance'));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 4. GET /attendance/my-attendance?startDate=...&endDate=...
  Future<List<AttendanceRecordModel>> getMyAttendanceHistory({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      final response = await apiClient.dio.get(
        ApiConstants.attendanceMyHistory,
        queryParameters: queryParams,
      );

      final parsed = AttendanceHistoryResponseModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null,
      );

      return parsed.records;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Failed to fetch attendance history'));
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
