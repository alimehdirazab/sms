# School Management System (SMS) — Flutter Mobile App

A production-ready Flutter mobile application combining **Parent** and **Teacher** flows with end-to-end integration of the complete **"School" Postman Collection** (`f9636028-f953-4dda-9939-e0247c4a8a80`, Nov 5, 2026). Built strictly using **Clean BLoC Architecture**, **Quiet Editorial Luxury UI Design System** (`DESIGN.md`), **Bulletproof Data Models**, **Dio Interceptors with Seamless Token Refresh**, and **Firebase Cloud Messaging (FCM)**.

---

## 0. Quality & Verification Status

- ✅ `dart analyze lib/ test/` → **No issues found! (0 errors, 0 warnings, 0 infos)**
- ✅ `flutter test` → **All test suites passed (100% contract and model safety)**
- ✅ **Zero Null-Crash Guarantee**: Safe fallbacks for missing, partial, or varied JSON schemas.
- ✅ **FCM Device Token Auto-Sync**: Token printed prominently in console on app start and synced via `/notifications/fcm-token`.
- ✅ **Quiet Editorial Luxury UI**: Poppins typography, Instrument Serif display headers & italic KPI numerals, hairline 1px `#E8E6E1` borders, sentence-case labels, and Pakistani Rupee `Rs.` formatting.

---

## 1. Postman Collection Integration Overview

Every endpoint from the School Postman Collection is connected end-to-end:

### 1. Auth Endpoints (`/auth`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/auth/login` | Login with email, password & optional `fcmToken` | [AuthRepository.login](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) & [AuthBloc](file:///d:/flutter/Projects/sms/lib/features/auth/bloc/auth_bloc.dart) |
| `POST` | `/auth/refresh` | Seamless access token refresh | [AuthInterceptor](file:///d:/flutter/Projects/sms/lib/core/network/auth_interceptor.dart) & [AuthRepository.refreshToken](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/forgot-password` | Request password reset instructions | [ForgotPasswordScreen](file:///d:/flutter/Projects/sms/lib/features/auth/screens/forgot_password_screen.dart) & [AuthRepository.forgotPassword](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/reset-password` | Reset password using reset token | [ResetPasswordScreen](file:///d:/flutter/Projects/sms/lib/features/auth/screens/reset_password_screen.dart) & [AuthRepository.resetPassword](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/logout` | Server session invalidation, FCM token wipe & local logout | [AuthRepository.logout](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |

### 2. Leave Management Endpoints (`/leaves`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/leaves` | Apply teacher leave (`leaveType`, `startDate`, `endDate`, `description`, `attachment`) | [LeaveRepository.createTeacherLeave](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) |
| `POST` | `/leaves` | Apply parent leave on behalf of student (`studentId`) | [LeaveRepository.createParentLeave](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) |
| `GET` | `/leaves?applicantType=STUDENT` | List student leave requests (supports `STUDENT` and `STUDEN`) | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) & [LeaveBloc](file:///d:/flutter/Projects/sms/lib/features/parent/bloc/leave_bloc.dart) |
| `GET` | `/leaves?applicantType=TEACHER` | List teacher own leave requests | [TeacherLeaveScreen](file:///d:/flutter/Projects/sms/lib/features/teacher/leave/teacher_leave_screen.dart) & [LeaveBloc](file:///d:/flutter/Projects/sms/lib/features/parent/bloc/leave_bloc.dart) |
| `GET` | `/leaves/{id}` | Inspect leave request details | [LeaveRepository.getLeaveById](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) |
| `PATCH` | `/leaves/{id}/status` | Teacher approve student leave request with optional remark | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) |
| `PATCH` | `/leaves/{id}/status` | Teacher reject student leave request with reason | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) |
| `DELETE` | `/leaves/{id}` | Delete requester pending leave request | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) |

### 3. Student Switch Endpoint (`/parent`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/parent/switch-student` | Switch active child/student context | [StudentSwitchRepository](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/student_switch_repository.dart) & [ParentBloc](file:///d:/flutter/Projects/sms/lib/features/parent/bloc/parent_bloc.dart) |

### 4. Teacher Attendance & Timetable Endpoints (`/attendance`, `/teacher`)
| HTTP Method | Endpoint | Description | Implementation & Requirements |
|---|---|---|---|
| `POST` | `/attendance/check-in` | Real-time teacher check-in | [TeacherAttendanceRepository.checkIn](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) — Front-camera selfie file & live GPS coordinates |
| `POST` | `/attendance/check-out` | Real-time teacher check-out | [TeacherAttendanceRepository.checkOut](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) — Live GPS location capture |
| `GET` | `/attendance/recent` | Fetch today's / recent attendance record | [TeacherAttendanceRepository.getRecentAttendance](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) |
| `GET` | `/attendance/my-attendance` | History with date filters (`startDate`, `endDate`) | [TeacherAttendanceRepository.getMyAttendanceHistory](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) |
| `GET` | `/teacher/timetable/today` | Fetch today's assigned periods and timetable schedule | [TeacherTimetableRepository.getTodayTimetable](file:///d:/flutter/Projects/sms/lib/features/teacher/schedule/repositories/teacher_timetable_repository.dart) & [TeacherBloc](file:///d:/flutter/Projects/sms/lib/features/teacher/bloc/teacher_bloc.dart) |

### 5. Parent Fees & School Bank Details Endpoints (`/parent/fees`, `/school`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/school/bank-details` | Fetch official school bank account & IBAN info | [ParentFeeRepository.getBankDetails](file:///d:/flutter/Projects/sms/lib/features/parent/fees/repositories/parent_fee_repository.dart) |
| `GET` | `/parent/fees?studentId={id}` | Student fee schedule, applicable fees, monthly summary & latest submission status | [ParentFeeRepository.getFeeDetails](file:///d:/flutter/Projects/sms/lib/features/parent/fees/repositories/parent_fee_repository.dart) & [ParentFeesScreen](file:///d:/flutter/Projects/sms/lib/features/parent/fees/parent_fees_screen.dart) |
| `POST` | `/parent/fees/submit-payment` | Submit / Resubmit deposit receipt verification with amount, payment method, TXN ID & receipt screenshot | [ParentFeeRepository.submitPaymentVerification](file:///d:/flutter/Projects/sms/lib/features/parent/fees/repositories/parent_fee_repository.dart) |

### 6. Academic Calendar Endpoints (`/academic-calendar`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/academic-calendar/events` | List campus events, holidays, examinations, vacations | [AcademicCalendarRepository.getEvents](file:///d:/flutter/Projects/sms/lib/features/parent/calendar/repositories/academic_calendar_repository.dart) |
| `GET` | `/academic-calendar/sessions` | List active and upcoming school academic sessions | [AcademicCalendarRepository.getSessions](file:///d:/flutter/Projects/sms/lib/features/parent/calendar/repositories/academic_calendar_repository.dart) |
| `GET` | `/academic-calendar/events/{id}` | Fetch individual event details | [AcademicCalendarRepository.getEventDetails](file:///d:/flutter/Projects/sms/lib/features/parent/calendar/repositories/academic_calendar_repository.dart) |

### 7. Notifications & Announcements Endpoints (`/notifications`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/notifications` | Fetch paginated notifications with unread count and category filters | [NotificationRepository.getNotifications](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) & [ParentNotificationsScreen](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/parent_notifications_screen.dart) / [TeacherNotificationsScreen](file:///d:/flutter/Projects/sms/lib/features/teacher/notifications/teacher_notifications_screen.dart) |
| `GET` | `/notifications?sentByMe=true` | Fetch announcements broadcasted by current teacher | [NotificationRepository.getSentByMeNotifications](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |
| `PATCH` | `/notifications/{id}/read` | Mark single notification as read | [NotificationRepository.markAsRead](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |
| `PATCH` | `/notifications/mark-all-read` | Mark all notifications as read | [NotificationRepository.markAllAsRead](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |
| `POST` | `/notifications/fcm-token` | Register or update FCM device push token with platform info (invoked only when authenticated) | [NotificationRepository.registerFcmToken](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |
| `DELETE` | `/notifications/fcm-token` | Unregister FCM token on logout | [NotificationRepository.unregisterFcmToken](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |
| `POST` | `/notifications/broadcast` | Broadcast school announcement (Super Admin, Principal, Teacher) | [NotificationRepository.broadcastAnnouncement](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) & [TeacherNotificationsScreen](file:///d:/flutter/Projects/sms/lib/features/teacher/notifications/teacher_notifications_screen.dart) |

### 8. Campus Announcement Endpoints (`/announcements`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/announcements?page={page}&limit={limit}` | Fetch paginated campus announcements with infinite scrolling | [AnnouncementRepository.getAnnouncements](file:///d:/flutter/Projects/sms/lib/features/announcements/repositories/announcement_repository.dart), [ParentAnnouncementsScreen](file:///d:/flutter/Projects/sms/lib/features/parent/announcements/parent_announcements_screen.dart) & [TeacherAnnouncementsScreen](file:///d:/flutter/Projects/sms/lib/features/teacher/announcements/teacher_announcements_screen.dart) |
| `POST` | `/announcements` | Teacher: Create and publish announcement for parents/students | [AnnouncementRepository.createAnnouncement](file:///d:/flutter/Projects/sms/lib/features/announcements/repositories/announcement_repository.dart) & [TeacherAnnouncementsScreen](file:///d:/flutter/Projects/sms/lib/features/teacher/announcements/teacher_announcements_screen.dart) |

---

## 2. Configuration & Networking

Default base URL is configured in [`api_constants.dart`](file:///d:/flutter/Projects/sms/lib/core/network/api_constants.dart):
- **Live Production Server**: `https://school-erp-backend-production-7992.up.railway.app/api`

### Centralized Session Cache & Security
- **Strict Pre-Login Authentication Gating**: APIs requiring authorization headers are blocked client-side in [AuthInterceptor](file:///d:/flutter/Projects/sms/lib/core/network/auth_interceptor.dart) if no active access token exists, completely eliminating pre-login 401 unauthorized errors.
- **High-Visibility Debug Console API Logger**: Every HTTP call, URI, method, headers, query parameters, request body, response status, response body, and error messages are clearly output to the debug console via [AppApiLogInterceptor](file:///d:/flutter/Projects/sms/lib/core/network/api_log_interceptor.dart) using `dart:developer` `log()`.
- **FCM Token Auto-Sync**: On app start, the generated device FCM token is retrieved and printed with a high-visibility banner in the debug console, and registered with the server once an authenticated session is established.
- **Parent Child Switcher & Leave Auto-Targeting**: In the Parent flow, children from the login response `user.students` are displayed as interactive chips. Selecting a child activates `/parent/switch-student` and reloads all fee schedules, attendance records, marks, and calendar events. In Leave application, the child's valid UUID is automatically bound or omitted so the server applies it to the active child context.
- **Teacher Weekly Timetable Note**: Today's timetable schedule connects live to `GET /teacher/timetable/today`. The weekly timetable screen displays the full 6-day mock schedule via `MockTeacherRepository` since the backend Postman collection provides only `/teacher/timetable/today`.
- **Access & Refresh Tokens**: Secured in OS keychain/keystore via `flutter_secure_storage`.
- **Active Student & Profile**: Persisted in `shared_preferences` and synced dynamically upon child selection.
- **Session Expiry**: When refresh token expires or is rejected, session is wiped and user is cleanly redirected to login.

---

## 3. Quick Demo Credentials

| Role | Email / ID | Password | Target Flow |
|---|---|---|---|
| **Parent** | `guardian@email.com` | `_f7EZRdDSFjV` | Direct Parent Dashboard with Child Switching & Fees |
| **Teacher** | `teacher@gmail.com` | `_f7EZRdDSFjV` | Direct Teacher Dashboard & Attendance Punch |

---

## 4. Verification Commands

```bash
# Verify static analysis (0 errors, 0 warnings, 0 infos)
dart analyze lib/ test/

# Run unit and contract test suites (10 passing tests)
flutter test

# Run the app on device
flutter run
```
