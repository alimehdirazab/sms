import 'package:equatable/equatable.dart';

class LeaveApplicantModel extends Equatable {
  final String applicantId;
  final String applicantName;
  final String applicantType; // 'STUDENT' or 'TEACHER'
  final String roleOrClass;

  const LeaveApplicantModel({
    required this.applicantId,
    required this.applicantName,
    required this.applicantType,
    required this.roleOrClass,
  });

  factory LeaveApplicantModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LeaveApplicantModel(
        applicantId: '',
        applicantName: '',
        applicantType: '',
        roleOrClass: '',
      );
    }
    return LeaveApplicantModel(
      applicantId: json['applicantId']?.toString() ?? '',
      applicantName: json['applicantName']?.toString() ?? '',
      applicantType: json['applicantType']?.toString() ?? '',
      roleOrClass: json['roleOrClass']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantType': applicantType,
      'roleOrClass': roleOrClass,
    };
  }

  @override
  List<Object?> get props => [applicantId, applicantName, applicantType, roleOrClass];
}
