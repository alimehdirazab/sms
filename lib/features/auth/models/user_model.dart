import 'package:equatable/equatable.dart';

enum UserRole { parent, teacher }

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? photoUrl;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, photoUrl, role];
}

class TeacherModel extends UserModel {
  final String employeeId;
  final String department;
  final List<String> assignedClasses;
  final bool canPublishMarks;
  final String? phoneNumber;
  final String? email;

  const TeacherModel({
    required super.id,
    required super.name,
    required this.employeeId,
    required this.department,
    required this.assignedClasses,
    this.canPublishMarks = false,
    this.phoneNumber,
    this.email,
    super.photoUrl,
  }) : super(role: UserRole.teacher);

  @override
  List<Object?> get props => [
        ...super.props,
        employeeId,
        department,
        assignedClasses,
        canPublishMarks,
        phoneNumber,
        email,
      ];

  TeacherModel copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? employeeId,
    String? department,
    List<String>? assignedClasses,
    bool? canPublishMarks,
    String? phoneNumber,
    String? email,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      canPublishMarks: canPublishMarks ?? this.canPublishMarks,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

class ParentModel extends UserModel {
  final List<StudentModel> children;
  final String? phoneNumber;
  final String? email;

  const ParentModel({
    required super.id,
    required super.name,
    required this.children,
    this.phoneNumber,
    this.email,
    super.photoUrl,
  }) : super(role: UserRole.parent);

  @override
  List<Object?> get props => [
        ...super.props,
        children,
        phoneNumber,
        email,
      ];

  ParentModel copyWith({
    String? id,
    String? name,
    String? photoUrl,
    List<StudentModel>? children,
    String? phoneNumber,
    String? email,
  }) {
    return ParentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      children: children ?? this.children,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

class StudentModel extends Equatable {
  final String id;
  final String name;
  final String rollNumber;
  final String className;
  final String section;
  final String? photoUrl;
  final String? rfidCardId;

  const StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.section,
    this.photoUrl,
    this.rfidCardId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        rollNumber,
        className,
        section,
        photoUrl,
        rfidCardId,
      ];

  StudentModel copyWith({
    String? id,
    String? name,
    String? rollNumber,
    String? className,
    String? section,
    String? photoUrl,
    String? rfidCardId,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      className: className ?? this.className,
      section: section ?? this.section,
      photoUrl: photoUrl ?? this.photoUrl,
      rfidCardId: rfidCardId ?? this.rfidCardId,
    );
  }
}
