import 'package:equatable/equatable.dart';

class TimetableItemModel extends Equatable {
  final String id;
  final String academicYear;
  final String classId;
  final String className;
  final String sectionId;
  final String sectionName;
  final String courseId;
  final String courseName;
  final String courseCode;
  final String subjectName;
  final dynamic teacherId;
  final String teacherName;
  final String day;
  final String startTime;
  final String endTime;
  final String roomId;
  final String roomName;
  final String status;

  const TimetableItemModel({
    required this.id,
    this.academicYear = '',
    this.classId = '',
    this.className = '',
    this.sectionId = '',
    this.sectionName = '',
    this.courseId = '',
    this.courseName = '',
    this.courseCode = '',
    this.subjectName = '',
    this.teacherId,
    this.teacherName = '',
    this.day = '',
    this.startTime = '',
    this.endTime = '',
    this.roomId = '',
    this.roomName = '',
    this.status = '',
  });

  String get timeRange => '$startTime - $endTime';

  factory TimetableItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TimetableItemModel(id: '');
    return TimetableItemModel(
      id: json['id']?.toString() ?? '',
      academicYear: json['academicYear']?.toString() ?? '',
      classId: json['classId']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      sectionId: json['sectionId']?.toString() ?? '',
      sectionName: json['sectionName']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      courseCode: json['courseCode']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      teacherId: json['teacherId'],
      teacherName: json['teacherName']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      roomName: json['roomName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academicYear': academicYear,
      'classId': classId,
      'className': className,
      'sectionId': sectionId,
      'sectionName': sectionName,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'subjectName': subjectName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'roomId': roomId,
      'roomName': roomName,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        id,
        academicYear,
        classId,
        className,
        sectionId,
        sectionName,
        courseId,
        courseName,
        courseCode,
        subjectName,
        teacherId,
        teacherName,
        day,
        startTime,
        endTime,
        roomId,
        roomName,
        status,
      ];
}
