import 'package:equatable/equatable.dart';

/// Verification lifecycle of a fee payment submitted by a parent.
enum FeePaymentStatus { pending, verified, rejected }

extension FeePaymentStatusX on FeePaymentStatus {
  String get label {
    switch (this) {
      case FeePaymentStatus.pending:
        return 'Pending Verification';
      case FeePaymentStatus.verified:
        return 'Verified';
      case FeePaymentStatus.rejected:
        return 'Rejected';
    }
  }
}

/// School bank account details shown to the parent for making a transfer.
class SchoolAccountModel extends Equatable {
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branch;
  final String upiId;

  const SchoolAccountModel({
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branch,
    required this.upiId,
  });

  @override
  List<Object?> get props =>
      [accountName, accountNumber, ifscCode, bankName, branch, upiId];
}

/// A fee due for a student.
class FeeModel extends Equatable {
  final String id;
  final String studentId;
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;

  /// Amount already paid (verified) against this fee.
  final double paidAmount;

  const FeeModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.paidAmount = 0,
  });

  double get balance => (amount - paidAmount).clamp(0, amount);

  bool get isFullyPaid => balance <= 0;

  bool get isOverdue => !isFullyPaid && dueDate.isBefore(DateTime.now());

  FeeModel copyWith({
    String? id,
    String? studentId,
    String? title,
    String? description,
    double? amount,
    DateTime? dueDate,
    double? paidAmount,
  }) {
    return FeeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }

  @override
  List<Object?> get props =>
      [id, studentId, title, description, amount, dueDate, paidAmount];
}

/// A payment submitted by the parent, awaiting verification by the school
/// office. Screenshot of the transaction is optional but recommended.
class FeePaymentModel extends Equatable {
  final String id;
  final String feeId;
  final String studentId;
  final double amount;
  final DateTime submittedOn;
  final FeePaymentStatus status;

  /// Mock file name of the attached payment screenshot.
  final String? screenshotName;

  /// Reference / transaction id entered by the parent.
  final String? referenceNumber;

  /// Remarks added by the accountant after verification.
  final String? verificationRemarks;

  /// When the payment was verified/rejected.
  final DateTime? reviewedOn;

  const FeePaymentModel({
    required this.id,
    required this.feeId,
    required this.studentId,
    required this.amount,
    required this.submittedOn,
    this.status = FeePaymentStatus.pending,
    this.screenshotName,
    this.referenceNumber,
    this.verificationRemarks,
    this.reviewedOn,
  });

  FeePaymentModel copyWith({
    String? id,
    String? feeId,
    String? studentId,
    double? amount,
    DateTime? submittedOn,
    FeePaymentStatus? status,
    String? screenshotName,
    String? referenceNumber,
    String? verificationRemarks,
    DateTime? reviewedOn,
  }) {
    return FeePaymentModel(
      id: id ?? this.id,
      feeId: feeId ?? this.feeId,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      submittedOn: submittedOn ?? this.submittedOn,
      status: status ?? this.status,
      screenshotName: screenshotName ?? this.screenshotName,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      verificationRemarks: verificationRemarks ?? this.verificationRemarks,
      reviewedOn: reviewedOn ?? this.reviewedOn,
    );
  }

  @override
  List<Object?> get props => [
        id,
        feeId,
        studentId,
        amount,
        submittedOn,
        status,
        screenshotName,
        referenceNumber,
        verificationRemarks,
        reviewedOn,
      ];
}
