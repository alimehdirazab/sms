import 'package:equatable/equatable.dart';

class TimetablePeriodModel extends Equatable {
  final String id;
  final int period;
  final String periodLabel;
  final String status;
  final String subjectName;
  final String timeRange;
  final String startTime;
  final String endTime;
  final String className;
  final String roomName;

  const TimetablePeriodModel({
    required this.id,
    this.period = 0,
    this.periodLabel = '',
    this.status = '',
    this.subjectName = '',
    this.timeRange = '',
    this.startTime = '',
    this.endTime = '',
    this.className = '',
    this.roomName = '',
  });

  factory TimetablePeriodModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TimetablePeriodModel(id: '');
    return TimetablePeriodModel(
      id: json['id']?.toString() ?? '',
      period: json['period'] is num ? (json['period'] as num).toInt() : 0,
      periodLabel: json['periodLabel']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      timeRange: json['timeRange']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      roomName: json['roomName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'periodLabel': periodLabel,
      'status': status,
      'subjectName': subjectName,
      'timeRange': timeRange,
      'startTime': startTime,
      'endTime': endTime,
      'className': className,
      'roomName': roomName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        period,
        periodLabel,
        status,
        subjectName,
        timeRange,
        startTime,
        endTime,
        className,
        roomName,
      ];
}

class TodayTimetableModel extends Equatable {
  final String day;
  final String date;
  final List<TimetablePeriodModel> classes;

  const TodayTimetableModel({
    this.day = '',
    this.date = '',
    this.classes = const [],
  });

  factory TodayTimetableModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TodayTimetableModel();

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final day = data['day']?.toString() ?? '';
    final date = data['date']?.toString() ?? '';

    List<TimetablePeriodModel> classes = [];
    if (data['classes'] is List) {
      classes = (data['classes'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => TimetablePeriodModel.fromJson(e))
          .toList();
    }

    return TodayTimetableModel(
      day: day,
      date: date,
      classes: classes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'classes': classes.map((c) => c.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [day, date, classes];
}
