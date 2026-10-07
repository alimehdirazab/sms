import '../../auth/models/user_model.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/marks_model.dart';
import '../../auth/models/notification_model.dart';
import '../../../core/utils/mock_delay.dart';

class MockTeacherRepository {
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
}
