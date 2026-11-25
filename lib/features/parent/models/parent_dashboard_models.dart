import 'package:equatable/equatable.dart';

class StudentAttendanceDashboardModel extends Equatable {
  final String studentId;
  final String studentName;
  final String className;
  final String sectionName;
  final String date;
  final String status;
  final String? checkIn;
  final int daysPresent;
  final num overallRate;

  const StudentAttendanceDashboardModel({
    required this.studentId,
    this.studentName = '',
    this.className = '',
    this.sectionName = '',
    this.date = '',
    this.status = 'Not Marked',
    this.checkIn,
    this.daysPresent = 0,
    this.overallRate = 0,
  });

  factory StudentAttendanceDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StudentAttendanceDashboardModel(studentId: '');
    return StudentAttendanceDashboardModel(
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      sectionName: json['sectionName']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Not Marked',
      checkIn: json['checkIn']?.toString(),
      daysPresent: json['daysPresent'] is int
          ? json['daysPresent'] as int
          : int.tryParse(json['daysPresent']?.toString() ?? '0') ?? 0,
      overallRate: json['overallRate'] is num
          ? json['overallRate'] as num
          : num.tryParse(json['overallRate']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        studentId,
        studentName,
        className,
        sectionName,
        date,
        status,
        checkIn,
        daysPresent,
        overallRate,
      ];
}

class UpcomingExamDashboardModel extends Equatable {
  final String id;
  final String title;
  final String examType;
  final String subjectName;
  final String examDate;
  final String? timing;
  final num totalMarks;
  final num passingMarks;

  const UpcomingExamDashboardModel({
    required this.id,
    this.title = '',
    this.examType = '',
    this.subjectName = '',
    this.examDate = '',
    this.timing,
    this.totalMarks = 100,
    this.passingMarks = 40,
  });

  factory UpcomingExamDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpcomingExamDashboardModel(id: '');
    return UpcomingExamDashboardModel(
      id: json['examId']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      examType: json['examType']?.toString() ?? json['type']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      examDate: json['examDate']?.toString() ?? '',
      timing: json['timing']?.toString(),
      totalMarks: json['totalMarks'] is num
          ? json['totalMarks'] as num
          : num.tryParse(json['totalMarks']?.toString() ?? '100') ?? 100,
      passingMarks: json['passingMarks'] is num
          ? json['passingMarks'] as num
          : num.tryParse(json['passingMarks']?.toString() ?? '40') ?? 40,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        examType,
        subjectName,
        examDate,
        timing,
        totalMarks,
        passingMarks,
      ];
}
