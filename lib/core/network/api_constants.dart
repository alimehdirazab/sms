class ApiConstants {
  ApiConstants._();

  /// Default local development base URL from Postman collection
  /// For Android emulator, developers can use 'http://10.0.2.2:4000/api'
  static const String defaultBaseUrl =
      'https://school-erp-backend-production-7992.up.railway.app/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  // Leaves endpoints
  static const String leaves = '/leaves';
  static String leaveDetails(String leaveId) => '/leaves/$leaveId';
  static String updateLeaveStatus(String leaveId) => '/leaves/$leaveId/status';
  static String deleteLeave(String leaveId) => '/leaves/$leaveId';

  // Parent student switch
  static const String switchStudent = '/parent/switch-student';

  // Attendance endpoints (Teacher)
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceCheckOut = '/attendance/check-out';
  static const String attendanceRecent = '/attendance/recent';
  static const String attendanceMyHistory = '/attendance/my-attendance';

  // Timetable endpoints (Teacher)
  static const String timetableToday = '/teacher/timetable/today';
}
