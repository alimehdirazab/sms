import 'package:equatable/equatable.dart';

class SubscriptionModel extends Equatable {
  final String status;
  final int remainingDays;
  final String? expiryDate;
  final bool isLocked;
  final int schoolId;
  final String planName;
  final int planId;
  final String billingCycle;
  final bool autoRenewal;
  final String? startDate;
  final bool canRenew;

  const SubscriptionModel({
    this.status = 'active',
    this.remainingDays = 0,
    this.expiryDate,
    this.isLocked = false,
    this.schoolId = 0,
    this.planName = '',
    this.planId = 0,
    this.billingCycle = '',
    this.autoRenewal = false,
    this.startDate,
    this.canRenew = false,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SubscriptionModel();
    return SubscriptionModel(
      status: json['status']?.toString() ?? 'active',
      remainingDays: json['remainingDays'] is num ? (json['remainingDays'] as num).toInt() : 0,
      expiryDate: json['expiryDate']?.toString(),
      isLocked: json['isLocked'] is bool ? json['isLocked'] as bool : false,
      schoolId: json['schoolId'] is num ? (json['schoolId'] as num).toInt() : 0,
      planName: json['planName']?.toString() ?? '',
      planId: json['planId'] is num ? (json['planId'] as num).toInt() : 0,
      billingCycle: json['billingCycle']?.toString() ?? '',
      autoRenewal: json['autoRenewal'] is bool ? json['autoRenewal'] as bool : false,
      startDate: json['startDate']?.toString(),
      canRenew: json['canRenew'] is bool ? json['canRenew'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'remainingDays': remainingDays,
      if (expiryDate != null) 'expiryDate': expiryDate,
      'isLocked': isLocked,
      'schoolId': schoolId,
      'planName': planName,
      'planId': planId,
      'billingCycle': billingCycle,
      'autoRenewal': autoRenewal,
      if (startDate != null) 'startDate': startDate,
      'canRenew': canRenew,
    };
  }

  @override
  List<Object?> get props => [
        status,
        remainingDays,
        expiryDate,
        isLocked,
        schoolId,
        planName,
        planId,
        billingCycle,
        autoRenewal,
        startDate,
        canRenew,
      ];
}
