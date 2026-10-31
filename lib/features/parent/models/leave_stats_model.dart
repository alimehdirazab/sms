import 'package:equatable/equatable.dart';

class LeaveStatsModel extends Equatable {
  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int withdrawn;
  final int leaveUsed;

  const LeaveStatsModel({
    this.total = 0,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.withdrawn = 0,
    this.leaveUsed = 0,
  });

  factory LeaveStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LeaveStatsModel();
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }
    return LeaveStatsModel(
      total: parseInt(json['total']),
      pending: parseInt(json['pending']),
      approved: parseInt(json['approved']),
      rejected: parseInt(json['rejected']),
      withdrawn: parseInt(json['withdrawn'] ?? json['withdraw']),
      leaveUsed: parseInt(json['leaveUsed'] ?? json['leaveDaysUsed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'withdrawn': withdrawn,
      'leaveUsed': leaveUsed,
    };
  }

  @override
  List<Object?> get props => [total, pending, approved, rejected, withdrawn, leaveUsed];
}
