import 'package:equatable/equatable.dart';

enum MarkStatus { draft, published }

String calculateGrade(double percentage) {
  if (percentage >= 90) return 'A+';
  if (percentage >= 80) return 'A';
  if (percentage >= 70) return 'B+';
  if (percentage >= 60) return 'B';
  if (percentage >= 50) return 'C';
  if (percentage >= 40) return 'D';
  return 'F';
}

class ExamModel extends Equatable {
  final String id;
  final String name;
  final String className;
  final String subjectId;
  final String subjectName;
  final DateTime date;
  final MarkStatus status;

  const ExamModel({
    required this.id,
    required this.name,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    this.status = MarkStatus.draft,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    className,
    subjectId,
    subjectName,
    date,
    status,
  ];
}

class StudentMarkModel extends Equatable {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String? studentPhotoUrl;
  final double obtainedMarks;
  final double totalMarks;
  final MarkStatus status;
  final String? teacherRemarks;

  const StudentMarkModel({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    this.studentPhotoUrl,
    required this.obtainedMarks,
    required this.totalMarks,
    this.status = MarkStatus.draft,
    this.teacherRemarks,
  });

  double get percentage =>
      totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;
  String get grade => calculateGrade(percentage);

  @override
  List<Object?> get props => [
    id,
    examId,
    studentId,
    studentName,
    rollNumber,
    studentPhotoUrl,
    obtainedMarks,
    totalMarks,
    status,
    teacherRemarks,
  ];

  StudentMarkModel copyWith({
    String? id,
    String? examId,
    String? studentId,
    String? studentName,
    String? rollNumber,
    String? studentPhotoUrl,
    double? obtainedMarks,
    double? totalMarks,
    MarkStatus? status,
    String? teacherRemarks,
  }) {
    return StudentMarkModel(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      studentPhotoUrl: studentPhotoUrl ?? this.studentPhotoUrl,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      status: status ?? this.status,
      teacherRemarks: teacherRemarks ?? this.teacherRemarks,
    );
  }
}
