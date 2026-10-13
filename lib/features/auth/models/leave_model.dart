import 'package:equatable/equatable.dart';

/// Who is requesting the leave.
enum LeaveApplicant { parent, teacher }

/// The lifecycle of a leave application. The Principal (separate web app)
/// reviews and moves an application from [pending] to [approved] / [rejected].
enum LeaveStatus { pending, approved, rejected, cancelled }

/// Types of leave a Parent can apply for on behalf of a student.
enum LeaveType {
  sick,
  casual,
  emergency,
  familyFunction,
  vacation,
  medical,
  sports,
  exam,
  halfDay,
  lateArrival,
  other,
}

extension LeaveTypeX on LeaveType {
  /// Human friendly label shown in the UI.
  String get label {
    switch (this) {
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.casual:
        return 'Casual Leave';
      case LeaveType.emergency:
        return 'Emergency Leave';
      case LeaveType.familyFunction:
        return 'Family Function';
      case LeaveType.vacation:
        return 'Vacation';
      case LeaveType.medical:
        return 'Medical / Hospital';
      case LeaveType.sports:
        return 'Sports / Competition';
      case LeaveType.exam:
        return 'Exam Related';
      case LeaveType.halfDay:
        return 'Half Day';
      case LeaveType.lateArrival:
        return 'Late Arrival';
      case LeaveType.other:
        return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case LeaveType.sick:
        return 'sick';
      case LeaveType.casual:
        return 'casual';
      case LeaveType.emergency:
        return 'emergency';
      case LeaveType.familyFunction:
        return 'family';
      case LeaveType.vacation:
        return 'vacation';
      case LeaveType.medical:
        return 'medical';
      case LeaveType.sports:
        return 'sports';
      case LeaveType.exam:
        return 'exam';
      case LeaveType.halfDay:
        return 'halfday';
      case LeaveType.lateArrival:
        return 'late';
      case LeaveType.other:
        return 'other';
    }
  }
}

extension LeaveStatusX on LeaveStatus {
  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// A leave application submitted by a parent (for a student) or by a teacher.
class LeaveApplicationModel extends Equatable {
  final String id;

  /// Student id (parent flow) or employee id (teacher flow).
  final String applicantId;

  /// Display name of the student or teacher the leave belongs to.
  final String applicantName;

  /// Class name for student leaves (empty for teachers).
  final String className;

  final LeaveApplicant applicantType;
  final LeaveType type;
  final DateTime fromDate;
  final DateTime toDate;

  /// Optional free-text description written by the applicant.
  final String reason;

  final LeaveStatus status;

  /// Remarks added by the Principal when approving/rejecting.
  final String? principalRemarks;

  final DateTime appliedOn;

  /// Attachment file name (e.g. medical certificate). Mock only.
  final String? attachmentName;

  const LeaveApplicationModel({
    required this.id,
    required this.applicantId,
    required this.applicantName,
    required this.applicantType,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.className = '',
    this.status = LeaveStatus.pending,
    this.principalRemarks,
    required this.appliedOn,
    this.attachmentName,
  });

  /// Number of days covered by this application (inclusive).
  int get totalDays => toDate.difference(fromDate).inDays + 1;

  LeaveApplicationModel copyWith({
    String? id,
    String? applicantId,
    String? applicantName,
    String? className,
    LeaveApplicant? applicantType,
    LeaveType? type,
    DateTime? fromDate,
    DateTime? toDate,
    String? reason,
    LeaveStatus? status,
    String? principalRemarks,
    DateTime? appliedOn,
    String? attachmentName,
  }) {
    return LeaveApplicationModel(
      id: id ?? this.id,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      className: className ?? this.className,
      applicantType: applicantType ?? this.applicantType,
      type: type ?? this.type,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      principalRemarks: principalRemarks ?? this.principalRemarks,
      appliedOn: appliedOn ?? this.appliedOn,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        applicantId,
        applicantName,
        className,
        applicantType,
        type,
        fromDate,
        toDate,
        reason,
        status,
        principalRemarks,
        appliedOn,
        attachmentName,
      ];
}
