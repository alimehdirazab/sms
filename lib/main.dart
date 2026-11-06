import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/network/api_client.dart';
import 'core/storage/session_storage_service.dart';
import 'core/notifications/fcm_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/teacher/bloc/teacher_bloc.dart';
import 'features/parent/bloc/parent_bloc.dart';
import 'features/parent/bloc/leave_bloc.dart';
import 'features/parent/repositories/leave_repository.dart';
import 'features/parent/repositories/student_switch_repository.dart';
import 'features/parent/fees/repositories/parent_fee_repository.dart';
import 'features/parent/calendar/repositories/academic_calendar_repository.dart';
import 'features/parent/notifications/repositories/notification_repository.dart';
import 'features/teacher/attendance/repositories/teacher_attendance_repository.dart';
import 'features/teacher/schedule/repositories/teacher_timetable_repository.dart';
import 'features/announcements/bloc/announcement_bloc.dart';
import 'features/announcements/repositories/announcement_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent GoogleFonts from attempting network calls to fonts.gstatic.com (uses local assets)
  GoogleFonts.config.allowRuntimeFetching = false;

  final sessionStorage = SessionStorageService();
  await sessionStorage.init();

  await FcmService.initialize(storageService: sessionStorage);
  final fcmToken = await FcmService.getToken(storageService: sessionStorage);
  log('====================================================', name: 'MAIN');
  log('🔥 [FCM TOKEN ON APP START]: $fcmToken', name: 'MAIN');
  log('====================================================', name: 'MAIN');
  final apiClient = ApiClient(
    storageService: sessionStorage,
    onSessionExpired: () {
      appRouter.goNamed(RouteNames.login);
    },
  );

  final authRepository = AuthRepository(
    apiClient: apiClient,
    storageService: sessionStorage,
  );

  final leaveRepository = LeaveRepository(apiClient: apiClient);

  final studentSwitchRepository = StudentSwitchRepository(
    apiClient: apiClient,
    storageService: sessionStorage,
  );

  final teacherAttendanceRepository = TeacherAttendanceRepository(
    apiClient: apiClient,
  );

  final teacherTimetableRepository = TeacherTimetableRepository(
    apiClient: apiClient,
  );

  final parentFeeRepository = ParentFeeRepository(apiClient: apiClient);

  final academicCalendarRepository = AcademicCalendarRepository(
    apiClient: apiClient,
  );

  final notificationRepository = NotificationRepository(apiClient: apiClient);
  final announcementRepository = AnnouncementRepository(apiClient: apiClient);

  // Register FCM token only when user is authenticated with an active session
  FcmService.addTokenListener((token) async {
    final accessToken = await sessionStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      notificationRepository.registerFcmToken(token);
    }
  });

  runApp(
    SchoolManagementApp(
      authRepository: authRepository,
      leaveRepository: leaveRepository,
      studentSwitchRepository: studentSwitchRepository,
      teacherAttendanceRepository: teacherAttendanceRepository,
      teacherTimetableRepository: teacherTimetableRepository,
      parentFeeRepository: parentFeeRepository,
      academicCalendarRepository: academicCalendarRepository,
      notificationRepository: notificationRepository,
      announcementRepository: announcementRepository,
    ),
  );
}

class SchoolManagementApp extends StatelessWidget {
  final AuthRepository authRepository;
  final LeaveRepository leaveRepository;
  final StudentSwitchRepository studentSwitchRepository;
  final TeacherAttendanceRepository teacherAttendanceRepository;
  final TeacherTimetableRepository teacherTimetableRepository;
  final ParentFeeRepository parentFeeRepository;
  final AcademicCalendarRepository academicCalendarRepository;
  final NotificationRepository notificationRepository;
  final AnnouncementRepository announcementRepository;

  const SchoolManagementApp({
    super.key,
    required this.authRepository,
    required this.leaveRepository,
    required this.studentSwitchRepository,
    required this.teacherAttendanceRepository,
    required this.teacherTimetableRepository,
    required this.parentFeeRepository,
    required this.academicCalendarRepository,
    required this.notificationRepository,
    required this.announcementRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<LeaveRepository>.value(value: leaveRepository),
        RepositoryProvider<StudentSwitchRepository>.value(
          value: studentSwitchRepository,
        ),
        RepositoryProvider<TeacherAttendanceRepository>.value(
          value: teacherAttendanceRepository,
        ),
        RepositoryProvider<TeacherTimetableRepository>.value(
          value: teacherTimetableRepository,
        ),
        RepositoryProvider<ParentFeeRepository>.value(
          value: parentFeeRepository,
        ),
        RepositoryProvider<AcademicCalendarRepository>.value(
          value: academicCalendarRepository,
        ),
        RepositoryProvider<NotificationRepository>.value(
          value: notificationRepository,
        ),
        RepositoryProvider<AnnouncementRepository>.value(
          value: announcementRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(authRepository: authRepository)
                  ..add(const CheckAuthSessionEvent()),
          ),
          BlocProvider<LeaveBloc>(
            create: (_) => LeaveBloc(leaveRepository: leaveRepository),
          ),
          BlocProvider<TeacherBloc>(
            create: (_) => TeacherBloc(
              attendanceRepository: teacherAttendanceRepository,
              timetableRepository: teacherTimetableRepository,
              calendarRepository: academicCalendarRepository,
              notificationRepository: notificationRepository,
            ),
          ),
          BlocProvider<ParentBloc>(
            create: (_) => ParentBloc(
              studentSwitchRepository: studentSwitchRepository,
              feeRepository: parentFeeRepository,
              calendarRepository: academicCalendarRepository,
              notificationRepository: notificationRepository,
            ),
          ),
          BlocProvider<AnnouncementBloc>(
            create: (_) =>
                AnnouncementBloc(repository: announcementRepository),
          ),
        ],
        child: MaterialApp.router(
          title: 'School Management System',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
