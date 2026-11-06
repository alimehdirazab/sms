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

  // Parent fees & bank details
  static const String bankDetails = '/school/bank-details';
  static const String parentFees = '/parent/fees';
  static const String submitFeePayment = '/parent/fees/submit-payment';

  // Academic calendar
  static const String academicCalendarEvents = '/academic-calendar/events';
  static String academicCalendarEventDetails(String eventId) =>
      '/academic-calendar/events/$eventId';
  static const String academicCalendarSessions = '/academic-calendar/sessions';

  // Notifications & FCM
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/mark-all-read';
  static const String notificationFcmToken = '/notifications/fcm-token';
  static const String notificationBroadcast = '/notifications/broadcast';

  // Announcements (Teacher & Parent)
  static const String announcements = '/announcements';

  // Attendance endpoints (Teacher)
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceCheckOut = '/attendance/check-out';
  static const String attendanceRecent = '/attendance/recent';
  static const String attendanceMyHistory = '/attendance/my-attendance';

  // Timetable endpoints (Teacher)
  static const String timetableToday = '/teacher/timetable/today';
}
