import 'package:equatable/equatable.dart';

/// Category of a calendar entry, used to colour-code the academic calendar.
enum CalendarEventType {
  holiday,
  exam,
  event,
  meeting,
  result,
  vacation,
  activity,
}

extension CalendarEventTypeX on CalendarEventType {
  String get label {
    switch (this) {
      case CalendarEventType.holiday:
        return 'Holiday';
      case CalendarEventType.exam:
        return 'Exam';
      case CalendarEventType.event:
        return 'Event';
      case CalendarEventType.meeting:
        return 'Meeting';
      case CalendarEventType.result:
        return 'Result';
      case CalendarEventType.vacation:
        return 'Vacation';
      case CalendarEventType.activity:
        return 'Activity';
    }
  }
}

/// A single entry on the academic calendar (holiday, exam, PTM, event...).
class AcademicCalendarEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  /// Multi-day events (e.g. vacations) set this to a date after [date].
  final DateTime? endDate;

  final CalendarEventType type;

  /// Optional audience hint, e.g. 'All', 'Parents', 'Teachers'.
  final String audience;

  const AcademicCalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.endDate,
    required this.type,
    this.audience = 'All',
  });

  bool get isMultiDay => endDate != null && endDate!.isAfter(date);

  /// True when this event starts on or after [day] (ignoring the time).
  bool startsOnOrAfter(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final start = DateTime(date.year, date.month, date.day);
    return !start.isBefore(d);
  }

  bool occursOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final start = DateTime(date.year, date.month, date.day);
    if (d.isBefore(start)) return false;
    if (endDate == null) return d == start;
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return !d.isAfter(end);
  }

  int get spanDays =>
      endDate == null ? 1 : endDate!.difference(date).inDays + 1;

  @override
  List<Object?> get props =>
      [id, title, description, date, endDate, type, audience];
}
