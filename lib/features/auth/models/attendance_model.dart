import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late }

class AttendanceModel extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final bool isInsideGeofence;
  final bool faceVerified;

  const AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.isInsideGeofence = true,
    this.faceVerified = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        checkInTime,
        checkOutTime,
        status,
        isInsideGeofence,
        faceVerified,
      ];

  AttendanceModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    AttendanceStatus? status,
    bool? isInsideGeofence,
    bool? faceVerified,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      isInsideGeofence: isInsideGeofence ?? this.isInsideGeofence,
      faceVerified: faceVerified ?? this.faceVerified,
    );
  }
}
