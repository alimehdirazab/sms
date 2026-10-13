import '../../auth/models/user_model.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/marks_model.dart';
import '../../auth/models/notification_model.dart';
import '../../auth/models/leave_model.dart';
import '../../auth/models/fee_model.dart';
import '../../auth/models/academic_calendar_model.dart';
import '../../../core/utils/mock_delay.dart';

/// Aggregated analytics for a single student, computed from attendance + marks
/// so the dashboard can render charts without extra round-trips.
class StudentAnalytics {
  final double attendancePercentage;
  final int attendancePresent;
  final int attendanceTotal;
  final double averagePercentage;
  final String overallGrade;
  final List<String> examLabels;
  final List<double> examPercentages;

  const StudentAnalytics({
    required this.attendancePercentage,
    required this.attendancePresent,
    required this.attendanceTotal,
    required this.averagePercentage,
    required this.overallGrade,
    required this.examLabels,
    required this.examPercentages,
  });
}

class MockParentRepository {
  /// In-memory store so newly submitted leave applications and fee payments
  /// remain visible for the duration of the session.
  final List<LeaveApplicationModel> _leaveStore = [];
  final List<FeePaymentModel> _paymentStore = [];
  Future<ParentModel> getParentProfile() async {
    await MockDelay.simulate();
    return const ParentModel(
      id: 'p1',
      name: 'Mr. Amit Sharma',
      phoneNumber: '+91 9876543211',
      email: 'amit.sharma@email.com',
      children: [
        StudentModel(
          id: 's1',
          name: 'Aarav Sharma',
          rollNumber: '10A-01',
          className: 'Class 10-A',
          section: 'A',
          rfidCardId: 'RFID1001',
        ),
        StudentModel(
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

  // ───────────────────────────── LEAVE ─────────────────────────────

  /// Seed data returned the first time leave history is requested.
  List<LeaveApplicationModel> _seedLeaves() {
    final now = DateTime.now();
    return [
      LeaveApplicationModel(
        id: 'lv_seed_1',
        applicantId: 's1',
        applicantName: 'Aarav Sharma',
        className: 'Class 10-A',
        applicantType: LeaveApplicant.parent,
        type: LeaveType.sick,
        fromDate: now.subtract(const Duration(days: 12)),
        toDate: now.subtract(const Duration(days: 11)),
        reason: 'Viral fever, advised rest by doctor.',
        status: LeaveStatus.approved,
        principalRemarks: 'Approved. Get well soon.',
        appliedOn: now.subtract(const Duration(days: 13)),
      ),
      LeaveApplicationModel(
        id: 'lv_seed_2',
        applicantId: 's1',
        applicantName: 'Aarav Sharma',
        className: 'Class 10-A',
        applicantType: LeaveApplicant.parent,
        type: LeaveType.familyFunction,
        fromDate: now.add(const Duration(days: 6)),
        toDate: now.add(const Duration(days: 7)),
        reason: 'Cousin\'s wedding out of station.',
        status: LeaveStatus.pending,
        appliedOn: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<List<LeaveApplicationModel>> getLeaveApplications(
    String studentId,
  ) async {
    await MockDelay.simulate(milliseconds: 900);
    if (_leaveStore.isEmpty) {
      _leaveStore.addAll(_seedLeaves());
    }
    return _leaveStore
        .where((l) => l.applicantId == studentId)
        .toList()
      ..sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
  }

  Future<LeaveApplicationModel> submitLeaveApplication(
    LeaveApplicationModel application,
  ) async {
    await MockDelay.simulate();
    final saved = application.copyWith(
      id: 'lv_${DateTime.now().millisecondsSinceEpoch}',
      status: LeaveStatus.pending,
      appliedOn: DateTime.now(),
    );
    if (_leaveStore.isEmpty) {
      _leaveStore.addAll(_seedLeaves());
    }
    _leaveStore.insert(0, saved);
    return saved;
  }

  Future<bool> cancelLeaveApplication(String leaveId) async {
    await MockDelay.simulate(milliseconds: 600);
    final index = _leaveStore.indexWhere((l) => l.id == leaveId);
    if (index == -1) return false;
    _leaveStore[index] =
        _leaveStore[index].copyWith(status: LeaveStatus.cancelled);
    return true;
  }

  // ────────────────────────────── FEES ──────────────────────────────

  SchoolAccountModel getSchoolAccount() {
    return const SchoolAccountModel(
      accountName: 'Bright Future Public School',
      accountNumber: '50100234567890',
      ifscCode: 'HDFC0001234',
      bankName: 'HDFC Bank',
      branch: 'Civil Lines Branch',
      upiId: 'brightfuture@hdfcbank',
    );
  }

  List<FeeModel> _seedFees(String studentId) {
    final now = DateTime.now();
    return [
      FeeModel(
        id: 'fee_1',
        studentId: studentId,
        title: 'Term 2 Tuition Fee',
        description: 'Quarterly tuition fee for Term 2 (Oct - Dec).',
        amount: 15000,
        dueDate: now.add(const Duration(days: 17)),
        paidAmount: 0,
      ),
      FeeModel(
        id: 'fee_2',
        studentId: studentId,
        title: 'Transport Fee',
        description: 'School bus fee for the current quarter.',
        amount: 5000,
        dueDate: now.add(const Duration(days: 5)),
        paidAmount: 0,
      ),
      FeeModel(
        id: 'fee_3',
        studentId: studentId,
        title: 'Annual Charges',
        description: 'Lab, library and sports annual charges.',
        amount: 4000,
        dueDate: now.subtract(const Duration(days: 40)),
        paidAmount: 4000,
      ),
    ];
  }

  Future<List<FeeModel>> getFees(String studentId) async {
    await MockDelay.simulate(milliseconds: 900);
    return _seedFees(studentId);
  }

  Future<List<FeePaymentModel>> getFeePayments(String studentId) async {
    await MockDelay.simulate(milliseconds: 700);
    final seeded = [
      FeePaymentModel(
        id: 'pay_seed_1',
        feeId: 'fee_3',
        studentId: studentId,
        amount: 4000,
        submittedOn: DateTime.now().subtract(const Duration(days: 42)),
        status: FeePaymentStatus.verified,
        screenshotName: 'receipt_annual.jpg',
        referenceNumber: 'TXN88213456',
        verificationRemarks: 'Payment confirmed. Thank you.',
        reviewedOn: DateTime.now().subtract(const Duration(days: 41)),
      ),
    ];
    return [..._paymentStore.where((p) => p.studentId == studentId), ...seeded]
      ..sort((a, b) => b.submittedOn.compareTo(a.submittedOn));
  }

  Future<FeePaymentModel> submitFeePayment(
    FeePaymentModel payment,
  ) async {
    await MockDelay.simulate();
    final saved = payment.copyWith(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      status: FeePaymentStatus.pending,
      submittedOn: DateTime.now(),
    );
    _paymentStore.insert(0, saved);
    return saved;
  }

  // ─────────────────────── ACADEMIC CALENDAR ────────────────────────

  Future<List<AcademicCalendarEvent>> getAcademicCalendar() async {
    await MockDelay.simulate(milliseconds: 900);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return [
      AcademicCalendarEvent(
        id: 'cal_1',
        title: 'Half-Yearly Examinations',
        description: 'All subjects. Timetable shared separately.',
        date: monthStart.add(const Duration(days: 8)),
        endDate: monthStart.add(const Duration(days: 15)),
        type: CalendarEventType.exam,
        audience: 'All',
      ),
      AcademicCalendarEvent(
        id: 'cal_2',
        title: 'Parent-Teacher Meeting',
        description: 'Discuss performance and progress with class teacher.',
        date: monthStart.add(const Duration(days: 20)),
        type: CalendarEventType.meeting,
        audience: 'Parents',
      ),
      AcademicCalendarEvent(
        id: 'cal_3',
        title: 'Mid-Term Result Declaration',
        description: 'Report cards available on the app.',
        date: monthStart.add(const Duration(days: 25)),
        type: CalendarEventType.result,
        audience: 'Parents',
      ),
      AcademicCalendarEvent(
        id: 'cal_4',
        title: 'Annual Day Rehearsals',
        description: 'Cultural programme practice after school hours.',
        date: monthStart.add(const Duration(days: 3)),
        endDate: monthStart.add(const Duration(days: 5)),
        type: CalendarEventType.activity,
        audience: 'All',
      ),
      AcademicCalendarEvent(
        id: 'cal_5',
        title: 'Independence Day Holiday',
        description: 'School remains closed.',
        date: DateTime(now.year, 8, 15),
        type: CalendarEventType.holiday,
      ),
      AcademicCalendarEvent(
        id: 'cal_6',
        title: 'Diwali Vacation',
        description: 'Festive break for students and staff.',
        date: DateTime(now.year, 11, 8),
        endDate: DateTime(now.year, 11, 16),
        type: CalendarEventType.vacation,
      ),
    ];
  }

  // ─────────────────────────── ANALYTICS ────────────────────────────

  /// Computes attendance + marks analytics for the dashboard charts.
  Future<StudentAnalytics> getStudentAnalytics(String studentId) async {
    await MockDelay.simulate(milliseconds: 800);
    final monthly = await getMonthlyAttendance(studentId, DateTime.now());
    final marks = await getStudentMarks(studentId);

    final present = monthly
        .where((a) =>
            a.status == AttendanceStatus.present ||
            a.status == AttendanceStatus.late)
        .length;
    final total = monthly.isEmpty ? 1 : monthly.length;
    final attendancePct = (present / total) * 100;

    final examGroups = <String, List<StudentMarkModel>>{};
    for (final m in marks) {
      examGroups.putIfAbsent(m.examId, () => []).add(m);
    }
    final examLabels = <String>[];
    final examPercentages = <double>[];
    var counter = 0;
    for (final entry in examGroups.entries) {
      final avg =
          entry.value.fold<double>(0, (s, m) => s + m.percentage) /
              entry.value.length;
      counter++;
      examLabels.add('Exam $counter');
      examPercentages.add(avg);
    }

    final avgPct = marks.isEmpty
        ? 0.0
        : marks.fold<double>(0, (s, m) => s + m.percentage) / marks.length;

    return StudentAnalytics(
      attendancePercentage: attendancePct,
      attendancePresent: present,
      attendanceTotal: total,
      averagePercentage: avgPct,
      overallGrade: calculateGrade(avgPct),
      examLabels: examLabels,
      examPercentages: examPercentages,
    );
  }
}
