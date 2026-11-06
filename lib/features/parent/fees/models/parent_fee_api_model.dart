import 'package:equatable/equatable.dart';
import '../../../auth/models/fee_model.dart';

/// Full response wrapper for GET /parent/fees?studentId=...
class ParentFeeResponseModel extends Equatable {
  final bool success;
  final String message;
  final ParentFeeDataModel? data;

  const ParentFeeResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ParentFeeResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ParentFeeResponseModel(
        success: false,
        message: 'Empty response',
      );
    }
    return ParentFeeResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ParentFeeDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

class ParentFeeDataModel extends Equatable {
  final FeeStudentInfoModel student;
  final SchoolBankDetailsModel bankDetails;
  final List<ApplicableFeeItemModel> applicableFees;
  final FeeSummaryModel summary;
  final String paymentStatus;
  final LatestPaymentSubmissionModel? latestPaymentSubmission;

  const ParentFeeDataModel({
    required this.student,
    required this.bankDetails,
    required this.applicableFees,
    required this.summary,
    required this.paymentStatus,
    this.latestPaymentSubmission,
  });

  factory ParentFeeDataModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ParentFeeDataModel(
        student: FeeStudentInfoModel.fromJson(null),
        bankDetails: SchoolBankDetailsModel.fromJson(null),
        applicableFees: const [],
        summary: FeeSummaryModel.fromJson(null),
        paymentStatus: 'UNKNOWN',
      );
    }

    final feesList = <ApplicableFeeItemModel>[];
    if (json['applicableFees'] is List) {
      for (final item in json['applicableFees']) {
        if (item is Map<String, dynamic>) {
          feesList.add(ApplicableFeeItemModel.fromJson(item));
        }
      }
    }

    return ParentFeeDataModel(
      student: FeeStudentInfoModel.fromJson(
        json['student'] is Map<String, dynamic>
            ? json['student'] as Map<String, dynamic>
            : null,
      ),
      bankDetails: SchoolBankDetailsModel.fromJson(
        json['bankDetails'] is Map<String, dynamic>
            ? json['bankDetails'] as Map<String, dynamic>
            : null,
      ),
      applicableFees: feesList,
      summary: FeeSummaryModel.fromJson(
        json['summary'] is Map<String, dynamic>
            ? json['summary'] as Map<String, dynamic>
            : null,
      ),
      paymentStatus: json['paymentStatus']?.toString() ?? 'UNKNOWN',
      latestPaymentSubmission: json['latestPaymentSubmission'] is Map<String, dynamic>
          ? LatestPaymentSubmissionModel.fromJson(
              json['latestPaymentSubmission'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts applicable fees to list of domain [FeeModel]s
  List<FeeModel> toDomainFees() {
    return applicableFees.map((f) {
      final isPaid = f.status.toUpperCase() == 'PAID';
      return FeeModel(
        id: f.id,
        studentId: student.id,
        title: f.name,
        description: f.description.isNotEmpty
            ? f.description
            : '${f.category} (${f.academicYear})',
        amount: f.amount,
        dueDate: DateTime.tryParse(f.dueDate) ?? DateTime.now(),
        paidAmount: isPaid ? f.amount : 0,
      );
    }).toList();
  }

  /// Converts bank details to domain [SchoolAccountModel]
  SchoolAccountModel toDomainAccount() {
    return SchoolAccountModel(
      accountName: bankDetails.accountName,
      accountNumber: bankDetails.accountNumber,
      ifscCode: bankDetails.ibanNo,
      bankName: bankDetails.bankName,
      branch: 'Main Branch',
      upiId: bankDetails.ibanNo,
    );
  }

  /// Converts latest payment submission to domain [FeePaymentModel] list
  List<FeePaymentModel> toDomainPayments() {
    if (latestPaymentSubmission == null) return const [];
    final sub = latestPaymentSubmission!;
    FeePaymentStatus pStatus = FeePaymentStatus.pending;
    if (sub.status.toUpperCase() == 'APPROVED' ||
        sub.status.toUpperCase() == 'VERIFIED') {
      pStatus = FeePaymentStatus.verified;
    } else if (sub.status.toUpperCase() == 'REJECTED') {
      pStatus = FeePaymentStatus.rejected;
    }

    return [
      FeePaymentModel(
        id: sub.id,
        feeId: sub.invoiceNumber,
        studentId: student.id,
        amount: sub.amount,
        submittedOn: DateTime.tryParse(sub.submittedAt) ?? DateTime.now(),
        status: pStatus,
        referenceNumber: sub.transactionId,
        screenshotName: sub.receiptUrl,
        verificationRemarks: sub.rejectionReason ?? sub.notes,
        reviewedOn: sub.verifiedAt != null
            ? DateTime.tryParse(sub.verifiedAt!)
            : null,
      )
    ];
  }

  @override
  List<Object?> get props => [
        student,
        bankDetails,
        applicableFees,
        summary,
        paymentStatus,
        latestPaymentSubmission,
      ];
}

class FeeStudentInfoModel extends Equatable {
  final String id;
  final String name;
  final String className;
  final String sectionName;
  final String classId;
  final String sectionId;

  const FeeStudentInfoModel({
    required this.id,
    required this.name,
    required this.className,
    required this.sectionName,
    required this.classId,
    required this.sectionId,
  });

  factory FeeStudentInfoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FeeStudentInfoModel(
        id: '',
        name: 'Student',
        className: '',
        sectionName: '',
        classId: '',
        sectionId: '',
      );
    }
    return FeeStudentInfoModel(
      id: json['id']?.toString() ?? json['studentId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      sectionName: json['sectionName']?.toString() ?? '',
      classId: json['classId']?.toString() ?? '',
      sectionId: json['sectionId']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, className, sectionName, classId, sectionId];
}

class SchoolBankDetailsModel extends Equatable {
  final int schoolId;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ibanNo;
  final String? updatedAt;

  const SchoolBankDetailsModel({
    required this.schoolId,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ibanNo,
    this.updatedAt,
  });

  factory SchoolBankDetailsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SchoolBankDetailsModel(
        schoolId: 0,
        bankName: '',
        accountName: '',
        accountNumber: '',
        ibanNo: '',
      );
    }
    return SchoolBankDetailsModel(
      schoolId: (json['schoolId'] is num) ? (json['schoolId'] as num).toInt() : 0,
      bankName: json['bankName']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ibanNo: json['ibanNo']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  @override
  List<Object?> get props =>
      [schoolId, bankName, accountName, accountNumber, ibanNo, updatedAt];
}

class ApplicableFeeItemModel extends Equatable {
  final String id;
  final String name;
  final String code;
  final double amount;
  final String category;
  final int dueDays;
  final String dueDate;
  final String description;
  final String academicYear;
  final String status;

  const ApplicableFeeItemModel({
    required this.id,
    required this.name,
    required this.code,
    required this.amount,
    required this.category,
    required this.dueDays,
    required this.dueDate,
    required this.description,
    required this.academicYear,
    required this.status,
  });

  factory ApplicableFeeItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ApplicableFeeItemModel(
        id: '',
        name: '',
        code: '',
        amount: 0,
        category: '',
        dueDays: 0,
        dueDate: '',
        description: '',
        academicYear: '',
        status: '',
      );
    }
    return ApplicableFeeItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      category: json['category']?.toString() ?? '',
      dueDays: (json['dueDays'] is num) ? (json['dueDays'] as num).toInt() : 0,
      dueDate: json['dueDate']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      academicYear: json['academicYear']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        amount,
        category,
        dueDays,
        dueDate,
        description,
        academicYear,
        status,
      ];
}

class FeeSummaryModel extends Equatable {
  final double currentMonthFee;
  final double totalMonthly;
  final double totalTerm;
  final double totalOneTime;
  final double previousArrears;
  final int unpaidMonthsCount;
  final double grandTotal;
  final String overallDueDate;
  final String dueStatus;

  const FeeSummaryModel({
    required this.currentMonthFee,
    required this.totalMonthly,
    required this.totalTerm,
    required this.totalOneTime,
    required this.previousArrears,
    required this.unpaidMonthsCount,
    required this.grandTotal,
    required this.overallDueDate,
    required this.dueStatus,
  });

  factory FeeSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FeeSummaryModel(
        currentMonthFee: 0,
        totalMonthly: 0,
        totalTerm: 0,
        totalOneTime: 0,
        previousArrears: 0,
        unpaidMonthsCount: 0,
        grandTotal: 0,
        overallDueDate: '',
        dueStatus: 'UNKNOWN',
      );
    }
    return FeeSummaryModel(
      currentMonthFee: (json['currentMonthFee'] is num)
          ? (json['currentMonthFee'] as num).toDouble()
          : 0.0,
      totalMonthly: (json['totalMonthly'] is num)
          ? (json['totalMonthly'] as num).toDouble()
          : 0.0,
      totalTerm: (json['totalTerm'] is num)
          ? (json['totalTerm'] as num).toDouble()
          : 0.0,
      totalOneTime: (json['totalOneTime'] is num)
          ? (json['totalOneTime'] as num).toDouble()
          : 0.0,
      previousArrears: (json['previousArrears'] is num)
          ? (json['previousArrears'] as num).toDouble()
          : 0.0,
      unpaidMonthsCount: (json['unpaidMonthsCount'] is num)
          ? (json['unpaidMonthsCount'] as num).toInt()
          : 0,
      grandTotal: (json['grandTotal'] is num)
          ? (json['grandTotal'] as num).toDouble()
          : 0.0,
      overallDueDate: json['overallDueDate']?.toString() ?? '',
      dueStatus: json['dueStatus']?.toString() ?? 'UNKNOWN',
    );
  }

  @override
  List<Object?> get props => [
        currentMonthFee,
        totalMonthly,
        totalTerm,
        totalOneTime,
        previousArrears,
        unpaidMonthsCount,
        grandTotal,
        overallDueDate,
        dueStatus,
      ];
}

class LatestPaymentSubmissionModel extends Equatable {
  final String id;
  final String invoiceNumber;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final String? receiptUrl;
  final String status;
  final String submittedAt;
  final String? verifiedAt;
  final String? rejectionReason;
  final String? notes;

  const LatestPaymentSubmissionModel({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    this.receiptUrl,
    required this.status,
    required this.submittedAt,
    this.verifiedAt,
    this.rejectionReason,
    this.notes,
  });

  factory LatestPaymentSubmissionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LatestPaymentSubmissionModel(
        id: '',
        invoiceNumber: '',
        amount: 0,
        paymentMethod: '',
        transactionId: '',
        status: 'PENDING',
        submittedAt: '',
      );
    }
    return LatestPaymentSubmissionModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      transactionId: json['transactionId']?.toString() ?? '',
      receiptUrl: json['receiptUrl']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      submittedAt: json['submittedAt']?.toString() ?? '',
      verifiedAt: json['verifiedAt']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        amount,
        paymentMethod,
        transactionId,
        receiptUrl,
        status,
        submittedAt,
        verifiedAt,
        rejectionReason,
        notes,
      ];
}

