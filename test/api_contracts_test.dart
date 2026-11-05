import 'package:flutter_test/flutter_test.dart';
import 'package:sms/core/network/api_constants.dart';
import 'package:sms/features/auth/models/auth_response_model.dart';
import 'package:sms/features/parent/models/leave_api_model.dart';
import 'package:sms/features/teacher/attendance/models/attendance_api_model.dart';

void main() {
  group('ApiConstants Contract Validation', () {
    test('Endpoints match School Postman collection paths', () {
      expect(ApiConstants.login, '/auth/login');
      expect(ApiConstants.refresh, '/auth/refresh');
      expect(ApiConstants.forgotPassword, '/auth/forgot-password');
      expect(ApiConstants.resetPassword, '/auth/reset-password');
      expect(ApiConstants.logout, '/auth/logout');
      expect(ApiConstants.leaves, '/leaves');
      expect(ApiConstants.leaveDetails('123'), '/leaves/123');
      expect(ApiConstants.updateLeaveStatus('123'), '/leaves/123/status');
      expect(ApiConstants.deleteLeave('123'), '/leaves/123');
      expect(ApiConstants.switchStudent, '/parent/switch-student');
    });
  });

  group('Bulletproof Models - Safe Fallback & Zero-Null Crash', () {
    test('UserModel.fromJson safely handles nulls and varied formats', () {
      final user = UserModel.fromJson(null);
      expect(user.id, '');
      expect(user.name, 'User');
      expect(user.role.toUpperCase(), 'PARENT');
      expect(user.normalizedRole, 'parent');
      expect(user.studentIds, isEmpty);

      final userWithData = UserModel.fromJson(const {
        'id': 'usr_99',
        'email': 'teacher@school.com',
        'firstName': 'Teacher',
        'lastName': 'One',
        'role': 'TEACHER',
        'activeStudentId': 's_1',
      });
      expect(userWithData.id, 'usr_99');
      expect(userWithData.email, 'teacher@school.com');
      expect(userWithData.role, 'TEACHER');
      expect(userWithData.normalizedRole, 'teacher');
    });

    test('AuthResponseModel.fromJson safely parses nested response envelopes', () {
      final res = AuthResponseModel.fromJson(const {
        'success': true,
        'message': 'Login successful',
        'data': {
          'accessToken': 'jwt_access_abc',
          'refreshToken': 'jwt_refresh_xyz',
          'user': {
            'id': 'u1',
            'email': 'parent@school.com',
            'role': 'parent',
          },
        },
      });

      expect(res.success, isTrue);
      expect(res.accessToken, 'jwt_access_abc');
      expect(res.refreshToken, 'jwt_refresh_xyz');
      expect(res.user?.email, 'parent@school.com');
    });

    test('LeaveItemModel.fromJson and LeavePaginationModel.fromJson handle varied list schemas safely', () {
      final emptyPagination = LeavePaginationModel.fromJson(null);
      expect(emptyPagination.items, isEmpty);
      expect(emptyPagination.totalCount, 0);
      expect(emptyPagination.hasNextPage, isFalse);

      final paginationWithData = LeavePaginationModel.fromJson(const {
        'success': true,
        'data': {
          'leaves': [
            {
              'id': 'lv_1',
              'leaveType': 'Sick Leave',
              'startDate': '2026-10-22',
              'endDate': '2026-10-24',
              'description': 'Viral fever',
              'status': 'PENDING',
              'studentId': '768-9876',
            },
            {
              'id': 'lv_2',
              'leaveType': 'Casual Leave',
              'startDate': '2026-10-25',
              'endDate': '2026-10-25',
              'description': 'Family event',
              'status': 'APPROVED',
            }
          ],
          'total': 2,
          'page': 1,
          'limit': 10,
        }
      });

      expect(paginationWithData.items.length, 2);
      expect(paginationWithData.items[0].status, LeaveStatus.pending);
      expect(paginationWithData.items[0].studentId, '768-9876');
      expect(paginationWithData.items[1].status, LeaveStatus.approved);
      expect(paginationWithData.totalCount, 2);
    });

    test('AttendanceRecordModel and AttendanceHistoryResponseModel parse attendance records safely', () {
      final emptyRecord = AttendanceRecordModel.fromJson(null);
      expect(emptyRecord.id, '');
      expect(emptyRecord.status, TeacherAttendanceStatus.unknown);
      expect(emptyRecord.checkInTime, isNull);

      final record = AttendanceRecordModel.fromJson(const {
        'id': 'att_01',
        'teacherId': 'teacher_99',
        'date': '2026-10-14',
        'status': 'PRESENT',
        'checkInTime': '2026-10-14T08:05:00Z',
        'checkOutTime': '2026-10-14T15:00:00Z',
        'latitude': 33.6844,
        'longitude': 73.0479,
        'accuracy': 15.2,
      });

      expect(record.id, 'att_01');
      expect(record.teacherId, 'teacher_99');
      expect(record.status, TeacherAttendanceStatus.present);
      expect(record.checkInLatitude, 33.6844);
      expect(record.checkInLongitude, 73.0479);
      expect(record.checkInAccuracy, 15.2);
      expect(record.checkInTime, isNotNull);
      expect(record.checkOutTime, isNotNull);

      final history = AttendanceHistoryResponseModel.fromJson(const {
        'success': true,
        'data': {
          'records': [
            {
              'id': 'att_01',
              'status': 'PRESENT',
              'checkInTime': '2026-10-14T08:05:00Z',
            }
          ]
        }
      });

      expect(history.records.length, 1);
      expect(history.totalCount, 1);
    });

    test('ApiConstants covers School ERP Auth & Attendance API endpoints', () {
      expect(ApiConstants.attendanceCheckIn, '/attendance/check-in');
      expect(ApiConstants.attendanceCheckOut, '/attendance/check-out');
      expect(ApiConstants.attendanceRecent, '/attendance/recent');
      expect(ApiConstants.attendanceMyHistory, '/attendance/my-attendance');
    });

    test('LeaveItemModel handles both applicantType and aplicantType with STUDEN and TEACHER', () {
      final studentLeave = LeaveItemModel.fromJson(const {
        'id': 'lv_studen_1',
        'leaveType': 'Sick Leave',
        'startDate': '2026-11-01',
        'endDate': '2026-11-03',
        'description': 'Student illness',
        'status': 'PENDING',
        'aplicantType': 'STUDEN',
        'applicantId': 's_101',
        'applicantName': 'Zaid Khan',
      });

      expect(studentLeave.id, 'lv_studen_1');
      expect(studentLeave.applicantType, 'STUDEN');
      expect(studentLeave.applicantName, 'Zaid Khan');
      expect(studentLeave.studentId, 's_101');

      final teacherLeave = LeaveItemModel.fromJson(const {
        'id': 'lv_teacher_1',
        'leaveType': 'Casual Leave',
        'startDate': '2026-11-10',
        'endDate': '2026-11-10',
        'description': 'Personal work',
        'status': 'APPROVED',
        'aplicantType': 'TEACHER',
        'applicantId': 't_201',
        'applicantName': 'Mr. Ahmed',
      });

      expect(teacherLeave.id, 'lv_teacher_1');
      expect(teacherLeave.applicantType, 'TEACHER');
      expect(teacherLeave.applicantName, 'Mr. Ahmed');
      expect(teacherLeave.studentId, isNull);
    });
  });
}
