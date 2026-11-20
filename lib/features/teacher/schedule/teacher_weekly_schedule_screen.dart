import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/notification_model.dart';
import '../../shared/repositories/timetable_repository.dart';
import '../../shared/widgets/stat_card.dart';

/// Full-week timetable for the teacher, grouped by weekday with the current
/// day highlighted and its periods marked as "Now" / "Next".
class TeacherWeeklyScheduleScreen extends StatefulWidget {
  final ApiClient? apiClient;

  const TeacherWeeklyScheduleScreen({super.key, this.apiClient});

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
  late final TimetableRepository _timetableRepo;
  Map<String, List<ScheduleModel>>? _apiWeeklySchedule;
  bool _isLoadingApi = true;
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
    _timetableRepo = TimetableRepository(apiClient: widget.apiClient ?? ApiClient());
    _fetchLiveTimetable();
    context.read<TeacherBloc>().add(LoadTeacherWeeklySchedule());
  }

  Future<void> _fetchLiveTimetable() async {
    try {
      final grouped = await _timetableRepo.getWeeklyTimetableGrouped();
      if (!mounted) return;

      final now = DateTime.now();
      DateTime parseTime(String timeStr) {
        final parts = timeStr.split(':');
        final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 8 : 8;
        final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        return DateTime(now.year, now.month, now.day, hour, minute);
      }

      final Map<String, List<ScheduleModel>> mapped = {};
      var hasAnyEntries = false;

      for (final day in _weekdays) {
        final entries = grouped[day] ?? [];
        if (entries.isNotEmpty) hasAnyEntries = true;
        mapped[day] = entries.map((item) {
          return ScheduleModel(
            id: item.id,
            subject: item.subjectName.isNotEmpty
                ? item.subjectName
                : (item.courseName.isNotEmpty ? item.courseName : 'Class'),
            className: item.className,
            section: item.sectionName,
            startTime: parseTime(item.startTime),
            endTime: parseTime(item.endTime),
          );
        }).toList();
      }

      if (mounted) {
        setState(() {
          if (hasAnyEntries) {
            _apiWeeklySchedule = mapped;
          }
          _isLoadingApi = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingApi = false;
        });
      }
    }
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
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Weekly timetable',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: 0.15,
          ),
        ),
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        buildWhen: (_, state) =>
            state is TeacherWeeklyScheduleLoaded ||
            state is TeacherWeeklyScheduleLoading ||
            state is TeacherError,
        builder: (context, state) {
          if (_isLoadingApi && state is! TeacherWeeklyScheduleLoaded) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 90);
          }
          if (state is TeacherError && _apiWeeklySchedule == null) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                _fetchLiveTimetable();
                context.read<TeacherBloc>().add(LoadTeacherWeeklySchedule());
              },
            );
          }

          final week = _apiWeeklySchedule ??
              (state is TeacherWeeklyScheduleLoaded ? state.week : <String, List<ScheduleModel>>{});

          return Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.accent,
                  indicatorWeight: 2,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.inkMuted,
                  tabs: _weekdays.map((day) {
                    final isToday = day == _todayName;
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            day.substring(0, 3),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 5),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _weekdays.map((day) {
                    final periods = week[day] ?? const <ScheduleModel>[];
                    if (periods.isEmpty) {
                      return const EmptyStateWidget(
                        message: 'No classes scheduled',
                        subtitle: 'Enjoy your free day or prepare your lesson plans.',
                        icon: Icons.free_breakfast_outlined,
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
    final now = DateTime.now();
    final isNow = isToday &&
        now.isAfter(period.startTime) &&
        now.isBefore(period.endTime);
    final isNext = isToday && isFirst && now.isBefore(period.startTime);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNow ? AppColors.accentTint.withValues(alpha: 0.5) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isNow ? AppColors.infoBorder : AppColors.border,
          width: 1,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatTime(period.startTime),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isNow ? AppColors.accent : AppColors.ink,
                  ),
                ),
                Text(
                  DateFormatter.formatTime(period.endTime),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2.5,
            height: 42,
            decoration: BoxDecoration(
              color: isNow ? AppColors.accent : AppColors.border,
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
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${period.className} · Section ${period.section}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isNow)
            const StatusPill(
              label: 'Now',
              color: AppColors.accent,
              backgroundColor: AppColors.accentTint,
              borderColor: AppColors.infoBorder,
            )
          else if (isNext)
            const StatusPill(
              label: 'Next',
              color: AppColors.warning,
              backgroundColor: AppColors.warningBg,
              borderColor: AppColors.warningBorder,
            ),
        ],
      ),
    );
  }
}
