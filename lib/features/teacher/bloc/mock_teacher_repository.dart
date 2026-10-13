import '../../auth/models/user_model.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/marks_model.dart';
import '../../auth/models/notification_model.dart';
import '../../auth/models/leave_model.dart';
import '../../auth/models/academic_calendar_model.dart';
import '../../../core/utils/mock_delay.dart';

/// Analytics used by the teacher dashboard charts.
class TeacherAnalytics {
  final double attendancePercentage;
  final int presentDays;
  final int totalDays;
  final int lateDays;
  final double classAverage;
  final List<String> subjectLabels;
  final List<double> subjectAverages;
  final List<String> weekdayLabels;
  final List<double> weekdayAttendance;

  const TeacherAnalytics({
    required this.attendancePercentage,
    required this.presentDays,
    required this.totalDays,
    required this.lateDays,
    required this.classAverage,
    required this.subjectLabels,
    required this.subjectAverages,
    required this.weekdayLabels,
    required this.weekdayAttendance,
  });
}

class MockTeacherRepository {
  /// Session-scoped store of leave applications submitted by the teacher.
  /// The Principal's separate web app is the approver, so new entries always
  /// start as [LeaveStatus.pending].
  final List<LeaveApplicationModel> _leaveStore = [];

  /// Free-text comments attached to a late check-in, keyed by attendance id.
  final Map<String, String> _lateComments = {};

  Future<TeacherModel> getTeacherProfile() async {
    await MockDelay.simulate();
    return const TeacherModel(
      id: 't1',
      name: 'Mr. Rajesh Kumar',
      employeeId: 'EMP001',
      department: 'Mathematics',
      assignedClasses: ['Class 10-A', 'Class 10-B', 'Class 9-A'],
      canPublishMarks: false,
      phoneNumber: '+91 9876543210',
      email: 'rajesh.kumar@school.edu',
      photoUrl: null,
    );
  }

  Future<List<AttendanceModel>> getTeacherAttendance() async {
    await MockDelay.simulate();
    final now = DateTime.now();
    return List.generate(15, (index) {
      final date = now.subtract(Duration(days: index));
      final isPresent = index % 5 != 0;
      final checkInHour = 8 + (index % 2);
      final checkInMinute = 15 + (index * 7) % 45;
      return AttendanceModel(
        id: 'att_t_$index',
        userId: 't1',
        date: date,
        checkInTime: isPresent
            ? DateTime(date.year, date.month, date.day, checkInHour, checkInMinute)
            : null,
        checkOutTime: isPresent
            ? DateTime(date.year, date.month, date.day, 15 + (index % 2), (index * 13) % 60)
            : null,
        status: isPresent
            ? (checkInHour > 8 ? AttendanceStatus.late : AttendanceStatus.present)
            : AttendanceStatus.absent,
        isInsideGeofence: isPresent,
        faceVerified: isPresent,
      );
    });
  }

  Future<List<String>> getAssignedClasses() async {
    await MockDelay.simulate(milliseconds: 800);
    return ['Class 10-A', 'Class 10-B', 'Class 9-A', 'Class 9-B'];
  }

  Future<List<String>> getSubjectsForClass(String className) async {
    await MockDelay.simulate(milliseconds: 800);
    final subjects = <String, List<String>>{
      'Class 10-A': ['Mathematics', 'Physics', 'Chemistry', 'English'],
      'Class 10-B': ['Mathematics', 'Physics', 'Biology', 'English'],
      'Class 9-A': ['Mathematics', 'Physics', 'History', 'English'],
      'Class 9-B': ['Mathematics', 'Chemistry', 'Geography', 'English'],
    };
    return subjects[className] ?? ['Mathematics'];
  }

  Future<List<ExamModel>> getExamsForSubject(String className, String subject) async {
    await MockDelay.simulate(milliseconds: 800);
    final now = DateTime.now();
    return [
      ExamModel(
        id: 'e1',
        name: 'Mid-Term Examination',
        className: className,
        subjectId: '${subject}_1',
        subjectName: subject,
        date: now.subtract(const Duration(days: 30)),
        status: MarkStatus.published,
      ),
      ExamModel(
        id: 'e2',
        name: 'Final Examination',
        className: className,
        subjectId: '${subject}_2',
        subjectName: subject,
        date: now.subtract(const Duration(days: 5)),
        status: MarkStatus.draft,
      ),
      ExamModel(
        id: 'e3',
        name: 'Unit Test 1',
        className: className,
        subjectId: '${subject}_3',
        subjectName: subject,
        date: now.subtract(const Duration(days: 60)),
        status: MarkStatus.published,
      ),
    ];
  }

  Future<List<StudentModel>> getStudentsForClass(String className) async {
    await MockDelay.simulate(milliseconds: 800);
    return List.generate(20, (index) {
      return StudentModel(
        id: 's_${className}_$index',
        name: 'Student ${index + 1}',
        rollNumber: '${className.split(' ').last}-${(index + 1).toString().padLeft(2, '0')}',
        className: className,
        section: className.split('-').length > 1 ? className.split('-').last : 'A',
        rfidCardId: 'RFID${1000 + index}',
      );
    });
  }

  Future<List<StudentMarkModel>> getStudentMarks(String examId) async {
    await MockDelay.simulate();
    return [
      StudentMarkModel(
        id: 'sm_1',
        examId: examId,
        studentId: 's1',
        studentName: 'Aarav Sharma',
        rollNumber: '10A-01',
        obtainedMarks: 85,
        totalMarks: 100,
        status: MarkStatus.draft,
      ),
      StudentMarkModel(
        id: 'sm_2',
        examId: examId,
        studentId: 's2',
        studentName: 'Priya Patel',
        rollNumber: '10A-02',
        obtainedMarks: 92,
        totalMarks: 100,
        status: MarkStatus.draft,
      ),
      StudentMarkModel(
        id: 'sm_3',
        examId: examId,
        studentId: 's3',
        studentName: 'Rohan Gupta',
        rollNumber: '10A-03',
        obtainedMarks: 45,
        totalMarks: 100,
        status: MarkStatus.draft,
      ),
    ];
  }

  Future<bool> saveStudentMarks(List<StudentMarkModel> marks) async {
    await MockDelay.simulate(milliseconds: 1000);
    return true;
  }

  Future<bool> publishMarks(String examId) async {
    await MockDelay.simulate(milliseconds: 1000);
    return true;
  }

  Future<List<ScheduleModel>> getTodaySchedule() async {
    await MockDelay.simulate(milliseconds: 800);
    final now = DateTime.now();
    return [
      ScheduleModel(
        id: 'sched_1',
        subject: 'Mathematics',
        className: 'Class 10-A',
        section: 'A',
        startTime: DateTime(now.year, now.month, now.day, 8, 0),
        endTime: DateTime(now.year, now.month, now.day, 8, 45),
      ),
      ScheduleModel(
        id: 'sched_2',
        subject: 'Physics',
        className: 'Class 10-B',
        section: 'B',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 9, 45),
      ),
      ScheduleModel(
        id: 'sched_3',
        subject: 'Mathematics',
        className: 'Class 9-A',
        section: 'A',
        startTime: DateTime(now.year, now.month, now.day, 10, 15),
        endTime: DateTime(now.year, now.month, now.day, 11, 0),
      ),
      ScheduleModel(
        id: 'sched_4',
        subject: 'Mathematics',
        className: 'Class 10-A',
        section: 'A',
        startTime: DateTime(now.year, now.month, now.day, 11, 30),
        endTime: DateTime(now.year, now.month, now.day, 12, 15),
      ),
    ];
  }

  Future<bool> submitAttendanceCorrection(String attendanceId, String reason) async {
    await MockDelay.simulate();
    return true;
  }

  Future<List<AttendanceModel>> getStudentAttendanceOverview(String className) async {
    await MockDelay.simulate(milliseconds: 1200);
    final now = DateTime.now();
    return List.generate(10, (index) {
      final date = now.subtract(Duration(days: index));
      return AttendanceModel(
        id: 'stud_att_$index',
        userId: 'class_$className',
        date: date,
        checkInTime: DateTime(date.year, date.month, date.day, 8, 30),
        status: index % 4 == 0 ? AttendanceStatus.absent : AttendanceStatus.present,
        isInsideGeofence: index % 4 != 0,
        faceVerified: index % 4 != 0,
      );
    });
  }

  Future<int> getNotificationCount() async {
    await MockDelay.simulate(milliseconds: 300);
    return 3;
  }

  /// Attaches a short comment to a late check-in record.
  Future<bool> addLateCheckInComment(
    String attendanceId,
    String comment,
  ) async {
    await MockDelay.simulate(milliseconds: 600);
    _lateComments[attendanceId] = comment;
    return true;
  }

  String? lateCommentFor(String attendanceId) => _lateComments[attendanceId];

  // ─────────────────────── WEEKLY TIMETABLE ─────────────────────────

  /// Returns the full week timetable grouped by weekday (Mon..Sat).
  Future<Map<String, List<ScheduleModel>>> getWeeklySchedule() async {
    await MockDelay.simulate(milliseconds: 900);
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));

    // A rotation of subjects per weekday so the timetable looks realistic.
    final rotation = <String, List<List<String>>>{
      'Monday': [
        ['Mathematics', 'Class 10-A'],
        ['Physics', 'Class 10-B'],
        ['Mathematics', 'Class 9-A'],
        ['Mathematics', 'Class 10-A'],
      ],
      'Tuesday': [
        ['Physics', 'Class 10-A'],
        ['Mathematics', 'Class 9-B'],
        ['Mathematics', 'Class 10-B'],
        ['Chemistry', 'Class 10-A'],
      ],
      'Wednesday': [
        ['Mathematics', 'Class 9-A'],
        ['Mathematics', 'Class 10-A'],
        ['Physics', 'Class 10-B'],
        ['English', 'Class 10-A'],
      ],
      'Thursday': [
        ['Chemistry', 'Class 10-B'],
        ['Mathematics', 'Class 10-A'],
        ['Mathematics', 'Class 9-B'],
        ['Physics', 'Class 9-A'],
      ],
      'Friday': [
        ['Mathematics', 'Class 10-B'],
        ['Physics', 'Class 10-A'],
        ['Mathematics', 'Class 9-A'],
        ['Mathematics', 'Class 10-A'],
      ],
      'Saturday': [
        ['Mathematics', 'Class 10-A'],
        ['Mathematics', 'Class 9-B'],
        ['Revision', 'Class 10-A'],
      ],
    };

    final result = <String, List<ScheduleModel>>{};
    for (var i = 0; i < weekdays.length; i++) {
      final day = weekdays[i];
      final dayDate = monday.add(Duration(days: i));
      final periods = rotation[day] ?? const [];
      var startHour = 8;
      var startMinute = 0;
      final entries = <ScheduleModel>[];
      for (var p = 0; p < periods.length; p++) {
        final subject = periods[p][0];
        final className = periods[p][1];
        final start = DateTime(
          dayDate.year,
          dayDate.month,
          dayDate.day,
          startHour,
          startMinute,
        );
        final end = start.add(const Duration(minutes: 45));
        entries.add(
          ScheduleModel(
            id: 'wk_${day}_$p',
            subject: subject,
            className: className,
            section: className.split('-').last,
            startTime: start,
            endTime: end,
          ),
        );
        // 15 minute break between periods.
        startMinute += 60;
        if (startMinute >= 60) {
          startHour += startMinute ~/ 60;
          startMinute %= 60;
        }
      }
      result[day] = entries;
    }
    return result;
  }

  // ─────────────────────── ACADEMIC CALENDAR ────────────────────────

  Future<List<AcademicCalendarEvent>> getAcademicCalendar() async {
    await MockDelay.simulate(milliseconds: 900);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return [
      AcademicCalendarEvent(
        id: 'tcal_1',
        title: 'Staff Meeting',
        description: 'Monthly staff coordination meeting in the conference hall.',
        date: monthStart.add(const Duration(days: 2)),
        type: CalendarEventType.meeting,
        audience: 'Teachers',
      ),
      AcademicCalendarEvent(
        id: 'tcal_2',
        title: 'Half-Yearly Examinations',
        description: 'Invigilation duty as per the published roster.',
        date: monthStart.add(const Duration(days: 8)),
        endDate: monthStart.add(const Duration(days: 15)),
        type: CalendarEventType.exam,
        audience: 'All',
      ),
      AcademicCalendarEvent(
        id: 'tcal_3',
        title: 'Answer Sheet Evaluation',
        description: 'Submit evaluated answer sheets to the exam cell.',
        date: monthStart.add(const Duration(days: 17)),
        endDate: monthStart.add(const Duration(days: 19)),
        type: CalendarEventType.activity,
        audience: 'Teachers',
      ),
      AcademicCalendarEvent(
        id: 'tcal_4',
        title: 'Parent-Teacher Meeting',
        description: 'Discuss student progress with parents.',
        date: monthStart.add(const Duration(days: 20)),
        type: CalendarEventType.meeting,
        audience: 'All',
      ),
      AcademicCalendarEvent(
        id: 'tcal_5',
        title: 'Result Declaration',
        description: 'Publish mid-term results after principal approval.',
        date: monthStart.add(const Duration(days: 25)),
        type: CalendarEventType.result,
        audience: 'All',
      ),
      AcademicCalendarEvent(
        id: 'tcal_6',
        title: 'Annual Day',
        description: 'Cultural programme. Teachers to assist with coordination.',
        date: monthStart.add(const Duration(days: 27)),
        type: CalendarEventType.event,
        audience: 'All',
      ),
    ];
  }

  // ─────────────────────────── ANALYTICS ────────────────────────────

  Future<TeacherAnalytics> getTeacherAnalytics() async {
    await MockDelay.simulate(milliseconds: 800);
    final attendance = await getTeacherAttendance();
    final present = attendance
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final late = attendance
        .where((a) => a.status == AttendanceStatus.late)
        .length;
    final total = attendance.isEmpty ? 1 : attendance.length;

    const subjectLabels = ['10-A', '10-B', '9-A', '9-B'];
    const subjectAverages = [78.4, 74.1, 81.6, 69.8];

    // Weekly attendance trend sampled over the last 6 days (oldest first).
    final recent = attendance.take(6).toList().reversed.toList();
    final weekdayLabels = <String>[];
    final weekdayAttendance = <double>[];
    for (final a in recent) {
      weekdayLabels.add(_weekdayShort(a.date));
      weekdayAttendance.add(
        a.status == AttendanceStatus.absent ? 0 : 100,
      );
    }

    return TeacherAnalytics(
      attendancePercentage: ((present + late) / total) * 100,
      presentDays: present,
      totalDays: total,
      lateDays: late,
      classAverage: subjectAverages.reduce((a, b) => a + b) /
          subjectAverages.length,
      subjectLabels: subjectLabels,
      subjectAverages: subjectAverages,
      weekdayLabels: weekdayLabels,
      weekdayAttendance: weekdayAttendance,
    );
  }

  String _weekdayShort(DateTime date) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  // ───────────────────────────── LEAVE ──────────────────────────────

  List<LeaveApplicationModel> _seedLeaves() {
    final now = DateTime.now();
    return [
      LeaveApplicationModel(
        id: 'tlv_seed_1',
        applicantId: 't1',
        applicantName: 'Mr. Rajesh Kumar',
        applicantType: LeaveApplicant.teacher,
        type: LeaveType.casual,
        fromDate: now.subtract(const Duration(days: 20)),
        toDate: now.subtract(const Duration(days: 20)),
        reason: 'Personal work at the bank.',
        status: LeaveStatus.approved,
        principalRemarks: 'Approved. Arrange a substitute for your periods.',
        appliedOn: now.subtract(const Duration(days: 22)),
      ),
      LeaveApplicationModel(
        id: 'tlv_seed_2',
        applicantId: 't1',
        applicantName: 'Mr. Rajesh Kumar',
        applicantType: LeaveApplicant.teacher,
        type: LeaveType.medical,
        fromDate: now.add(const Duration(days: 4)),
        toDate: now.add(const Duration(days: 5)),
        reason: 'Scheduled dental procedure at the city hospital.',
        status: LeaveStatus.pending,
        appliedOn: now.subtract(const Duration(days: 1)),
        attachmentName: 'dental_appointment.pdf',
      ),
    ];
  }

  Future<List<LeaveApplicationModel>> getLeaveApplications() async {
    await MockDelay.simulate(milliseconds: 900);
    if (_leaveStore.isEmpty) {
      _leaveStore.addAll(_seedLeaves());
    }
    return List.of(_leaveStore)
      ..sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
  }

  Future<LeaveApplicationModel> submitLeaveApplication(
    LeaveApplicationModel application,
  ) async {
    await MockDelay.simulate();
    final saved = application.copyWith(
      id: 'tlv_${DateTime.now().millisecondsSinceEpoch}',
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
}
