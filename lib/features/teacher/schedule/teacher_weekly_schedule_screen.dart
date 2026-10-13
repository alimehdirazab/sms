import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/teacher_bloc.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/notification_model.dart';

/// Full-week timetable for the teacher, grouped by weekday with the current
/// day highlighted and its periods marked as "Now" / "Next".
class TeacherWeeklyScheduleScreen extends StatefulWidget {
  const TeacherWeeklyScheduleScreen({super.key});

  @override
  State<TeacherWeeklyScheduleScreen> createState() =>
      _TeacherWeeklyScheduleScreenState();
}

class _TeacherWeeklyScheduleScreenState
    extends State<TeacherWeeklyScheduleScreen>
    with SingleTickerProviderStateMixin {
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  late final TabController _tabController;
  final _todayName = _weekdayName(DateTime.now().weekday);

  @override
  void initState() {
    super.initState();
    final initialIndex = _weekdays.indexOf(_todayName);
    _tabController = TabController(
      length: _weekdays.length,
      vsync: this,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
    );
    context.read<TeacherBloc>().add(LoadTeacherWeeklySchedule());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[(weekday - 1).clamp(0, 6)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Timetable')),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        buildWhen: (_, state) =>
            state is TeacherWeeklyScheduleLoaded ||
            state is TeacherWeeklyScheduleLoading ||
            state is TeacherError,
        builder: (context, state) {
          if (state is TeacherError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<TeacherBloc>()
                  .add(LoadTeacherWeeklySchedule()),
            );
          }
          if (state is! TeacherWeeklyScheduleLoaded) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 90);
          }
          final week = state.week;

          return Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: _weekdays.map((day) {
                  final isToday = day == _todayName;
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(day.substring(0, 3)),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _weekdays.map((day) {
                    final periods = week[day] ?? const <ScheduleModel>[];
                    if (periods.isEmpty) {
                      return const EmptyStateWidget(
                        message: 'No classes scheduled.',
                        icon: Icons.free_breakfast,
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: periods.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _PeriodCard(
                        period: periods[index],
                        isToday: day == _todayName,
                        isFirst: index == 0,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final ScheduleModel period;
  final bool isToday;
  final bool isFirst;

  const _PeriodCard({
    required this.period,
    required this.isToday,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final isNow = isToday &&
        now.isAfter(period.startTime) &&
        now.isBefore(period.endTime);
    // The first period of today is highlighted as "Next" before it starts.
    final isNext = isToday && isFirst && now.isBefore(period.startTime);

    return Card(
      margin: EdgeInsets.zero,
      color: isNow ? colorScheme.primaryContainer.withValues(alpha: 0.5) : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatTime(period.startTime),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    DateFormatter.formatTime(period.endTime),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 3,
              height: 46,
              decoration: BoxDecoration(
                color: isNow ? colorScheme.primary : colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${period.className} · Section ${period.section}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isNow)
              _Badge(label: 'Now', color: colorScheme.primary)
            else if (isNext)
              _Badge(label: 'Next', color: colorScheme.tertiary),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
