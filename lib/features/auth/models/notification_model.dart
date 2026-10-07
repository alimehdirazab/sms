import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final NotificationType type;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, title, message, date, type, isRead];

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? date,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  absence,
  resultDeclared,
  event,
  announcement,
  feeDue,
  ptm,
}

class ScheduleModel extends Equatable {
  final String id;
  final String subject;
  final String className;
  final String section;
  final DateTime startTime;
  final DateTime endTime;

  const ScheduleModel({
    required this.id,
    required this.subject,
    required this.className,
    required this.section,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [id, subject, className, section, startTime, endTime];
}
