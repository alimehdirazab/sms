import 'package:equatable/equatable.dart';

class AttendanceSummaryModel extends Equatable {
  final double attendanceRate;
  final double punctualityRate;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final int totalWorkingDays;
  final int windowDays;
  final String? windowStartDate;
  final String? windowEndDate;

  const AttendanceSummaryModel({
    this.attendanceRate = 0.0,
    this.punctualityRate = 0.0,
    this.presentDays = 0,
    this.lateDays = 0,
    this.absentDays = 0,
    this.totalWorkingDays = 0,
    this.windowDays = 0,
    this.windowStartDate,
    this.windowEndDate,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AttendanceSummaryModel();

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return AttendanceSummaryModel(
      attendanceRate: parseDouble(json['attendanceRate']),
      punctualityRate: parseDouble(json['punctualityRate']),
      presentDays: parseInt(json['presentDays']),
      lateDays: parseInt(json['lateDays']),
      absentDays: parseInt(json['absentDays']),
      totalWorkingDays: parseInt(json['totalWorkingDays']),
      windowDays: parseInt(json['windowDays']),
      windowStartDate: json['windowStartDate']?.toString(),
      windowEndDate: json['windowEndDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceRate': attendanceRate,
      'punctualityRate': punctualityRate,
      'presentDays': presentDays,
      'lateDays': lateDays,
      'absentDays': absentDays,
      'totalWorkingDays': totalWorkingDays,
      'windowDays': windowDays,
      if (windowStartDate != null) 'windowStartDate': windowStartDate,
      if (windowEndDate != null) 'windowEndDate': windowEndDate,
    };
  }

  @override
  List<Object?> get props => [
        attendanceRate,
        punctualityRate,
        presentDays,
        lateDays,
        absentDays,
        totalWorkingDays,
        windowDays,
        windowStartDate,
        windowEndDate,
      ];
}
