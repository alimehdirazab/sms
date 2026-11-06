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

  factory AcademicCalendarEvent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AcademicCalendarEvent(
        id: '',
        title: '',
        description: '',
        date: DateTime.now(),
        type: CalendarEventType.event,
      );
    }

    final rawType = json['type']?.toString().toLowerCase() ?? '';
    CalendarEventType eventType;
    switch (rawType) {
      case 'holiday':
        eventType = CalendarEventType.holiday;
        break;
      case 'exam':
      case 'examination':
        eventType = CalendarEventType.exam;
        break;
      case 'vacation':
        eventType = CalendarEventType.vacation;
        break;
      case 'meeting':
      case 'ptm':
        eventType = CalendarEventType.meeting;
        break;
      case 'result':
        eventType = CalendarEventType.result;
        break;
      case 'activity':
        eventType = CalendarEventType.activity;
        break;
      default:
        eventType = CalendarEventType.event;
    }

    final rawStart = json['startDate'] ?? json['date'];
    final rawEnd = json['endDate'];
    final parsedStart = rawStart != null
        ? (DateTime.tryParse(rawStart.toString()) ?? DateTime.now())
        : DateTime.now();
    final parsedEnd = rawEnd != null ? DateTime.tryParse(rawEnd.toString()) : null;

    String audienceText = 'All';
    if (json['audience'] is List) {
      audienceText = (json['audience'] as List).join(', ');
    } else if (json['audience'] != null) {
      audienceText = json['audience'].toString();
    }

    return AcademicCalendarEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: parsedStart,
      endDate: parsedEnd,
      type: eventType,
      audience: audienceText,
    );
  }

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

class AcademicCalendarSessionModel extends Equatable {
  final String id;
  final int schoolId;
  final String name;
  final String startDate;
  final String endDate;
  final String status;
  final int termsCount;
  final int eventsCount;

  const AcademicCalendarSessionModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.termsCount = 0,
    this.eventsCount = 0,
  });

  factory AcademicCalendarSessionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AcademicCalendarSessionModel(
        id: '',
        schoolId: 0,
        name: '',
        startDate: '',
        endDate: '',
        status: '',
      );
    }
    return AcademicCalendarSessionModel(
      id: json['id']?.toString() ?? '',
      schoolId: (json['schoolId'] is num) ? (json['schoolId'] as num).toInt() : 0,
      name: json['name']?.toString() ?? '',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      termsCount: (json['termsCount'] is num) ? (json['termsCount'] as num).toInt() : 0,
      eventsCount: (json['eventsCount'] is num) ? (json['eventsCount'] as num).toInt() : 0,
    );
  }

  @override
  List<Object?> get props =>
      [id, schoolId, name, startDate, endDate, status, termsCount, eventsCount];
}
