import 'package:flutter_test/flutter_test.dart';
import 'package:sms/core/network/api_constants.dart';
import 'package:sms/features/auth/models/auth_response_model.dart';
import 'package:sms/features/auth/models/academic_calendar_model.dart';
import 'package:sms/features/auth/models/notification_model.dart';
import 'package:sms/features/parent/models/leave_api_model.dart';
import 'package:sms/features/parent/repositories/leave_repository.dart';
import 'package:sms/features/parent/fees/models/parent_fee_api_model.dart';
import 'package:sms/features/teacher/attendance/models/attendance_api_model.dart';
import 'package:sms/features/announcements/models/announcement_model.dart';

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
      expect(ApiConstants.bankDetails, '/school/bank-details');
      expect(ApiConstants.parentFees, '/parent/fees');
      expect(ApiConstants.submitFeePayment, '/parent/fees/submit-payment');
      expect(ApiConstants.academicCalendarEvents, '/academic-calendar/events');
      expect(ApiConstants.academicCalendarSessions, '/academic-calendar/sessions');
      expect(ApiConstants.academicCalendarEventDetails('e1'), '/academic-calendar/events/e1');
      expect(ApiConstants.notifications, '/notifications');
      expect(ApiConstants.markNotificationRead('n1'), '/notifications/n1/read');
      expect(ApiConstants.markAllNotificationsRead, '/notifications/mark-all-read');
      expect(ApiConstants.notificationFcmToken, '/notifications/fcm-token');
      expect(ApiConstants.notificationBroadcast, '/notifications/broadcast');
      expect(ApiConstants.announcements, '/announcements');
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

    test('LeaveRepository.isValidUuid strictly checks UUID formats and rejects dummy strings', () {
      expect(LeaveRepository.isValidUuid('0be6e309-4771-4f4a-a8df-933993e34b10'), isTrue);
      expect(LeaveRepository.isValidUuid('c4b18c5e-0c17-4835-bd91-3cf8e305eebc'), isTrue);
      expect(LeaveRepository.isValidUuid('768-9876'), isFalse);
      expect(LeaveRepository.isValidUuid('null'), isFalse);
      expect(LeaveRepository.isValidUuid(''), isFalse);
      expect(LeaveRepository.isValidUuid(null), isFalse);
    });

    test('ParentFeeResponseModel safely handles live fee JSON response and nulls', () {
      final empty = ParentFeeResponseModel.fromJson(null);
      expect(empty.success, isFalse);
      expect(empty.data, isNull);

      final liveFee = ParentFeeResponseModel.fromJson(const {
        'success': true,
        'message': 'Student fee details retrieved successfully.',
        'data': {
          'student': {
            'id': 's_001',
            'name': 'Mushtaq Khan',
            'className': 'Class-1',
            'sectionName': 'A',
          },
          'bankDetails': {
            'bankName': 'Meezan Bank Limited',
            'accountName': 'Beacon House School',
            'accountNumber': '096288300099',
            'ibanNo': 'PK36MENZ096288300099',
          },
          'applicableFees': [
            {
              'id': 'fee_1',
              'name': 'Tuition Fee',
              'amount': 1000,
              'category': 'MONTHLY',
              'dueDate': '2026-11-10',
              'status': 'paid',
            }
          ],
          'summary': {
            'grandTotal': 1000,
            'dueStatus': 'PAID',
            'currentMonthFee': 1000,
          },
          'paymentStatus': 'APPROVED',
          'latestPaymentSubmission': {
            'id': 'sub_1',
            'invoiceNumber': 'PAY-85198661',
            'amount': 1000,
            'paymentMethod': 'Bank Transfer',
            'transactionId': 'TXN-98234123',
            'status': 'APPROVED',
          }
        }
      });

      expect(liveFee.success, isTrue);
      expect(liveFee.data?.student.name, 'Mushtaq Khan');
      expect(liveFee.data?.bankDetails.ibanNo, 'PK36MENZ096288300099');
      expect(liveFee.data?.applicableFees.first.amount, 1000);
      expect(liveFee.data?.summary.grandTotal, 1000);
      expect(liveFee.data?.paymentStatus, 'APPROVED');
      expect(liveFee.data?.toDomainFees().first.title, 'Tuition Fee');
      expect(liveFee.data?.toDomainAccount().accountName, 'Beacon House School');
      expect(liveFee.data?.toDomainPayments().first.referenceNumber, 'TXN-98234123');
    });

    test('AcademicCalendarEvent safely parses live API event structure', () {
      final emptyEvent = AcademicCalendarEvent.fromJson(null);
      expect(emptyEvent.id, '');
      expect(emptyEvent.title, '');

      final liveEvent = AcademicCalendarEvent.fromJson(const {
        'id': 'cal_1',
        'title': 'Kashmir Day',
        'type': 'holiday',
        'startDate': '2026-02-05',
        'endDate': '2026-02-05',
        'audience': ['students', 'parents', 'teachers'],
        'description': 'Kashmir Solidarity Day',
      });

      expect(liveEvent.id, 'cal_1');
      expect(liveEvent.title, 'Kashmir Day');
      expect(liveEvent.type, CalendarEventType.holiday);
      expect(liveEvent.audience, 'students, parents, teachers');
    });

    test('NotificationModel and NotificationListResponseModel parse live API structures safely', () {
      final emptyList = NotificationListResponseModel.fromJson(null);
      expect(emptyList.notifications, isEmpty);
      expect(emptyList.unreadCount, 0);

      final liveRes = NotificationListResponseModel.fromJson(const {
        'success': true,
        'message': 'Notifications fetched successfully',
        'data': {
          'notifications': [
            {
              'id': 5,
              'notificationId': 'nid_123',
              'title': 'New Term Fee',
              'message': 'Term Fee has been scheduled.',
              'category': 'FEE_REMINDER',
              'isRead': false,
              'createdByName': 'Bilal Ahmed Ali',
              'createdByRole': 'PRINCIPAL',
            }
          ],
          'unreadCount': 1,
          'pagination': {
            'page': 1,
            'limit': 20,
            'total': 1,
            'totalPages': 1,
          }
        }
      });

      expect(liveRes.notifications.length, 1);
      expect(liveRes.unreadCount, 1);
      final notif = liveRes.notifications.first;
      expect(notif.id, '5');
      expect(notif.title, 'New Term Fee');
      expect(notif.type, NotificationType.feeDue);
      expect(notif.isRead, isFalse);
      expect(notif.createdByName, 'Bilal Ahmed Ali');
    });

    test('AnnouncementModel & AnnouncementListResponseModel handle live schemas and nulls', () {
      final empty = AnnouncementListResponseModel.fromJson(null);
      expect(empty.announcements, isEmpty);
      expect(empty.page, 1);
      expect(empty.hasNextPage, isFalse);

      final liveResponse = AnnouncementListResponseModel.fromJson(const {
        'success': true,
        'data': [
          {
            'id': 'ann_101',
            'title': 'Upcoming Parent-Teacher Conference',
            'message': 'Dear parents, please note that...',
            'recipient': ['parents'],
            'senderName': 'Sir Ahmed',
            'senderRole': 'TEACHER',
            'createdAt': '2026-11-06T18:00:00.000Z',
          }
        ],
        'meta': {
          'page': 1,
          'limit': 10,
          'total': 25,
          'totalPages': 3,
          'hasNextPage': true,
        }
      });

      expect(liveResponse.announcements.length, 1);
      expect(liveResponse.page, 1);
      expect(liveResponse.limit, 10);
      expect(liveResponse.total, 25);
      expect(liveResponse.totalPages, 3);
      expect(liveResponse.hasNextPage, isTrue);

      final item = liveResponse.announcements.first;
      expect(item.id, 'ann_101');
      expect(item.title, 'Upcoming Parent-Teacher Conference');
      expect(item.recipient, ['parents']);
      expect(item.senderName, 'Sir Ahmed');
      expect(item.senderRole, 'TEACHER');
    });
  });
}
