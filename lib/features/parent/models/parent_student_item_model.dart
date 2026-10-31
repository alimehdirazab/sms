import 'package:equatable/equatable.dart';

class ParentStudentItemModel extends Equatable {
  final String studentId;
  final int schoolId;
  final String firstName;
  final String lastName;
  final String classId;
  final String sectionId;
  final String className;
  final String sectionName;

  const ParentStudentItemModel({
    required this.studentId,
    this.schoolId = 0,
    required this.firstName,
    required this.lastName,
    this.classId = '',
    this.sectionId = '',
    this.className = '',
    this.sectionName = '',
  });

  String get fullName => '$firstName $lastName'.trim();
  String get id => studentId;
  String get name => fullName.isNotEmpty ? fullName : 'Student';
  String get section => sectionName;
  String get rollNumber => sectionName.isNotEmpty ? '$className-$sectionName' : className;

  factory ParentStudentItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ParentStudentItemModel(
        studentId: '',
        firstName: '',
        lastName: '',
      );
    }
    return ParentStudentItemModel(
      studentId: json['studentId']?.toString() ?? json['id']?.toString() ?? '',
      schoolId: json['schoolId'] is num ? (json['schoolId'] as num).toInt() : 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      classId: json['classId']?.toString() ?? '',
      sectionId: json['sectionId']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      sectionName: json['sectionName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'schoolId': schoolId,
      'firstName': firstName,
      'lastName': lastName,
      'classId': classId,
      'sectionId': sectionId,
      'className': className,
      'sectionName': sectionName,
    };
  }

  @override
  List<Object?> get props => [
        studentId,
        schoolId,
        firstName,
        lastName,
        classId,
        sectionId,
        className,
        sectionName,
      ];
}
