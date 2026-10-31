enum TeacherAttendanceStatus {
  present,
  absent,
  late,
  weekend,
  halfDay,
  onLeave,
  unknown;

  static TeacherAttendanceStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'PRESENT':
        return TeacherAttendanceStatus.present;
      case 'ABSENT':
        return TeacherAttendanceStatus.absent;
      case 'LATE':
        return TeacherAttendanceStatus.late;
      case 'WEEKEND':
        return TeacherAttendanceStatus.weekend;
      case 'HALF_DAY':
      case 'HALFDAY':
        return TeacherAttendanceStatus.halfDay;
      case 'ON_LEAVE':
      case 'ONLEAVE':
      case 'LEAVE':
        return TeacherAttendanceStatus.onLeave;
      default:
        return TeacherAttendanceStatus.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case TeacherAttendanceStatus.present:
        return 'Present';
      case TeacherAttendanceStatus.absent:
        return 'Absent';
      case TeacherAttendanceStatus.late:
        return 'Late';
      case TeacherAttendanceStatus.weekend:
        return 'Weekend';
      case TeacherAttendanceStatus.halfDay:
        return 'Half Day';
      case TeacherAttendanceStatus.onLeave:
        return 'On Leave';
      case TeacherAttendanceStatus.unknown:
        return 'Unknown';
    }
  }
}