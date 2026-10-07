import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/parent_bloc.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../auth/models/attendance_model.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ParentBloc>();
    bloc.add(LoadParentProfile());
  }

  void _loadChildData(String studentId) {
    final bloc = context.read<ParentBloc>();
    bloc.add(LoadTodayAttendance(studentId));
    bloc.add(LoadUpcomingExams(studentId));
    bloc.add(LoadStudentMarks(studentId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Dashboard')),
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

            // Load child data on first build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadChildData(selectedChild.id);
            });

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ParentBloc>().add(LoadParentProfile());
                _loadChildData(selectedChild.id);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      '${DateFormatter.getGreeting()}, ${profile.name.split(' ').first}!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Child Switcher
                    if (profile.children.length > 1) ...[
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: profile.children.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final child = profile.children[index];
                            final isSelected =
                                index == state.selectedChildIndex;
                            return ChoiceChip(
                              label: Text(child.name),
                              selected: isSelected,
                              onSelected: (_) {
                                context.read<ParentBloc>().add(
                                  SelectChild(index),
                                );
                                _loadChildData(child.id);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      'Showing data for: ${selectedChild.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Today's Attendance
                    _buildAttendanceCard(selectedChild.id, colorScheme),
                    const SizedBox(height: 16),

                    // Recent Marks
                    _buildRecentMarks(selectedChild.id, colorScheme),
                    const SizedBox(height: 16),

                    // Upcoming Exams
                    _buildUpcomingExams(selectedChild.id, colorScheme),
                    const SizedBox(height: 16),

                    // Fee Due Alert
                    _buildFeeAlert(colorScheme),
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

  Widget _buildAttendanceCard(String studentId, ColorScheme colorScheme) {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) =>
          state is ParentAttendanceLoaded || state is ParentAttendanceLoading,
      builder: (context, state) {
        if (state is ParentAttendanceLoading) {
          return const ShimmerCard(height: 100);
        }
        if (state is ParentAttendanceLoaded) {
          final attendance = state.todayAttendance;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _attendanceColor(
                        attendance.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _attendanceIcon(attendance.status),
                      color: _attendanceColor(attendance.status),
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attendance.status.name.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _attendanceColor(attendance.status),
                            fontSize: 16,
                          ),
                        ),
                        if (attendance.checkInTime != null)
                          Text(
                            'Check-in: ${DateFormatter.formatTime(attendance.checkInTime!)}',
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

  Widget _buildRecentMarks(String studentId, ColorScheme colorScheme) {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentMarksLoaded,
      builder: (context, state) {
        if (state is ParentMarksLoaded) {
          if (state.marks.isEmpty) return const SizedBox.shrink();
          final latestMarks = state.marks.take(3).toList();
          final avgPercentage =
              latestMarks.fold<double>(0, (sum, m) => sum + m.percentage) /
              latestMarks.length;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Marks',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${avgPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...latestMarks.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            m.studentName.split(' ').first,
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            '${m.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: m.percentage >= 40
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
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

  Widget _buildUpcomingExams(String studentId, ColorScheme colorScheme) {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentUpcomingExamsLoaded,
      builder: (context, state) {
        if (state is ParentUpcomingExamsLoaded) {
          if (state.exams.isEmpty) return const SizedBox.shrink();
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Exams',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...state.exams.map(
                    (exam) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.quiz, color: Colors.orange),
                      ),
                      title: Text(
                        exam.subjectName,
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

  Widget _buildFeeAlert(ColorScheme colorScheme) {
    return Card(
      color: Colors.red.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.red),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fee Due Alert',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹5000 due by 25 July 2026',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment gateway - Coming soon'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  Color _attendanceColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
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
