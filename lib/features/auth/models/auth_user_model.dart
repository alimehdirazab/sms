import 'package:equatable/equatable.dart';
import 'subscription_model.dart';
import '../../parent/models/parent_student_item_model.dart';

class UserModel extends Equatable {
  final dynamic id; // number or string
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? photo;
  final String status;
  final int schoolId;
  final String schoolName;
  final String? schoolLogo;
  final String role; // 'TEACHER', 'PARENT', etc.
  final int roleId;
  final SubscriptionModel? subscription;
  final List<ParentStudentItemModel> students;
  final String? activeStudentId;

  const UserModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    required this.email,
    this.phone,
    this.photo,
    this.status = 'active',
    this.schoolId = 0,
    this.schoolName = '',
    this.schoolLogo,
    required this.role,
    this.roleId = 0,
    this.subscription,
    this.students = const [],
    this.activeStudentId,
  });

  /// Computed display name from firstName and lastName (or fallback to email prefix)
  String get name {
    final full = '$firstName $lastName'.trim();
    if (full.isNotEmpty) return full;
    if (email.isNotEmpty) return email.split('@').first;
    return 'User';
  }

  /// Normalized role lowercased ('teacher', 'parent')
  String get normalizedRole => role.toLowerCase();

  /// List of student IDs for parent
  List<String> get studentIds => students.map((s) => s.studentId).toList();

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UserModel(
        id: '',
        email: '',
        role: 'PARENT',
      );
    }

    final id = json['id'] ?? json['_id'] ?? json['userId'] ?? '';
    final email = json['email']?.toString() ?? '';
    final firstName = json['firstName']?.toString() ??
        json['name']?.toString() ??
        '';
    final lastName = json['lastName']?.toString() ?? '';
    final phone = json['phone']?.toString() ?? json['phoneNumber']?.toString();
    final photo = json['photo']?.toString() ?? json['photoUrl']?.toString();
    final status = json['status']?.toString() ?? 'active';
    final schoolId = json['schoolId'] is num ? (json['schoolId'] as num).toInt() : 0;
    final schoolName = json['schoolName']?.toString() ?? '';
    final schoolLogo = json['schoolLogo']?.toString();
    final role = (json['role']?.toString() ?? json['applicantType']?.toString() ?? 'PARENT').toUpperCase();
    final roleId = json['roleId'] is num ? (json['roleId'] as num).toInt() : 0;

    SubscriptionModel? subscription;
    if (json['subscription'] is Map<String, dynamic>) {
      subscription = SubscriptionModel.fromJson(json['subscription'] as Map<String, dynamic>);
    }

    List<ParentStudentItemModel> students = [];
    if (json['students'] is List) {
      students = (json['students'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ParentStudentItemModel.fromJson(e))
          .toList();
    }

    final activeStudentId = json['activeStudentId']?.toString() ??
        (students.isNotEmpty ? students.first.studentId : null);

    return UserModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      photo: photo,
      status: status,
      schoolId: schoolId,
      schoolName: schoolName,
      schoolLogo: schoolLogo,
      role: role,
      roleId: roleId,
      subscription: subscription,
      students: students,
      activeStudentId: activeStudentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'status': status,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'schoolLogo': schoolLogo,
      'role': role,
      'roleId': roleId,
      if (subscription != null) 'subscription': subscription!.toJson(),
      'students': students.map((s) => s.toJson()).toList(),
      if (activeStudentId != null) 'activeStudentId': activeStudentId,
    };
  }

  UserModel copyWith({
    dynamic id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? photo,
    String? status,
    int? schoolId,
    String? schoolName,
    String? schoolLogo,
    String? role,
    int? roleId,
    SubscriptionModel? subscription,
    List<ParentStudentItemModel>? students,
    String? activeStudentId,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      status: status ?? this.status,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      schoolLogo: schoolLogo ?? this.schoolLogo,
      role: role ?? this.role,
      roleId: roleId ?? this.roleId,
      subscription: subscription ?? this.subscription,
      students: students ?? this.students,
      activeStudentId: activeStudentId ?? this.activeStudentId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        photo,
        status,
        schoolId,
        schoolName,
        schoolLogo,
        role,
        roleId,
        subscription,
        students,
        activeStudentId,
      ];
}
