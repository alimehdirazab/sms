import 'package:equatable/equatable.dart';
import 'leave_status.dart';

class LeaveItemModel extends Equatable {
  final String id;
  final String applicantId;
  final String applicantName;
  final String applicantType; // 'TEACHER', 'STUDENT', 'PARENT'
  final String roleOrClass;
  final String leaveType;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String description; // maps to reason/description
  final String? remarks;
  final LeaveStatus status;
  final String? submissionDate;
  final String? attachment;
  final String? studentId;

  const LeaveItemModel({
    required this.id,
    this.applicantId = '',
    this.applicantName = '',
    this.applicantType = '',
    this.roleOrClass = '',
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.totalDays = 1,
    required this.description,
    this.remarks,
    required this.status,
    this.submissionDate,
    this.attachment,
    this.studentId,
  });

  /// Compatibility alias for remarks/reviewReason
  String? get reviewReason => remarks;

  factory LeaveItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LeaveItemModel(
        id: '',
        leaveType: 'General Leave',
        startDate: '',
        endDate: '',
        description: '',
        status: LeaveStatus.pending,
      );
    }

    final id = json['id']?.toString() ??
        json['_id']?.toString() ??
        json['leaveId']?.toString() ??
        '';

    final applicantId = json['applicantId']?.toString() ?? '';
    final applicantName = json['applicantName']?.toString() ??
        json['applicant']?['name']?.toString() ??
        json['studentName']?.toString() ??
        json['name']?.toString() ??
        '';

    final applicantType = json['applicantType']?.toString() ??
        json['aplicantType']?.toString() ??
        json['type']?.toString() ??
        '';

    final roleOrClass = json['roleOrClass']?.toString() ??
        json['class']?.toString() ??
        json['role']?.toString() ??
        '';

    final leaveType = json['leaveType']?.toString() ??
        json['type']?.toString() ??
        'Leave';

    final startDate = json['startDate']?.toString() ??
        json['from']?.toString() ??
        '';

    final endDate = json['endDate']?.toString() ??
        json['to']?.toString() ??
        startDate;

    final totalDays = json['totalDays'] is num
        ? (json['totalDays'] as num).toInt()
        : 1;

    final description = json['reason']?.toString() ??
        json['description']?.toString() ??
        '';

    final remarks = json['remarks']?.toString() ??
        json['reviewReason']?.toString() ??
        json['approvalReason']?.toString();

    final statusStr = json['status']?.toString();
    final status = LeaveStatus.fromString(statusStr);

    final submissionDate = json['submissionDate']?.toString() ??
        json['createdAt']?.toString();

    final attachment = json['attachment']?.toString();

    final upperType = applicantType.toUpperCase();
    final studentId = json['studentId']?.toString() ??
        ((upperType == 'STUDENT' || upperType == 'STUDEN') ? applicantId : null);

    return LeaveItemModel(
      id: id,
      applicantId: applicantId,
      applicantName: applicantName,
      applicantType: applicantType,
      roleOrClass: roleOrClass,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      description: description,
      remarks: remarks,
      status: status,
      submissionDate: submissionDate,
      attachment: attachment,
      studentId: studentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantType': applicantType,
      'roleOrClass': roleOrClass,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'totalDays': totalDays,
      'description': description,
      if (remarks != null) 'remarks': remarks,
      'status': status.toApiString(),
      if (submissionDate != null) 'submissionDate': submissionDate,
      if (attachment != null) 'attachment': attachment,
      if (studentId != null) 'studentId': studentId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        applicantId,
        applicantName,
        applicantType,
        roleOrClass,
        leaveType,
        startDate,
        endDate,
        totalDays,
        description,
        remarks,
        status,
        submissionDate,
        attachment,
        studentId,
      ];
}
