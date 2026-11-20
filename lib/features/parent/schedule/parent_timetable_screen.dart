import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../shared/models/timetable_item_model.dart';
import '../../shared/repositories/timetable_repository.dart';

class ParentTimetableScreen extends StatefulWidget {
  final ApiClient? apiClient;

  const ParentTimetableScreen({super.key, this.apiClient});

  @override
  State<ParentTimetableScreen> createState() => _ParentTimetableScreenState();
}

class _ParentTimetableScreenState extends State<ParentTimetableScreen>
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
  late final TimetableRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, List<TimetableItemModel>> _weeklyTimetable = {};

  final _todayName = _getWeekdayName(DateTime.now().weekday);

  static String _getWeekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekday >= 1 && weekday <= 7 ? names[weekday - 1] : 'Monday';
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = _weekdays.indexOf(_todayName);
    _tabController = TabController(
      length: _weekdays.length,
      vsync: this,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
    );

    _repository = TimetableRepository(
      apiClient: widget.apiClient ?? ApiClient(),
    );

    _fetchTimetable();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final grouped = await _repository.getWeeklyTimetableGrouped();
      if (mounted) {
        setState(() {
          _weeklyTimetable = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Class timetable',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: 0.15,
          ),
        ),
      ),
      body: _isLoading
          ? const ShimmerLoading(itemCount: 6, itemHeight: 88)
          : _errorMessage != null && _weeklyTimetable.isEmpty
              ? AppErrorWidget(
                  message: _errorMessage!,
                  onRetry: _fetchTimetable,
                )
              : Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          bottom: BorderSide(color: AppColors.border, width: 1),
                        ),
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
                                    fontWeight: isToday
                                        ? FontWeight.w600
                                        : FontWeight.normal,
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
                      child: RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: _fetchTimetable,
                        child: TabBarView(
                          controller: _tabController,
                          children: _weekdays.map((day) {
                            final periods =
                                _weeklyTimetable[day] ?? const <TimetableItemModel>[];
                            if (periods.isEmpty) {
                              return const EmptyStateWidget(
                                message: 'No classes scheduled',
                                subtitle: 'No timetable slots assigned for this day.',
                                icon: Icons.free_breakfast_outlined,
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: periods.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final period = periods[index];
                                return _ParentPeriodCard(
                                  period: period,
                                  isToday: day == _todayName,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ParentPeriodCard extends StatelessWidget {
  final TimetableItemModel period;
  final bool isToday;

  const _ParentPeriodCard({
    required this.period,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.startTime.isNotEmpty ? period.startTime : '--:--',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  period.endTime.isNotEmpty ? period.endTime : '--:--',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.subjectName.isNotEmpty
                      ? period.subjectName
                      : (period.courseName.isNotEmpty ? period.courseName : 'Class'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (period.teacherName.isNotEmpty) ...[
                      const Icon(Icons.person_outline, size: 14, color: AppColors.inkMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          period.teacherName,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.inkSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (period.roomName.isNotEmpty) ...[
                      const Icon(Icons.room_outlined, size: 14, color: AppColors.inkMuted),
                      const SizedBox(width: 4),
                      Text(
                        period.roomName,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
