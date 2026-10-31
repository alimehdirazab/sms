# School Management System (SMS) — Flutter Mobile App

A production-ready Flutter mobile application combining **Parent** and **Teacher** flows with end-to-end integration of the complete **"School" API / Postman Collection** (`74722100-06b1-43c6-b856-8289ca743ee7`). Built strictly using **Clean BLoC Architecture**, **Bulletproof Data Models**, **Dio Interceptors with Seamless Token Refresh**, and **Material 3 Design**.

---

## 0. Quality & Verification Status

- ✅ `flutter analyze` → **No issues found! (0 errors, 0 warnings, 0 infos)**
- ✅ `flutter test` → **All test suites passed (100% contract and model safety)**
- ✅ **Zero Null-Crash Guarantee**: Safe fallbacks for missing, partial, or malformed JSON responses.
- ✅ **Automated 401 Mutex Token Refresh**: Requests queue during refresh and retry seamlessly without forced logout.

---

## 1. Postman Collection Integration Overview

Every endpoint from the School Postman Collection is connected end-to-end:

### Auth Endpoints (`/auth`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/auth/login` | Login with email and password | [AuthRepository.login](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) & [AuthBloc](file:///d:/flutter/Projects/sms/lib/features/auth/bloc/auth_bloc.dart) |
| `POST` | `/auth/refresh` | Seamless access token refresh | [AuthInterceptor](file:///d:/flutter/Projects/sms/lib/core/network/auth_interceptor.dart) & [AuthRepository.refreshToken](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/forgot-password` | Request password reset instructions | [ForgotPasswordScreen](file:///d:/flutter/Projects/sms/lib/features/auth/screens/forgot_password_screen.dart) & [AuthRepository.forgotPassword](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/reset-password` | Reset password using reset token | [ResetPasswordScreen](file:///d:/flutter/Projects/sms/lib/features/auth/screens/reset_password_screen.dart) & [AuthRepository.resetPassword](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |
| `POST` | `/auth/logout` | Server session invalidation & token wipe | [AuthRepository.logout](file:///d:/flutter/Projects/sms/lib/features/auth/repositories/auth_repository.dart) |

### Leave Management Endpoints (`/leaves`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/leaves` | Apply teacher leave (Casual/Sick/Medical/Emergency) | [LeaveRepository.createTeacherLeave](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) |
| `POST` | `/leaves` | Apply parent leave on behalf of student | [LeaveRepository.createParentLeave](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) |
| `GET` | `/leaves` | List leaves with filters (`status`, `page`, `limit`, etc.) | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) & [LeaveBloc](file:///d:/flutter/Projects/sms/lib/features/parent/bloc/leave_bloc.dart) |
| `GET` | `/leaves/{id}` | Inspect leave request details | [LeaveRepository.getLeaveById](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/leave_repository.dart) |
| `PATCH` | `/leaves/{id}/status` | Approve pending leave with reason | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) (`Approve` dialog) |
| `PATCH` | `/leaves/{id}/status` | Reject pending leave with reason | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) (`Reject` dialog) |
| `DELETE` | `/leaves/{id}` | Delete requester pending leave | [LeavesManagementScreen](file:///d:/flutter/Projects/sms/lib/features/parent/leave/leaves_management_screen.dart) (`Delete` button) |

### Teacher Attendance Endpoints (`/attendance`) — School ERP Auth & Attendance API (`d5e06b53-163f-49e2-994c-5510329e0f7e`)
| HTTP Method | Endpoint | Description | Implementation & Requirements |
|---|---|---|---|
| `POST` | `/attendance/check-in` | Real-time teacher check-in | [TeacherAttendanceRepository.checkIn](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) — **Mandatory front-camera selfie** (`base64`) & **Live GPS Coordinates** (`latitude`, `longitude`, `accuracy`) via [LocationAndSelfieService](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/services/location_and_selfie_service.dart) |
| `POST` | `/attendance/check-out` | Real-time teacher check-out | [TeacherAttendanceRepository.checkOut](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) — Live GPS location capture |
| `GET` | `/attendance/recent` | Fetch current / today's attendance record | [TeacherAttendanceRepository.getRecentAttendance](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) |
| `GET` | `/attendance/my-attendance` | History with date filters (`startDate`, `endDate`) | [TeacherAttendanceRepository.getMyAttendanceHistory](file:///d:/flutter/Projects/sms/lib/features/teacher/attendance/repositories/teacher_attendance_repository.dart) |

### Student Switch Endpoint (`/parent`)
| HTTP Method | Endpoint | Description | Implementation |
|---|---|---|---|
| `POST` | `/parent/switch-student` | Switch active child/student | [StudentSwitchRepository](file:///d:/flutter/Projects/sms/lib/features/parent/repositories/student_switch_repository.dart) & [ParentBloc](file:///d:/flutter/Projects/sms/lib/features/parent/bloc/parent_bloc.dart) |

---

## 2. Architectural Structure

```
lib/
├── core/
│   ├── network/
│   │   ├── api_constants.dart          # Canonical collection endpoints & Base URL
│   │   ├── api_client.dart             # Centralized Dio HTTP client
│   │   └── auth_interceptor.dart       # Mutex queue, Bearer injector & 401 auto-refresher
│   ├── storage/
│   │   └── session_storage_service.dart# FlutterSecureStorage & SharedPreferences cache
│   ├── routes/
│   │   └── app_router.dart             # GoRouter setup for Parent, Teacher & Auth
│   ├── theme/                          # Material 3 colors & AppStatusColors extension
│   └── widgets/                        # Reusable buttons, shimmers, error states
├── features/
│   ├── auth/
│   │   ├── bloc/auth_bloc.dart         # Authentication state machine
│   │   ├── models/auth_response_model.dart # Safe UserModel & AuthResponseModel
│   │   ├── repositories/auth_repository.dart # Full auth API implementation
│   │   └── screens/                    # Login, OTP, Forgot & Reset Password screens
│   ├── parent/
│   │   ├── bloc/
│   │   │   ├── parent_bloc.dart        # Parent profile, student selector & analytics
│   │   │   └── leave_bloc.dart         # Paginated & reactive leave management BLoC
│   │   ├── models/
│   │   │   └── leave_api_model.dart    # Strongly typed LeaveItemModel & Pagination
│   │   ├── repositories/
│   │   │   ├── leave_repository.dart   # Complete CRUD leave repository
│   │   │   └── student_switch_repository.dart # /parent/switch-student integration
│   │   └── leave/
│   │       └── leaves_management_screen.dart # Filter tabs, create modal, approve/reject/delete
│   └── teacher/
│       ├── bloc/teacher_bloc.dart      # Teacher attendance, marks, schedule & check-in/out
│       ├── attendance/
│       │   ├── models/attendance_api_model.dart # AttendanceRecordModel & AttendanceHistory
│       │   ├── services/location_and_selfie_service.dart # Real GPS & front camera selfie capture
│       │   └── repositories/teacher_attendance_repository.dart # /attendance/check-in, check-out, recent, my-attendance
│       ├── home/teacher_home_screen.dart # Interactive check-in/out flow with selfie preview & GPS status
│       └── ...
│   └── shared/
└── main.dart                           # Top-level DI, Repositories & MultiBlocProvider
```

---

## 3. Configuration & Networking

Default base URL is configured in [`api_constants.dart`](file:///d:/flutter/Projects/sms/lib/core/network/api_constants.dart):
- **Production Server**: `https://school-erp-backend-production-7992.up.railway.app/api`

### Centralized Session Cache
- **Direct Login**: Role selection screen removed. Users enter their credentials on a unified `LoginScreen`, and the app dynamically redirects to either Teacher Home or Parent Home based on `user.role` from the API response.
- **Parent Child Switcher**: In the Parent flow, children from the login response `user.students` are displayed as interactive chips. Selecting a child activates the child switch API (`/parent/switch-student`) and reloads all attendance, marks, and fees.
- **Parent Leave Actions**: In the parent leave section, approve and reject controls are hidden so parents can only submit and delete their own requests.
- **Access & Refresh Tokens**: Secured in OS keychain/keystore via `flutter_secure_storage`.
- **Active Student & Profile**: Persisted in `shared_preferences` and synced dynamically upon child selection.
- **Session Expiry**: When refresh token expires or is rejected, session is wiped and user is cleanly redirected to login.

---

## 4. Quick Demo Credentials

| Role | Email / ID | Password | Target Flow |
|---|---|---|---|
| **Teacher** | `teacher@gmail.com` | `password123` | Direct Teacher Dashboard & Attendance Punch |
| **Parent** | `parent@gmail.com` | `password123` | Direct Parent Dashboard with Child Switching |

---

## 5. Verification Commands

```bash
# Verify static analysis (0 errors, 0 warnings, 0 infos)
flutter analyze

# Run unit and contract test suites
flutter test

# Run the app
flutter run
```
