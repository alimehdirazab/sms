import '../../auth/models/user_model.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/marks_model.dart';
import '../../auth/models/notification_model.dart';
import '../../../core/utils/mock_delay.dart';

class MockParentRepository {
  Future<ParentModel> getParentProfile() async {
    await MockDelay.simulate();
    return ParentModel(
      id: 'p1',
      name: 'Mr. Amit Sharma',
      phoneNumber: '+91 9876543211',
      email: 'amit.sharma@email.com',
      children: [
        const StudentModel(
          id: 's1',
          name: 'Aarav Sharma',
          rollNumber: '10A-01',
          className: 'Class 10-A',
          section: 'A',
          rfidCardId: 'RFID1001',
        ),
        const StudentModel(
          id: 's2',
          name: 'Ananya Sharma',
          rollNumber: '7B-05',
          className: 'Class 7-B',
          section: 'B',
          rfidCardId: 'RFID1002',
        ),
      ],
    );
  }

  Future<AttendanceModel> getTodayAttendance(String studentId) async {
    await MockDelay.simulate(milliseconds: 800);
    final today = DateTime.now();
    final isPresent = studentId.hashCode % 3 != 0;
    return AttendanceModel(
      id: 'att_$studentId',
      userId: studentId,
      date: today,
      checkInTime: isPresent
          ? DateTime(today.year, today.month, today.day, 8, 30)
          : null,
      checkOutTime: isPresent
          ? DateTime(today.year, today.month, today.day, 15, 0)
          : null,
      status: isPresent
          ? AttendanceStatus.present
          : (studentId.hashCode % 5 == 0
                ? AttendanceStatus.late
                : AttendanceStatus.absent),
      isInsideGeofence: isPresent,
      faceVerified: isPresent,
    );
  }

  Future<List<AttendanceModel>> getMonthlyAttendance(
    String studentId,
    DateTime month,
  ) async {
    await MockDelay.simulate();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(daysInMonth, (index) {
      final date = DateTime(month.year, month.month, index + 1);
      final isPresent = (index + studentId.hashCode) % 5 != 0;
      return AttendanceModel(
        id: 'att_m_${studentId}_$index',
        userId: studentId,
        date: date,
        checkInTime: isPresent
            ? DateTime(date.year, date.month, date.day, 8, 30)
            : null,
        status: isPresent ? AttendanceStatus.present : AttendanceStatus.absent,
        isInsideGeofence: isPresent,
        faceVerified: isPresent,
      );
    });
  }

  Future<List<StudentMarkModel>> getStudentMarks(String studentId) async {
    await MockDelay.simulate();
    return [
      StudentMarkModel(
        id: 'pm_1',
        examId: 'e1',
        studentId: studentId,
        studentName: 'Aarav Sharma',
        rollNumber: '10A-01',
        obtainedMarks: 85,
        totalMarks: 100,
        status: MarkStatus.published,
        teacherRemarks: 'Good performance, needs improvement in algebra.',
      ),
      StudentMarkModel(
        id: 'pm_2',
        examId: 'e1',
        studentId: studentId,
        studentName: 'Aarav Sharma',
        rollNumber: '10A-01',
        obtainedMarks: 78,
        totalMarks: 100,
        status: MarkStatus.published,
        teacherRemarks: 'Satisfactory.',
      ),
      StudentMarkModel(
        id: 'pm_3',
        examId: 'e1',
        studentId: studentId,
        studentName: 'Aarav Sharma',
        rollNumber: '10A-01',
        obtainedMarks: 92,
        totalMarks: 100,
        status: MarkStatus.published,
      ),
      StudentMarkModel(
        id: 'pm_4',
        examId: 'e2',
        studentId: studentId,
        studentName: 'Aarav Sharma',
        rollNumber: '10A-01',
        obtainedMarks: 88,
        totalMarks: 100,
        status: MarkStatus.published,
        teacherRemarks: 'Excellent improvement!',
      ),
      StudentMarkModel(
        id: 'pm_5',
        examId: 'e2',
        studentId: studentId,
        studentName: 'Aarav Sharma',
        rollNumber: '10A-01',
        obtainedMarks: 82,
        totalMarks: 100,
        status: MarkStatus.published,
      ),
      StudentMarkModel(
        id: 'pm_6',
        examId: 'e2',
        studentId: studentId,
        studentName: 'Aarav Sharma',
        rollNumber: '10A-01',
        obtainedMarks: 95,
        totalMarks: 100,
        status: MarkStatus.published,
        teacherRemarks: 'Outstanding!',
      ),
    ];
  }

  Future<List<ExamModel>> getUpcomingExams(String studentId) async {
    await MockDelay.simulate(milliseconds: 800);
    final now = DateTime.now();
    return [
      ExamModel(
        id: 'ue1',
        name: 'Half-Yearly',
        className: 'Class 10-A',
        subjectId: 'math_1',
        subjectName: 'Mathematics',
        date: now.add(const Duration(days: 5)),
      ),
      ExamModel(
        id: 'ue2',
        name: 'Half-Yearly',
        className: 'Class 10-A',
        subjectId: 'phy_1',
        subjectName: 'Physics',
        date: now.add(const Duration(days: 8)),
      ),
      ExamModel(
        id: 'ue3',
        name: 'Half-Yearly',
        className: 'Class 10-A',
        subjectId: 'chem_1',
        subjectName: 'Chemistry',
        date: now.add(const Duration(days: 12)),
      ),
    ];
  }

  Future<List<NotificationModel>> getNotifications() async {
    await MockDelay.simulate();
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'n1',
        title: 'Absence Alert',
        message:
            'Your child Aarav was absent on ${now.subtract(const Duration(days: 1)).day} July.',
        date: now.subtract(const Duration(days: 1)),
        type: NotificationType.absence,
      ),
      NotificationModel(
        id: 'n2',
        title: 'Result Declared',
        message:
            'Mid-Term results have been published. Check the Marks section.',
        date: now.subtract(const Duration(days: 2)),
        type: NotificationType.resultDeclared,
      ),
      NotificationModel(
        id: 'n3',
        title: 'Fee Due Reminder',
        message: '₹5000 due by 25 July 2026. Please pay before the due date.',
        date: now.subtract(const Duration(days: 3)),
        type: NotificationType.feeDue,
      ),
      NotificationModel(
        id: 'n4',
        title: 'PTM Scheduled',
        message: 'Parent-Teacher Meeting on 15 July 2026 at 10:00 AM.',
        date: now.subtract(const Duration(days: 4)),
        type: NotificationType.ptm,
      ),
      NotificationModel(
        id: 'n5',
        title: 'Annual Day',
        message:
            'Annual Day celebration on 20 August 2026. All parents are invited.',
        date: now.subtract(const Duration(days: 5)),
        type: NotificationType.event,
      ),
      NotificationModel(
        id: 'n6',
        title: 'Attendance Update',
        message: 'Your child has maintained 95% attendance this month.',
        date: now.subtract(const Duration(days: 6)),
        type: NotificationType.announcement,
      ),
    ];
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    await MockDelay.simulate();
    return true;
  }
}
