import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'features/teacher/attendance/repositories/teacher_attendance_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionStorage = SessionStorageService();
  await sessionStorage.init();

  await FcmService.initialize(storageService: sessionStorage);

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

  final leaveRepository = LeaveRepository(
    apiClient: apiClient,
  );

  final studentSwitchRepository = StudentSwitchRepository(
    apiClient: apiClient,
    storageService: sessionStorage,
  );

  final teacherAttendanceRepository = TeacherAttendanceRepository(
    apiClient: apiClient,
  );

  runApp(
    SchoolManagementApp(
      authRepository: authRepository,
      leaveRepository: leaveRepository,
      studentSwitchRepository: studentSwitchRepository,
      teacherAttendanceRepository: teacherAttendanceRepository,
    ),
  );
}

class SchoolManagementApp extends StatelessWidget {
  final AuthRepository authRepository;
  final LeaveRepository leaveRepository;
  final StudentSwitchRepository studentSwitchRepository;
  final TeacherAttendanceRepository teacherAttendanceRepository;

  const SchoolManagementApp({
    super.key,
    required this.authRepository,
    required this.leaveRepository,
    required this.studentSwitchRepository,
    required this.teacherAttendanceRepository,
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              authRepository: authRepository,
            )..add(const CheckAuthSessionEvent()),
          ),
          BlocProvider<LeaveBloc>(
            create: (_) => LeaveBloc(
              leaveRepository: leaveRepository,
            ),
          ),
          BlocProvider<TeacherBloc>(
            create: (_) => TeacherBloc(
              attendanceRepository: teacherAttendanceRepository,
            ),
          ),
          BlocProvider<ParentBloc>(
            create: (_) => ParentBloc(
              studentSwitchRepository: studentSwitchRepository,
            ),
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
