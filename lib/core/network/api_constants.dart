class ApiConstants {
  ApiConstants._();

  /// Nexira Production Base URL
  static const String defaultBaseUrl = 'https://api.nexira.pk/api';

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

  // Parent exams
  static const String parentExams = '/parent/exams';

  // Academic calendar & sessions
  static const String academicCalendarEvents = '/academic-calendar/events';
  static String academicCalendarEventDetails(String eventId) =>
      '/academic-calendar/events/$eventId';
  static const String academicCalendarSessions = '/academic-calendar/sessions';

  // Timetable
  static const String timetable = '/timetable/';
  static const String timetableConfig = '/timetable-config';
  static const String timetableExportPdf = '/timetable/export/pdf';
  static const String timetableToday = '/teacher/timetable/today';

  // Teacher Tests & Marks
  static const String teacherTests = '/teacher/tests';
  static String teacherTestMarksDraft(String testId) =>
      '/teacher/marks/tests/$testId';
  static String teacherTestMarksSubmit(String testId) =>
      '/teacher/marks/tests/$testId/submit';

  // User Profile
  static String user(dynamic id) => '/users/$id';

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
}
