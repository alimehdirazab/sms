import 'package:equatable/equatable.dart';
import 'attendance_summary_model.dart';
import 'teacher_attendance_status.dart';
export 'attendance_summary_model.dart';
export 'teacher_attendance_status.dart';

class AttendanceRecordModel extends Equatable {
  final String id;
  final String teacherId;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkInAccuracy;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final double? checkOutAccuracy;
  final String? selfieUrl;
  final TeacherAttendanceStatus status;
  final String? type;
  final String? reason;
  final bool isInsideGeofence;
  final String? createdAt;
  final String? updatedAt;

  const AttendanceRecordModel({
    required this.id,
    this.teacherId = '',
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAccuracy,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutAccuracy,
    this.selfieUrl,
    required this.status,
    this.type,
    this.reason,
    this.isInsideGeofence = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AttendanceRecordModel(
        id: '',
        date: '',
        status: TeacherAttendanceStatus.unknown,
      );
    }

    final id = json['id']?.toString() ??
        json['_id']?.toString() ??
        json['attendanceId']?.toString() ??
        '';

    final teacherId = json['teacherId']?.toString() ??
        json['userId']?.toString() ??
        json['employeeId']?.toString() ??
        '';

    final date = json['date']?.toString() ??
        json['attendanceDate']?.toString() ??
        '';

    final checkInTime = json['checkInTime']?.toString() ??
        json['checkIn']?.toString() ??
        json['checkInAt']?.toString();

    final checkOutTime = json['checkOutTime']?.toString() ??
        json['checkOut']?.toString() ??
        json['checkOutAt']?.toString();

    final checkInLatitude = _toDouble(json['latitude'] ?? json['checkInLatitude']);
    final checkInLongitude = _toDouble(json['longitude'] ?? json['checkInLongitude']);
    final checkInAccuracy = _toDouble(json['accuracy'] ?? json['checkInAccuracy']);

    final checkOutLatitude = _toDouble(json['checkOutLatitude']);
    final checkOutLongitude = _toDouble(json['checkOutLongitude']);
    final checkOutAccuracy = _toDouble(json['checkOutAccuracy']);

    final selfieUrl = json['checkInImage']?.toString() ??
        json['selfieUrl']?.toString() ??
        json['selfie']?.toString() ??
        json['photoUrl']?.toString() ??
        json['attachment']?.toString();

    final statusStr = json['status']?.toString() ?? json['type']?.toString();
    final status = TeacherAttendanceStatus.fromString(statusStr);
    final type = json['type']?.toString();
    final reason = json['reason']?.toString() ?? json['remarks']?.toString();

    final isInsideGeofence = json['isInsideGeofence'] is bool
        ? json['isInsideGeofence'] as bool
        : true;

    return AttendanceRecordModel(
      id: id,
      teacherId: teacherId,
      date: date,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      checkInLatitude: checkInLatitude,
      checkInLongitude: checkInLongitude,
      checkInAccuracy: checkInAccuracy,
      checkOutLatitude: checkOutLatitude,
      checkOutLongitude: checkOutLongitude,
      checkOutAccuracy: checkOutAccuracy,
      selfieUrl: selfieUrl,
      status: status,
      type: type,
      reason: reason,
      isInsideGeofence: isInsideGeofence,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'date': date,
      if (checkInTime != null) 'checkInTime': checkInTime,
      if (checkOutTime != null) 'checkOutTime': checkOutTime,
      if (checkInLatitude != null) 'latitude': checkInLatitude,
      if (checkInLongitude != null) 'longitude': checkInLongitude,
      if (checkInAccuracy != null) 'accuracy': checkInAccuracy,
      if (selfieUrl != null) 'checkInImage': selfieUrl,
      'status': status.displayName.toUpperCase(),
      if (type != null) 'type': type,
      if (reason != null) 'reason': reason,
      'isInsideGeofence': isInsideGeofence,
    };
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        teacherId,
        date,
        checkInTime,
        checkOutTime,
        checkInLatitude,
        checkInLongitude,
        status,
        type,
        selfieUrl,
        reason,
      ];
}

class AttendanceHistoryResponseModel extends Equatable {
  final bool success;
  final String message;
  final List<AttendanceRecordModel> records;
  final AttendanceSummaryModel? summary;
  final AttendanceRecordModel? todayRecord;
  final int totalCount;

  const AttendanceHistoryResponseModel({
    required this.success,
    required this.message,
    required this.records,
    this.summary,
    this.todayRecord,
    required this.totalCount,
  });

  factory AttendanceHistoryResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AttendanceHistoryResponseModel(
        success: false,
        message: 'Empty response',
        records: [],
        totalCount: 0,
      );
    }

    final success = json['success'] is bool
        ? json['success'] as bool
        : (json['status'] == 'success' || json['data'] != null);

    final message = json['message']?.toString() ?? '';

    dynamic dataList;
    AttendanceRecordModel? today;
    AttendanceSummaryModel? summary;

    final dataField = json['data'] ?? json['records'] ?? json['attendance'];

    if (dataField is List) {
      dataList = dataField;
    } else if (dataField is Map<String, dynamic>) {
      final innerList = dataField['records'] ??
          dataField['items'] ??
          dataField['attendance'] ??
          dataField['history'];
      dataList = innerList is List ? innerList : [];

      if (dataField['summary'] is Map<String, dynamic>) {
        summary = AttendanceSummaryModel.fromJson(dataField['summary'] as Map<String, dynamic>);
      }
      if (dataField['today'] is Map<String, dynamic>) {
        today = AttendanceRecordModel.fromJson(dataField['today']);
      }
    } else if (json['records'] is List) {
      dataList = json['records'];
    } else {
      dataList = [];
    }

    final records = (dataList as List)
        .whereType<Map<String, dynamic>>()
        .map((e) => AttendanceRecordModel.fromJson(e))
        .toList();

    return AttendanceHistoryResponseModel(
      success: success,
      message: message,
      records: records,
      summary: summary,
      todayRecord: today ?? (records.isNotEmpty ? records.first : null),
      totalCount: records.length,
    );
  }

  @override
  List<Object?> get props => [success, message, records, summary, todayRecord, totalCount];
}
