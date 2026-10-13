import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/role_selection/role_selection_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/parent_login_screen.dart';
import '../../features/auth/screens/teacher_login_screen.dart';
import '../../features/teacher/home/teacher_home_screen.dart';
import '../../features/teacher/attendance/teacher_attendance_screen.dart';
import '../../features/teacher/marks/teacher_marks_screen.dart';
import '../../features/teacher/profile/teacher_profile_screen.dart';
import '../../features/parent/home/parent_home_screen.dart';
import '../../features/parent/marks/parent_marks_screen.dart';
import '../../features/parent/notifications/parent_notifications_screen.dart';
import '../../features/parent/profile/parent_profile_screen.dart';
import '../../features/parent/leave/parent_leave_screen.dart';
import '../../features/parent/fees/parent_fees_screen.dart';
import '../../features/parent/calendar/parent_calendar_screen.dart';
import '../../features/teacher/leave/teacher_leave_screen.dart';
import '../../features/teacher/calendar/teacher_calendar_screen.dart';
import '../../features/teacher/schedule/teacher_weekly_schedule_screen.dart';

class RouteNames {
  static const splash = 'splash';
  static const roleSelection = 'roleSelection';
  static const parentLogin = 'parentLogin';
  static const teacherLogin = 'teacherLogin';
  static const teacherShell = 'teacherShell';
  static const teacherHome = 'teacherHome';
  static const teacherAttendance = 'teacherAttendance';
  static const teacherMarks = 'teacherMarks';
  static const teacherProfile = 'teacherProfile';
  static const teacherLeave = 'teacherLeave';
  static const teacherCalendar = 'teacherCalendar';
  static const teacherWeeklySchedule = 'teacherWeeklySchedule';
  static const parentShell = 'parentShell';
  static const parentHome = 'parentHome';
  static const parentMarks = 'parentMarks';
  static const parentNotifications = 'parentNotifications';
  static const parentProfile = 'parentProfile';
  static const parentLeave = 'parentLeave';
  static const parentFees = 'parentFees';
  static const parentCalendar = 'parentCalendar';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      pageBuilder: (context, state) =>
          _buildPageWithTransition(child: const SplashScreen(), state: state),
    ),
    GoRoute(
      path: '/role-selection',
      name: RouteNames.roleSelection,
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const RoleSelectionScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/parent-login',
      name: RouteNames.parentLogin,
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const ParentLoginScreen(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/teacher-login',
      name: RouteNames.teacherLogin,
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const TeacherLoginScreen(),
        state: state,
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return TeacherShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teacher/home',
              name: RouteNames.teacherHome,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TeacherHomeScreen()),
              routes: [
                GoRoute(
                  path: 'leave',
                  name: RouteNames.teacherLeave,
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    child: const TeacherLeaveScreen(),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'calendar',
                  name: RouteNames.teacherCalendar,
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    child: const TeacherCalendarScreen(),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'schedule',
                  name: RouteNames.teacherWeeklySchedule,
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    child: const TeacherWeeklyScheduleScreen(),
                    state: state,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teacher/attendance',
              name: RouteNames.teacherAttendance,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TeacherAttendanceScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teacher/marks',
              name: RouteNames.teacherMarks,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TeacherMarksScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/teacher/profile',
              name: RouteNames.teacherProfile,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TeacherProfileScreen()),
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ParentShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/parent/home',
              name: RouteNames.parentHome,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ParentHomeScreen()),
              routes: [
                GoRoute(
                  path: 'leave',
                  name: RouteNames.parentLeave,
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    child: const ParentLeaveScreen(),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'fees',
                  name: RouteNames.parentFees,
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    child: const ParentFeesScreen(),
                    state: state,
                  ),
                ),
                GoRoute(
                  path: 'calendar',
                  name: RouteNames.parentCalendar,
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    child: const ParentCalendarScreen(),
                    state: state,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/parent/marks',
              name: RouteNames.parentMarks,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ParentMarksScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/parent/notifications',
              name: RouteNames.parentNotifications,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ParentNotificationsScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/parent/profile',
              name: RouteNames.parentProfile,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ParentProfileScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);

CustomTransitionPage _buildPageWithTransition({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

class TeacherShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const TeacherShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade_outlined),
            activeIcon: Icon(Icons.grade),
            label: 'Marks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ParentShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ParentShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade_outlined),
            activeIcon: Icon(Icons.grade),
            label: 'Marks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
