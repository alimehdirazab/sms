import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/parent_bloc.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Parent dashboard',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Leave applications',
            icon: const Icon(Icons.event_note_rounded, size: 20),
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
              color: AppColors.accent,
              onRefresh: () async {
                context.read<ParentBloc>().add(LoadParentProfile());
                context.read<ParentBloc>().add(LoadAcademicCalendar());
                _loadChildData(selectedChild.id);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormatter.getGreeting()},',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.name.split(' ').first,
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 26,
                        fontWeight: FontWeight.normal,
                        color: AppColors.ink,
                        letterSpacing: -0.02 * 26,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (profile.children.isNotEmpty) ...[
                      _buildChildSwitcher(state),
                      const SizedBox(height: 12),
                    ],

                    Text(
                      'Showing data for: ${selectedChild.name} · ${selectedChild.className}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildQuickActions(),
                    const SizedBox(height: 18),

                    _buildStatsSnapshot(),
                    const SizedBox(height: 18),

                    _buildProgressSection(),
                    const SizedBox(height: 18),

                    _buildAttendanceCard(),
                    const SizedBox(height: 16),

                    _buildRecentMarks(),
                    const SizedBox(height: 16),

                    _buildUpcomingExams(),
                    const SizedBox(height: 16),

                    _buildCalendarPreview(),
                    const SizedBox(height: 16),

                    _buildFeeAlert(),
                    const SizedBox(height: 24),
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
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.profile.children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final child = state.profile.children[index];
          final isSelected = index == state.selectedChildIndex;
          final classDisplay = child.className.isNotEmpty ? ' (${child.className})' : '';

          return GestureDetector(
            onTap: () {
              context.read<ParentBloc>().add(SelectChild(index));
              _loadChildData(child.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppColors.border, width: 1)
                    : null,
                boxShadow: isSelected ? AppShadows.subtle : null,
              ),
              child: Center(
                child: Text(
                  '${child.name}$classDisplay',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.accent : AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          );
        },
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
            onTap: () => context.pushNamed(RouteNames.parentLeave),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.payments_outlined,
            label: 'Pay fees',
            onTap: () => context.pushNamed(RouteNames.parentFees),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_month_outlined,
            label: 'Calendar',
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
                color: a.attendancePercentage >= 75
                    ? status.success
                    : status.danger,
                caption: '${a.attendancePresent}/${a.attendanceTotal} days present',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Class average',
                value: '${a.averagePercentage.toStringAsFixed(1)}%',
                icon: Icons.trending_up_rounded,
                color: status.info,
                caption: 'Overall grade: ${a.overallGrade}',
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
                  const Icon(
                    Icons.insights_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Progress overview',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
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
                'Marks trajectory by exam',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 8),
              MiniBarChart(
                labels: a.examLabels,
                values: a.examPercentages,
                color: AppColors.accent,
                height: 140,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCard() {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) =>
          state is ParentAttendanceLoaded || state is ParentAttendanceLoading,
      builder: (context, state) {
        if (state is ParentAttendanceLoading) {
          return const ShimmerCard(height: 90);
        }
        if (state is ParentAttendanceLoaded) {
          final attendance = state.todayAttendance;
          final (icon, iconColor) = switch (attendance.status) {
            AttendanceStatus.present => (Icons.check_circle_outline_rounded, AppColors.success),
            AttendanceStatus.late => (Icons.access_time_rounded, AppColors.warning),
            AttendanceStatus.absent => (Icons.highlight_off_rounded, AppColors.danger),
          };

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: AppShadows.subtle,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceInset,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's attendance",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      StatusDot.semantic(
                        context,
                        label: _attendanceSentenceCase(attendance.status),
                        kind: attendance.status.name,
                      ),
                      if (attendance.checkInTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Checked in: ${DateFormatter.formatTime(attendance.checkInTime!)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.inkMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const ShimmerCard(height: 90);
      },
    );
  }

  Widget _buildRecentMarks() {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentMarksLoaded,
      builder: (context, state) {
        if (state is ParentMarksLoaded) {
          if (state.marks.isEmpty) return const SizedBox.shrink();
          final latestMarks = state.marks.take(3).toList();
          final avgPercentage =
              latestMarks.fold<double>(0, (sum, m) => sum + m.percentage) /
                  latestMarks.length;

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
                        'Recent marks',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    StatusPill.semantic(
                      context,
                      label: 'Avg: ${avgPercentage.toStringAsFixed(1)}%',
                      kind: 'info',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...latestMarks.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            m.examId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          '${m.percentage.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: m.percentage >= 40
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill.semantic(
                          context,
                          label: m.grade,
                          kind: m.percentage >= 40 ? 'success' : 'danger',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                Text(
                  'Upcoming exams',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                ...state.exams.map(
                  (exam) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.warningBorder, width: 1),
                      ),
                      child: const Icon(Icons.quiz_outlined, color: AppColors.warning, size: 18),
                    ),
                    title: Text(
                      exam.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
                    ),
                    subtitle: Text(
                      DateFormatter.formatDate(exam.date),
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.inkMuted),
                    ),
                    dense: true,
                  ),
                ),
              ],
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
                        context.pushNamed(RouteNames.parentCalendar),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        final isClear = outstanding <= 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isClear ? AppColors.successBorder : AppColors.warningBorder,
              width: 1,
            ),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isClear ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                    color: isClear ? AppColors.success : AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isClear ? 'All dues settled' : 'Fee due alert',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isClear
                              ? 'All tuition fees are paid. Thank you!'
                              : 'Rs. ${outstanding.toStringAsFixed(0)} outstanding',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isClear)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: () =>
                          context.pushNamed(RouteNames.parentFees),
                      child: const Text('Pay now'),
                    ),
                ],
              ),
              if (pendingPayments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.warningBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.hourglass_top_rounded,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${pendingPayments.length} payment(s) pending verification by accounts office.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _attendanceSentenceCase(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
    }
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.infoBorder, width: 1),
              ),
              child: Icon(icon, color: AppColors.accent, size: 18),
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
    );
  }
}
