import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/parent_bloc.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/attendance_model.dart';
import '../../shared/widgets/academic_calendar_view.dart';
import '../../shared/widgets/progress_charts.dart';
import '../../shared/widgets/stat_card.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ParentBloc>().add(LoadParentProfile());
    context.read<ParentBloc>().add(LoadAcademicCalendar());
  }

  void _loadChildData(String studentId) {
    final bloc = context.read<ParentBloc>();
    bloc.add(LoadTodayAttendance(studentId));
    bloc.add(LoadUpcomingExams(studentId));
    bloc.add(LoadStudentMarks(studentId));
    bloc.add(LoadStudentAnalytics(studentId));
    bloc.add(LoadLeaveApplications(studentId));
    bloc.add(LoadFees(studentId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Leave Applications',
            icon: const Icon(Icons.event_note),
            onPressed: () => context.pushNamed(RouteNames.parentLeave),
          ),
        ],
      ),
      body: BlocBuilder<ParentBloc, ParentState>(
        buildWhen: (_, state) =>
            state is ParentProfileLoaded ||
            state is ParentProfileLoading ||
            state is ParentProfileError,
        builder: (context, state) {
          if (state is ParentProfileLoading) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 80);
          }
          if (state is ParentProfileError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<ParentBloc>().add(LoadParentProfile()),
            );
          }
          if (state is ParentProfileLoaded) {
            final profile = state.profile;
            final selectedChild = profile.children[state.selectedChildIndex];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadChildData(selectedChild.id);
            });

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ParentBloc>().add(LoadParentProfile());
                context.read<ParentBloc>().add(LoadAcademicCalendar());
                _loadChildData(selectedChild.id);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormatter.getGreeting()}, ${profile.name.split(' ').first}!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    if (profile.children.length > 1) ...[
                      _buildChildSwitcher(state),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      'Showing data for: ${selectedChild.name} · ${selectedChild.className}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 14),

                    _buildQuickActions(),
                    const SizedBox(height: 18),

                    _buildStatsSnapshot(),
                    const SizedBox(height: 18),

                    _buildProgressSection(),
                    const SizedBox(height: 18),

                    _buildAttendanceCard(colorScheme),
                    const SizedBox(height: 16),

                    _buildRecentMarks(colorScheme),
                    const SizedBox(height: 16),

                    _buildUpcomingExams(),
                    const SizedBox(height: 16),

                    _buildCalendarPreview(),
                    const SizedBox(height: 16),

                    _buildFeeAlert(),
                  ],
                ),
              ),
            );
          }
          return const ShimmerLoading(itemCount: 6, itemHeight: 80);
        },
      ),
    );
  }

  Widget _buildChildSwitcher(ParentProfileLoaded state) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.profile.children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final child = state.profile.children[index];
          return ChoiceChip(
            label: Text(child.name),
            selected: index == state.selectedChildIndex,
            onSelected: (_) {
              context.read<ParentBloc>().add(SelectChild(index));
              _loadChildData(child.id);
            },
          );
        },
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
            onTap: () => context.pushNamed(RouteNames.parentLeave),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.payments_outlined,
            label: 'Pay Fees',
            color: status.warning,
            onTap: () => context.pushNamed(RouteNames.parentFees),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_month,
            label: 'Calendar',
            color: status.success,
            onTap: () => context.pushNamed(RouteNames.parentCalendar),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSnapshot() {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentAnalyticsLoaded,
      builder: (context, state) {
        if (state is! ParentAnalyticsLoaded) {
          return const ShimmerCard(height: 90);
        }
        final a = state.analytics;
        final status = AppStatusColors.of(context);
        return Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Attendance',
                value: '${a.attendancePercentage.toStringAsFixed(0)}%',
                icon: Icons.fact_check_outlined,
                color:
                    a.attendancePercentage >= 75 ? status.success : status.danger,
                caption: '${a.attendancePresent}/${a.attendanceTotal} days',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Average',
                value: '${a.averagePercentage.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: status.info,
                caption: 'Grade ${a.overallGrade}',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentAnalyticsLoaded,
      builder: (context, state) {
        if (state is! ParentAnalyticsLoaded) {
          return const ShimmerCard(height: 200);
        }
        final a = state.analytics;
        final status = AppStatusColors.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Progress Overview',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ProgressStatBar(
                  label: 'Attendance this month',
                  percentage: a.attendancePercentage,
                  color: a.attendancePercentage >= 75
                      ? status.success
                      : status.danger,
                ),
                const SizedBox(height: 16),
                Text(
                  'Marks trend by exam',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                MiniBarChart(
                  labels: a.examLabels,
                  values: a.examPercentages,
                  color: Theme.of(context).colorScheme.primary,
                  height: 150,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCard(ColorScheme colorScheme) {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) =>
          state is ParentAttendanceLoaded || state is ParentAttendanceLoading,
      builder: (context, state) {
        if (state is ParentAttendanceLoading) {
          return const ShimmerCard(height: 100);
        }
        if (state is ParentAttendanceLoaded) {
          final attendance = state.todayAttendance;
          final color = _attendanceColor(attendance.status);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _attendanceIcon(attendance.status),
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Attendance",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attendance.status.name.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontSize: 16,
                          ),
                        ),
                        if (attendance.checkInTime != null)
                          Text(
                            'Check-in: ${DateFormatter.formatTime(attendance.checkInTime!)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const ShimmerCard(height: 100);
      },
    );
  }

  Widget _buildRecentMarks(ColorScheme colorScheme) {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentMarksLoaded,
      builder: (context, state) {
        if (state is ParentMarksLoaded) {
          if (state.marks.isEmpty) return const SizedBox.shrink();
          final latestMarks = state.marks.take(3).toList();
          final avgPercentage =
              latestMarks.fold<double>(0, (sum, m) => sum + m.percentage) /
                  latestMarks.length;
          final status = AppStatusColors.of(context);

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
                          'Recent Marks',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      StatusPill(
                        label: '${avgPercentage.toStringAsFixed(1)}%',
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...latestMarks.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.examId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${m.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: m.percentage >= 40
                                  ? status.success
                                  : status.danger,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusPill(label: m.grade, color: colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const ShimmerCard(height: 100);
      },
    );
  }

  Widget _buildUpcomingExams() {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentUpcomingExamsLoaded,
      builder: (context, state) {
        if (state is ParentUpcomingExamsLoaded) {
          if (state.exams.isEmpty) return const SizedBox.shrink();
          final warning = AppStatusColors.of(context).warning;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Exams',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...state.exams.map(
                    (exam) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.quiz, color: warning),
                      ),
                      title: Text(
                        exam.subjectName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        DateFormatter.formatDate(exam.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const ShimmerCard(height: 100);
      },
    );
  }

  Widget _buildCalendarPreview() {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentCalendarLoaded,
      builder: (context, state) {
        if (state is! ParentCalendarLoaded) {
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
                          context.pushNamed(RouteNames.parentCalendar),
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

  Widget _buildFeeAlert() {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentFeesLoaded,
      builder: (context, state) {
        if (state is! ParentFeesLoaded) {
          return const ShimmerCard(height: 100);
        }
        final outstanding = state.totalOutstanding;
        final pendingPayments =
            state.payments.where((p) => p.status.name == 'pending').toList();
        final status = AppStatusColors.of(context);
        final isClear = outstanding <= 0;

        return Card(
          color: (isClear ? status.success : status.danger).withValues(
            alpha: 0.06,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isClear ? Icons.check_circle : Icons.warning_amber,
                      color: isClear ? status.success : status.danger,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isClear ? 'No Dues' : 'Fee Due Alert',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isClear
                                ? 'All fees are paid. Thank you!'
                                : '₹${outstanding.toStringAsFixed(0)} outstanding',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (!isClear)
                      FilledButton(
                        onPressed: () =>
                            context.pushNamed(RouteNames.parentFees),
                        child: const Text('Pay Now'),
                      ),
                  ],
                ),
                if (pendingPayments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: status.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_top,
                          size: 18,
                          color: status.warning,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${pendingPayments.length} payment(s) pending verification by the school office.',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _attendanceColor(AttendanceStatus status) {
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

  IconData _attendanceIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.warning_amber;
      case AttendanceStatus.absent:
        return Icons.cancel;
    }
  }
}

/// Small tappable action tile used in the dashboard quick-actions row.
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
