# Nexira — Flutter Mobile Application

A production-ready Flutter mobile application combining **Parent** and **Teacher** flows with end-to-end integration of the complete **"School" Postman Collection** (Nov 2026) and web portal APIs. Built strictly using **Clean BLoC Architecture**, **Fintech Editorial Design System** with **Google Fonts Poppins**, **Fintech 3D Bottom Navigation Bar**, **Personal Profile with 3D Glassmorphic Avatar**, **Bulletproof Data Models**, **Smart Network Retry UI**, **Dio Interceptors with Seamless Token Refresh**, and **Firebase Cloud Messaging (FCM)**.

---

## 0. Quality & Verification Status

- ✅ `dart analyze lib/ test/` → **No issues found! (0 errors, 0 warnings, 0 infos)**
- ✅ `flutter test` → **All test suites passed (100% contract and model safety)**
- ✅ **Offline Detection & Retry UX**: Automatically converts raw socket and host lookup failures (`api.nexira.pk`) into a friendly *"No internet connection"* message with a floating action pill and one-tap **RETRY** button.
- ✅ **Fintech 3D Bottom Navigation Bar**: Custom bottom navigation bar featuring 3D glossy icons (`Home`, `Discover`, `My Billing`, `Accounts`), a white surface with 28px top-rounded corners, and an elevated circular orange action button with dialogue bubble badge (`Complaint` for Parents, `Attendance` for Teachers).
- ✅ **Fintech Personal Profile Screen**: Luxury personal profile layout featuring `< Personal Profile` header, centered 3D translucent amber glassmorphic bust avatar with overlapping camera badge (`#4A4A4A`), outlined `[ 👤 Edit Profile ]` orange action button, and a rounded card with `Full Name *`, `Email Address`, `Mobile Number` with Pakistan flag 🇵🇰 and lock icon 🔒, `CNIC`, password change dialog, and sign out.
- ✅ **Zero Null-Crash Guarantee**: Safe fallbacks for missing, partial, or varied JSON schemas.
- ✅ **FCM Device Token Auto-Sync**: Token printed prominently in console on app start and synced via `/notifications/fcm-token`.
- ✅ **Typography**: Clean, unified **Google Fonts Poppins** typography across the entire application with positive letter spacing.
- ✅ **Leave Application Attachment**: Optional document/image picker with base64 data URI encoding submitted directly to `/leaves`.
- ✅ **User Profile Management**: Live `PUT /api/users/{id}` profile editing with validation and server synchronization.
- ✅ **Announcements Removal**: Announcements feature and endpoints cleanly pruned per specifications.

---

## 1. Postman & Web Portal API Integration Overview

Every active endpoint from the School Postman Collection and Web Portal is connected end-to-end:

### 1. Auth Endpoints (`/auth`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/auth/login` | Login with email, password & optional `fcmToken` | [AuthRepository.login](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) & [AuthBloc](file:///d:/flutter/Projects/sms/lib/features/auth/bloc/auth_bloc.dart) |
| `POST` | `/auth/refresh` | Seamless access token refresh | [AuthInterceptor](file:///d:/flutter/Projects/sms/lib/core/network/auth_interceptor.dart) & [AuthRepository.refreshToken](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/change-password` | Change account password with current, new, and confirm password | [AuthRepository.changePassword](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) & [ChangePasswordDialog](file:///d:/flutter/Projects/sms/lib/features/shared/widgets/change_password_dialog.dart) |
| `POST` | `/auth/forgot-password` | Request password reset instructions | [ForgotPasswordScreen](file:///d:/flutter/Projects/sms/lib/features/auth/screens/forgot_password_screen.dart) & [AuthRepository.forgotPassword](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/reset-password` | Reset password using reset token | [ResetPasswordScreen](file:///d:/flutter/Projects/sms/lib/features/auth/screens/reset_password_screen.dart) & [AuthRepository.resetPassword](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/logout` | Server session invalidation, FCM token wipe & local logout | [AuthRepository.logout](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |

### 2. Leave Management Endpoints (`/leaves`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/leaves` | Apply teacher leave with optional base64 image/document attachment | [LeaveRepository.createTeacherLeave](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) & [TeacherLeaveScreen](file:///d:/flutter/Projects/sms/lib/features/teacher/leave/teacher_leave_screen.dart) |
| `POST` | `/leaves` | Apply parent leave on behalf of student (`studentId`) with optional attachment | [LeaveRepository.createParentLeave](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) & [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) |
| `GET` | `/leaves?applicantType=STUDENT` | List student leave requests (supports `STUDENT` and `STUDEN`) | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) & [LeaveBloc](file:///d:/flutter/Projects/sms/lib/features/parent/bloc/leave_bloc.dart) |
| `GET` | `/leaves?applicantType=TEACHER` | List teacher own leave requests | [TeacherLeaveScreen](file:///d:/flutter/Projects/sms/lib/features/teacher/leave/teacher_leave_screen.dart) & [LeaveBloc](file:///d:/flutter/Projects/sms/lib/features/parent/bloc/leave_bloc.dart) |
| `GET` | `/leaves/{id}` | Inspect leave request details | [LeaveRepository.getLeaveById](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) |
| `PATCH` | `/leaves/{id}/status` | Teacher approve student leave request with optional remark | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) |
| `PATCH` | `/leaves/{id}/status` | Teacher reject student leave request with reason | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) |
| `DELETE` | `/leaves/{id}` | Delete requester pending leave request | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) |

### 3. Student Switch & Parent Dashboard Endpoints (`/parent`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/parent/switch-student` | Switch active child/student context | [StudentSwitchRepository](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/student_switch_repository.dart) & [ParentBloc](file:///d:/flutter/Projects/sms/lib/features/parent/bloc/parent_bloc.dart) |
| `GET` | `/parent/dashboard/student-attendance?studentId={id}` | Student attendance summary with attendance rate and records | [ParentExamRepository.getStudentAttendanceDashboard](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/parent_exam_repository.dart) |
| `GET` | `/parent/dashboard/upcoming-exams?studentId={id}&page=1&limit=3` | Upcoming exam schedule and tests for student dashboard | [ParentExamRepository.getUpcomingExamsDashboard](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/parent_exam_repository.dart) |

### 4. Teacher Attendance (`/attendance`)
| HTTP Method | Endpoint | Description | Implementation & Requirements |
|---|---|---|---|
| `POST` | `/attendance/check-in` | Real-time teacher check-in | [TeacherAttendanceRepository.checkIn](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) — Front-camera selfie file & live GPS coordinates (`latitude`, `longitude`) |
| `POST` | `/attendance/check-out` | Real-time teacher check-out | [TeacherAttendanceRepository.checkOut](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) — Live GPS location capture |
| `GET` | `/attendance/recent` | Fetch today's / recent attendance record | [TeacherAttendanceRepository.getRecentAttendance](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) |
| `GET` | `/attendance/my-attendance` | History with date filters (`startDate`, `endDate`) | [TeacherAttendanceRepository.getMyAttendanceHistory](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) |

### 5. Timetable Endpoints (`/timetable`, `/academic-calendar/sessions`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/academic-calendar/sessions` | Fetch active academic year session UUID | [TimetableRepository.fetchActiveSessionId](file:///d:/flutter/Projects/sms/lib/features/shared/repositories/timetable_repository.dart) |
| `GET` | `/timetable/?academicYearId={id}` | Full school schedule grouped by weekdays (Monday–Saturday) | [TimetableRepository.getWeeklyTimetable](file:///d:/flutter/Projects/sms/lib/features/shared/repositories/timetable_repository.dart) |
| `GET` | `/timetable/export/pdf?academicYearId={id}` | Export full school timetable to PDF format | [TimetableRepository.exportTimetablePdf](file:///d:/flutter/Projects/sms/lib/features/shared/repositories/timetable_repository.dart) |
| `GET` | `/parent/home/timetable` | Parent full weekday timetable schedule screen | [ParentTimetableScreen](file:///d:/flutter/Projects/sms/lib/features/parent/schedule/parent_timetable_screen.dart) |
| `GET` | `/teacher/schedule` | Teacher full weekday weekly timetable screen | [TeacherWeeklyScheduleScreen](file:///d:/flutter/Projects/sms/lib/features/teacher/schedule/teacher_weekly_schedule_screen.dart) |

### 6. Parent Fees & School Bank Details Endpoints (`/parent/fees`, `/school`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/school/bank-details` | Fetch official school bank account & IBAN info | [ParentFeeRepository.getBankDetails](file:///d:/flutter/Projects/sms/lib/features/parent/fees/repositories/parent_fee_repository.dart) |
| `GET` | `/parent/fees?studentId={id}` | Student fee schedule, applicable fees, monthly summary & latest submission status | [ParentFeeRepository.getFeeDetails](file:///d:/flutter/Projects/sms/lib/features/parent/fees/repositories/parent_fee_repository.dart) & [ParentFeesScreen](file:///d:/flutter/Projects/sms/lib/features/parent/fees/parent_fees_screen.dart) |
| `POST` | `/parent/fees/submit-payment` | Submit / Resubmit deposit receipt verification with amount, payment method, TXN ID & receipt screenshot | [ParentFeeRepository.submitPaymentVerification](file:///d:/flutter/Projects/sms/lib/features/parent/fees/repositories/parent_fee_repository.dart) |

### 7. User Profile Edit (`/api/users`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/api/users/{id}` | Fetch detailed user profile information | [UserRepository.getUserProfile](file:///d:/flutter/Projects/sms/lib/features/shared/repositories/user_repository.dart) |
| `PUT` | `/api/users/{id}` | Update profile details (Name, Contact, CNIC, Blood Group, Address) | [UserRepository.updateUserProfile](file:///d:/flutter/Projects/sms/lib/features/shared/repositories/user_repository.dart) & [EditProfileDialog](file:///d:/flutter/Projects/sms/lib/features/shared/widgets/edit_profile_dialog.dart) |

### 8. Academic Calendar Endpoints (`/academic-calendar`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/academic-calendar/events` | List campus events, holidays, examinations, vacations | [AcademicCalendarRepository.getEvents](file:///d:/flutter/Projects/sms/lib/features/parent/calendar/repositories/academic_calendar_repository.dart) |
| `GET` | `/academic-calendar/sessions` | List active and upcoming school academic sessions | [AcademicCalendarRepository.getSessions](file:///d:/flutter/Projects/sms/lib/features/parent/calendar/repositories/academic_calendar_repository.dart) |
| `GET` | `/academic-calendar/events/{id}` | Fetch individual event details | [AcademicCalendarRepository.getEventDetails](file:///d:/flutter/Projects/sms/lib/features/parent/calendar/repositories/academic_calendar_repository.dart) |

### 9. Notifications Endpoints (`/notifications`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/notifications` | Fetch paginated notifications with unread count and category filters | [NotificationRepository.getNotifications](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) & Notifications Screens |
| `PATCH` | `/notifications/{id}/read` | Mark single notification as read | [NotificationRepository.markAsRead](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |
| `PATCH` | `/notifications/mark-all-read` | Mark all notifications as read | [NotificationRepository.markAllAsRead](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |
| `POST` | `/notifications/fcm-token` | Register or update FCM device push token with platform info (invoked only when authenticated) | [NotificationRepository.registerFcmToken](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |
| `DELETE` | `/notifications/fcm-token` | Unregister FCM token on logout | [NotificationRepository.unregisterFcmToken](file:///d:/flutter/Projects/sms/lib/features/parent/notifications/repositories/notification_repository.dart) |

### 10. Teacher Assessments & Parent Exams
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `GET` | `/teacher/tests` | List created tests, quizzes, and assessments | [TeacherAssessmentRepository.getTests](file:///d:/flutter/Projects/sms/lib/features/teacher/marks/repositories/teacher_assessment_repository.dart) |
| `POST` | `/teacher/tests` | Create new assessment (Quiz, Midterm, Final, Test, Assignment) | [TeacherAssessmentRepository.createTest](file:///d:/flutter/Projects/sms/lib/features/teacher/marks/repositories/teacher_assessment_repository.dart) |
| `PUT` | `/teacher/marks/tests/{id}` | Save draft marks for student roster | [TeacherAssessmentRepository.saveMarksDraft](file:///d:/flutter/Projects/sms/lib/features/teacher/marks/repositories/teacher_assessment_repository.dart) |
| `POST` | `/teacher/marks/tests/{id}/submit` | Submit marks for grading | [TeacherAssessmentRepository.submitMarks](file:///d:/flutter/Projects/sms/lib/features/teacher/marks/repositories/teacher_assessment_repository.dart) |
| `GET` | `/parent/exams` | View student exam schedule and published marks | [ParentExamRepository.getStudentExamsRaw](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/parent_exam_repository.dart) |

---

## 2. Configuration & Networking

Default base URL is configured in [`api_constants.dart`](file:///d:/flutter/Projects/sms/lib/core/network/api_constants.dart):
- **Live Production Server**: `https://api.nexira.pk/api`

### Centralized Session Cache & Security
- **Strict Pre-Login Authentication Gating**: APIs requiring authorization headers are blocked client-side in [AuthInterceptor](file:///d:/flutter/Projects/sms/lib/core/network/auth_interceptor.dart) if no active access token exists, completely eliminating pre-login 401 unauthorized errors.
- **Smart Network Error Translation**: Network layer translates low-level `SocketException`, `DioExceptionType.connectionError`, and DNS failures into user-friendly messages with active retry triggers.
- **High-Visibility Debug Console API Logger**: Every HTTP call, URI, method, headers, query parameters, request body, response status, response body, and error messages are clearly output to the debug console via [AppApiLogInterceptor](file:///d:/flutter/Projects/sms/lib/core/network/api_log_interceptor.dart) using `dart:developer` `log()`.
- **FCM Token Auto-Sync**: On app start, the generated device FCM token is retrieved and printed with a high-visibility banner in the debug console, and registered with the server once an authenticated session is established.
- **Parent Child Switcher & Leave Auto-Targeting**: In the Parent flow, children from the login response `user.students` are displayed as interactive chips. Selecting a child activates `/parent/switch-student` and reloads all fee schedules, attendance records, marks, and calendar events.
- **Access & Refresh Tokens**: Secured in OS keychain/keystore via `flutter_secure_storage`.
- **Active Student & Profile**: Persisted in `shared_preferences` and synced dynamically upon child selection.
- **Session Expiry**: When refresh token expires or is rejected, session is wiped and user is cleanly redirected to login.

---

## 3. Quick Demo Credentials

| Role | Email / ID | Password | Target Flow |
|---|---|---|---|
| **Teacher** | `annemarie.mertens.kgs@school.com` | `password123**` | Direct Teacher Dashboard, Weekly Timetable, Attendance Punch & Assessment Management |
| **Parent** | `parent.torres.1@gmail.com` | `password123**` | Direct Parent Dashboard with Child Switching, Live Fees, Timetable & Exams |

---

## 4. Verification Commands

```bash
# Verify static analysis (0 errors, 0 warnings, 0 infos)
dart analyze lib/ test/

# Run unit and contract test suites (All tests passing)
flutter test

# Run the app on device
flutter run
```
