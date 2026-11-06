import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/teacher_bloc.dart';
import '../attendance/services/location_and_selfie_service.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/animated_button.dart';
import '../../auth/models/attendance_model.dart';
import '../../shared/widgets/academic_calendar_view.dart';
import '../../shared/widgets/progress_charts.dart';
import '../../shared/widgets/stat_card.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  bool _isCheckedIn = false;

  /// Tracks whether the current in-progress check-in is late so we can prompt
  /// the teacher for a short explanatory comment.
  bool _pendingLateComment = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final bloc = context.read<TeacherBloc>();
    bloc.add(LoadTeacherProfile());
    bloc.add(LoadNotificationCount());
    bloc.add(LoadTeacherSchedule());
    bloc.add(LoadTeacherAttendance());
    bloc.add(LoadTeacherAnalytics());
    bloc.add(LoadTeacherCalendar());
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Teacher dashboard',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Announcements',
            icon: const Icon(Icons.campaign_outlined, size: 20),
            onPressed: () => context.pushNamed(RouteNames.teacherAnnouncements),
          ),
          IconButton(
            tooltip: 'Weekly timetable',
            icon: const Icon(Icons.calendar_view_week_rounded, size: 20),
            onPressed: () =>
                context.pushNamed(RouteNames.teacherWeeklySchedule),
          ),
          BlocBuilder<TeacherBloc, TeacherState>(
            buildWhen: (_, state) => state is TeacherNotificationCountLoaded,
            builder: (context, state) {
              final count = state is TeacherNotificationCountLoaded
                  ? state.count
                  : 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'Campus notifications',
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                    ),
                    onPressed: () =>
                        context.pushNamed(RouteNames.teacherNotifications),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 10,
                      top: 12,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Date (Editorial Typography)
              BlocBuilder<TeacherBloc, TeacherState>(
                buildWhen: (_, state) => state is TeacherProfileLoaded,
                builder: (context, state) {
                  final name = state is TeacherProfileLoaded
                      ? state.profile.name
                      : 'Teacher';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormatter.getGreeting()},',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        style: GoogleFonts.instrumentSerif(
                          fontSize: 26,
                          fontWeight: FontWeight.normal,
                          color: AppColors.ink,
                          letterSpacing: -0.02 * 26,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormatter.formatDay(now)}, ${DateFormatter.formatDate(now)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Check-in/out verification card
              _buildCheckInOutSection(),
              const SizedBox(height: 18),

              // Quick actions (White cards with hairline borders)
              _buildQuickActions(),
              const SizedBox(height: 20),

              // Attendance & marks analytics
              _buildAnalyticsSection(),
              const SizedBox(height: 20),

              // Academic calendar preview
              _buildCalendarPreview(),
              const SizedBox(height: 20),

              // Today's Schedule
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Today's schedule",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.pushNamed(RouteNames.teacherWeeklySchedule),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Full week'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildScheduleSection(),
              const SizedBox(height: 20),

              // Recent Attendance
              Text(
                'Recent attendance',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              _buildRecentAttendance(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.event_available_outlined,
            label: 'Apply leave',
            onTap: () => context.pushNamed(RouteNames.teacherLeave),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_view_week_outlined,
            label: 'Timetable',
            onTap: () =>
                context.pushNamed(RouteNames.teacherWeeklySchedule),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_month_outlined,
            label: 'Calendar',
            onTap: () => context.pushNamed(RouteNames.teacherCalendar),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return BlocBuilder<TeacherBloc, TeacherState>(
      buildWhen: (_, state) => state is TeacherAnalyticsLoaded,
      builder: (context, state) {
        if (state is! TeacherAnalyticsLoaded) {
          return const ShimmerCard(height: 220);
        }
        final a = state.analytics;
        final status = AppStatusColors.of(context);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'My attendance',
                    value: '${a.attendancePercentage.toStringAsFixed(0)}%',
                    icon: Icons.fact_check_outlined,
                    color: a.attendancePercentage >= 85
                        ? status.success
                        : status.warning,
                    caption: '${a.presentDays} present · ${a.lateDays} late',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Class average',
                    value: '${a.classAverage.toStringAsFixed(1)}%',
                    icon: Icons.groups_outlined,
                    color: status.info,
                    caption: 'Across assigned classes',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Attendance trajectory',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily presence over the last 6 working days',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MiniBarChart(
                    labels: a.weekdayLabels,
                    values: a.weekdayAttendance,
                    color: AppColors.accent,
                    height: 150,
                  ),
                  const Divider(height: 28),
                  Text(
                    'Average marks by class',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MiniBarChart(
                    labels: a.subjectLabels,
                    values: a.subjectAverages,
                    color: AppColors.accent,
                    height: 140,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarPreview() {
    return BlocBuilder<TeacherBloc, TeacherState>(
      buildWhen: (_, state) => state is TeacherCalendarLoaded,
      builder: (context, state) {
        if (state is! TeacherCalendarLoaded) {
          return const ShimmerCard(height: 140);
        }
        if (state.events.isEmpty) return const SizedBox.shrink();
        final now = DateTime.now();
        final upcoming = state.events
            .where((e) => e.startsOnOrAfter(now))
            .take(3)
            .toList();
        final toShow = upcoming.isNotEmpty
            ? upcoming
            : state.events.take(3).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Academic calendar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.pushNamed(RouteNames.teacherCalendar),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...toShow.map((e) => CalendarEventTile(event: e, dense: true)),
            ],
          ),
        );
      },
    );
  }

  void _promptLateComment() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Running late?',
          style: GoogleFonts.instrumentSerif(
            fontSize: 22,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are checking in late. Add a short comment for the record (optional).',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.inkSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g., Traffic delay on the highway',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () {
              final comment = controller.text.trim();
              if (comment.isNotEmpty) {
                context.read<TeacherBloc>().add(
                  AddLateCheckInComment('att_today', comment),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save comment'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckInFlow() async {
    final locationService = LocationAndSelfieService();

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.accent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Check-in verification',
              style: GoogleFonts.instrumentSerif(
                fontSize: 22,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: Text(
          'To check in, the app will verify your real-time GPS location and require a selfie photo as proof of attendance.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.inkSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.camera_front_rounded, size: 16),
            label: const Text('Take selfie & check in'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    try {
      final File? selfieFile = await locationService.captureSelfie();
      if (selfieFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selfie is mandatory for attendance check-in.'),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Acquiring real-time GPS location...'),
              ],
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }

      final loc = await locationService.getCurrentRealLocation();

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      context.read<TeacherBloc>().add(
        PerformCheckIn(
          latitude: loc.latitude,
          longitude: loc.longitude,
          accuracy: loc.accuracy,
          selfieFile: selfieFile,
        ),
      );
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.danger,
            action: e.isServiceDisabled
                ? SnackBarAction(
                    label: 'Turn on GPS',
                    textColor: Colors.white,
                    onPressed: () => locationService.openLocationSettings(),
                  )
                : (e.isPermanentlyDenied
                      ? SnackBarAction(
                          label: 'Settings',
                          textColor: Colors.white,
                          onPressed: () => locationService.openAppSettings(),
                        )
                      : null),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckOutFlow() async {
    final locationService = LocationAndSelfieService();
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Verifying real-time GPS for check-out...'),
              ],
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }

      final loc = await locationService.getCurrentRealLocation();
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      context.read<TeacherBloc>().add(
        PerformCheckOut(
          latitude: loc.latitude,
          longitude: loc.longitude,
          accuracy: loc.accuracy,
        ),
      );
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.danger,
            action: e.isServiceDisabled
                ? SnackBarAction(
                    label: 'Turn on GPS',
                    textColor: Colors.white,
                    onPressed: () => locationService.openLocationSettings(),
                  )
                : (e.isPermanentlyDenied
                      ? SnackBarAction(
                          label: 'Settings',
                          textColor: Colors.white,
                          onPressed: () => locationService.openAppSettings(),
                        )
                      : null),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildCheckInOutSection() {
    final status = AppStatusColors.of(context);
    return BlocConsumer<TeacherBloc, TeacherState>(
      listenWhen: (_, state) =>
          state is TeacherCheckInSuccess ||
          state is TeacherCheckInError ||
          state is TeacherLateCommentSaved ||
          state is TeacherAttendanceLoaded,
      listener: (context, state) {
        if (state is TeacherAttendanceLoaded && state.records.isNotEmpty) {
          final now = DateTime.now();
          final todayRecord = state.records.cast<AttendanceModel?>().firstWhere(
            (r) =>
                r != null &&
                r.date.year == now.year &&
                r.date.month == now.month &&
                r.date.day == now.day,
            orElse: () => null,
          );
          if (todayRecord != null) {
            setState(() {
              _isCheckedIn =
                  todayRecord.checkInTime != null &&
                  todayRecord.checkOutTime == null;
            });
          }
        } else if (state is TeacherCheckInSuccess) {
          final wasLate = _pendingLateComment;
          setState(() {
            _isCheckedIn = state.checkedIn;
            _pendingLateComment = false;
          });
          final message = state.checkedIn
              ? (wasLate
                    ? 'Checked in (late). Please add a comment.'
                    : 'Check-in successful! Verified inside campus.')
              : 'Check-out successful!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.accent),
          );
          if (state.checkedIn && wasLate) {
            _promptLateComment();
          }
        } else if (state is TeacherCheckInError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        } else if (state is TeacherLateCommentSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment saved to attendance record.'),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TeacherCheckInLoading;
        final geofenceInside = state is! TeacherCheckInError;
        final now = DateTime.now();
        final isLateNow = now.hour > 8 || (now.hour == 8 && now.minute > 30);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: geofenceInside ? status.success : status.danger,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      geofenceInside
                          ? 'Inside school zone'
                          : 'Outside school zone',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: geofenceInside ? status.success : status.danger,
                      ),
                    ),
                  ),
                  if (!_isCheckedIn && isLateNow)
                    StatusDot(label: 'Late check-in', color: status.warning),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedBouncyButton(
                label: isLoading
                    ? 'Processing...'
                    : (_isCheckedIn ? 'Check out' : 'Check in'),
                icon: isLoading
                    ? null
                    : (_isCheckedIn
                          ? Icons.logout_rounded
                          : Icons.login_rounded),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_isCheckedIn) {
                          _handleCheckOutFlow();
                        } else {
                          _pendingLateComment = isLateNow;
                          _handleCheckInFlow();
                        }
                      },
                backgroundColor: _isCheckedIn
                    ? AppColors.surface
                    : AppColors.accent,
                foregroundColor: _isCheckedIn ? AppColors.danger : Colors.white,
                variant: _isCheckedIn
                    ? EduCoreButtonVariant.destructive
                    : EduCoreButtonVariant.primary,
              ),
              if (isLoading) ...[
                const SizedBox(height: 12),
                Text(
                  'Verifying location & face...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 8),
                const LinearProgressIndicator(
                  backgroundColor: AppColors.surfaceInset,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleSection() {
    return BlocBuilder<TeacherBloc, TeacherState>(
      buildWhen: (_, state) =>
          state is TeacherScheduleLoaded || state is TeacherScheduleLoading,
      builder: (context, state) {
        if (state is TeacherScheduleLoading) {
          return const ShimmerCard(height: 150);
        }
        if (state is TeacherScheduleLoaded) {
          if (state.schedule.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Center(
                child: Text(
                  'No classes scheduled today.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: AppShadows.subtle,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.schedule.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = state.schedule[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInset,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: const Icon(
                      Icons.book_outlined,
                      size: 18,
                      color: AppColors.accent,
                    ),
                  ),
                  title: Text(
                    item.subject,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  subtitle: Text(
                    '${item.className} · ${DateFormatter.formatTime(item.startTime)} - ${DateFormatter.formatTime(item.endTime)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const ShimmerCard(height: 150);
      },
    );
  }

  Widget _buildRecentAttendance() {
    return BlocBuilder<TeacherBloc, TeacherState>(
      buildWhen: (_, state) =>
          state is TeacherAttendanceLoaded || state is TeacherAttendanceLoading,
      builder: (context, state) {
        if (state is TeacherAttendanceLoading) {
          return const ShimmerCard(height: 120);
        }
        if (state is TeacherAttendanceLoaded) {
          final recent = state.records.take(5).toList();
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: AppShadows.subtle,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
              itemBuilder: (context, index) {
                final record = recent[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: _buildStatusIcon(record.status),
                  title: Text(
                    DateFormatter.formatDate(record.date),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  subtitle: Text(
                    'In: ${record.checkInTime != null ? DateFormatter.formatTime(record.checkInTime!) : '--'} · Out: ${record.checkOutTime != null ? DateFormatter.formatTime(record.checkOutTime!) : '--'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  trailing: StatusDot.semantic(
                    context,
                    label: _statusSentenceCase(record.status),
                    kind: record.status.name,
                  ),
                );
              },
            ),
          );
        }
        return const ShimmerCard(height: 120);
      },
    );
  }

  String _statusSentenceCase(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }

  Widget _buildStatusIcon(AttendanceStatus status) {
    final (color, icon) = switch (status) {
      AttendanceStatus.present => (
        AppColors.success,
        Icons.check_circle_outline_rounded,
      ),
      AttendanceStatus.late => (AppColors.warning, Icons.access_time_rounded),
      AttendanceStatus.absent => (
        AppColors.danger,
        Icons.highlight_off_rounded,
      ),
    };
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accentTint,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.infoBorder, width: 1),
                ),
                child: Icon(icon, color: AppColors.accent, size: 19),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
