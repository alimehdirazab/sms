import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/routes/app_router.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Weekly Timetable',
            icon: const Icon(Icons.calendar_view_week),
            onPressed: () =>
                context.pushNamed(RouteNames.teacherWeeklySchedule),
          ),
          BlocBuilder<TeacherBloc, TeacherState>(
            buildWhen: (_, state) => state is TeacherNotificationCountLoaded,
            builder: (context, state) {
              final count =
                  state is TeacherNotificationCountLoaded ? state.count : 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Date
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormatter.formatDay(now)}, ${DateFormatter.formatDate(now)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Check-in/out button
              _buildCheckInOutSection(colorScheme),
              const SizedBox(height: 20),

              // Quick actions
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
                      "Today's Schedule",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.pushNamed(RouteNames.teacherWeeklySchedule),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Full Week'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildScheduleSection(),
              const SizedBox(height: 20),

              // Recent Attendance
              Text(
                'Recent Attendance',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildRecentAttendance(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final status = AppStatusColors.of(context);
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.event_available,
            label: 'Apply Leave',
            color: status.info,
            onTap: () => context.pushNamed(RouteNames.teacherLeave),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_view_week,
            label: 'Week View',
            color: status.success,
            onTap: () => context.pushNamed(RouteNames.teacherWeeklySchedule),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_month,
            label: 'Calendar',
            color: status.warning,
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
        final colorScheme = Theme.of(context).colorScheme;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'My Attendance',
                    value: '${a.attendancePercentage.toStringAsFixed(0)}%',
                    icon: Icons.fact_check_outlined,
                    color: a.attendancePercentage >= 85
                        ? status.success
                        : status.warning,
                    caption: '${a.presentDays} present · ${a.lateDays} late',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Class Average',
                    value: '${a.classAverage.toStringAsFixed(1)}%',
                    icon: Icons.groups_outlined,
                    color: status.info,
                    caption: 'Across my classes',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart, size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attendance Chart',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Daily presence over the last 6 working days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    MiniBarChart(
                      labels: a.weekdayLabels,
                      values: a.weekdayAttendance,
                      color: colorScheme.primary,
                      height: 150,
                    ),
                    const Divider(height: 28),
                    Text(
                      'Average marks by class',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    MiniBarChart(
                      labels: a.subjectLabels,
                      values: a.subjectAverages,
                      color: status.info,
                      height: 140,
                    ),
                  ],
                ),
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
        final upcoming =
            state.events.where((e) => e.startsOnOrAfter(now)).take(3).toList();
        final toShow = upcoming.isNotEmpty
            ? upcoming
            : state.events.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Academic Calendar',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.pushNamed(RouteNames.teacherCalendar),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...toShow.map((e) => CalendarEventTile(event: e, dense: true)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Prompts for an optional comment when a late check-in is detected.
  void _promptLateComment() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Running Late?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are checking in late. Add a short comment for the record (optional).',
            ),
            const SizedBox(height: 12),
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
            child: const Text('Save Comment'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInOutSection(ColorScheme colorScheme) {
    final status = AppStatusColors.of(context);
    return BlocConsumer<TeacherBloc, TeacherState>(
      listenWhen: (_, state) =>
          state is TeacherCheckInSuccess ||
          state is TeacherCheckInError ||
          state is TeacherLateCommentSaved,
      listener: (context, state) {
        if (state is TeacherCheckInSuccess) {
          final wasLate = _pendingLateComment;
          setState(() {
            _isCheckedIn = state.checkedIn;
            _pendingLateComment = false;
          });
          final message = state.checkedIn
              ? (wasLate
                  ? '⏰ Checked in (late). Please add a comment.'
                  : '✅ Check-in successful! Verified & inside geofence.')
              : '👋 Check-out successful!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: colorScheme.primary,
            ),
          );
          if (state.checkedIn && wasLate) {
            _promptLateComment();
          }
        } else if (state is TeacherCheckInError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        } else if (state is TeacherLateCommentSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment saved to attendance record.')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TeacherCheckInLoading;
        final geofenceInside = state is! TeacherCheckInError;
        final now = DateTime.now();
        // A check-in after 08:30 is considered late (mock rule).
        final isLateNow = now.hour > 8 || (now.hour == 8 && now.minute > 30);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: geofenceInside
                            ? status.success
                            : status.danger,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        geofenceInside
                            ? 'Inside School Zone'
                            : 'Outside School Zone',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: geofenceInside
                              ? status.success
                              : status.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!_isCheckedIn && isLateNow)
                      StatusPill(
                        label: 'Late',
                        color: status.warning,
                        icon: Icons.schedule,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedBouncyButton(
                  label: isLoading
                      ? 'Processing...'
                      : (_isCheckedIn ? 'Check Out' : 'Check In'),
                  icon: isLoading
                      ? null
                      : (_isCheckedIn ? Icons.logout : Icons.login),
                  onPressed: isLoading
                      ? null
                      : () {
                          final bloc = context.read<TeacherBloc>();
                          if (_isCheckedIn) {
                            bloc.add(PerformCheckOut());
                          } else {
                            _pendingLateComment = isLateNow;
                            bloc.add(PerformCheckIn());
                          }
                        },
                  backgroundColor:
                      _isCheckedIn ? colorScheme.error : colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Verifying location & face...',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ],
              ],
            ),
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
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No classes scheduled today.'),
                ),
              ),
            );
          }
          return Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.schedule.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = state.schedule[index];
                final colorScheme = Theme.of(context).colorScheme;
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.book_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    item.subject,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${item.className} | ${DateFormatter.formatTime(item.startTime)} - ${DateFormatter.formatTime(item.endTime)}',
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
          return Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final record = recent[index];
                return ListTile(
                  leading: _buildStatusIcon(record.status),
                  title: Text(DateFormatter.formatDate(record.date)),
                  subtitle: Text(
                    'In: ${record.checkInTime != null ? DateFormatter.formatTime(record.checkInTime!) : 'N/A'} | Out: ${record.checkOutTime != null ? DateFormatter.formatTime(record.checkOutTime!) : 'N/A'}',
                  ),
                  trailing: Chip(
                    label: Text(
                      record.status.name.toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    backgroundColor: _statusColor(record.status),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Widget _buildStatusIcon(AttendanceStatus status) {
    final color = _statusColor(status);
    final icon = switch (status) {
      AttendanceStatus.present => Icons.check_circle,
      AttendanceStatus.late => Icons.warning_amber,
      AttendanceStatus.absent => Icons.cancel,
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }

  Color _statusColor(AttendanceStatus status) {
    final colors = AppStatusColors.of(context);
    switch (status) {
      case AttendanceStatus.present:
        return colors.success;
      case AttendanceStatus.late:
        return colors.warning;
      case AttendanceStatus.absent:
        return colors.danger;
    }
  }
}

/// Compact, tappable action tile for the dashboard quick-actions row.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
