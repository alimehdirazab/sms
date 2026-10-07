import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/animated_button.dart';
import '../../auth/models/attendance_model.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  bool _isCheckedIn = false;

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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
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

              // Today's Schedule
              Text(
                "Today's Schedule",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
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

  Widget _buildCheckInOutSection(ColorScheme colorScheme) {
    return BlocConsumer<TeacherBloc, TeacherState>(
      listener: (context, state) {
        if (state is TeacherCheckInSuccess) {
          setState(() {
            _isCheckedIn = state.checkedIn;
          });
          final message = state.checkedIn
              ? '✅ Check-in successful! Face verified & inside geofence.'
              : '👋 Check-out successful!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: colorScheme.primary,
            ),
          );
        } else if (state is TeacherCheckInError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TeacherCheckInLoading;
        // Mock GPS - will be replaced with actual Geolocator
        final geofenceInside = state is! TeacherCheckInError;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Geofence status
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: geofenceInside ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      geofenceInside
                          ? 'Inside School Zone'
                          : 'Outside School Zone',
                      style: TextStyle(
                        color: geofenceInside ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
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
              separatorBuilder: (_, __) => const Divider(height: 1),
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
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
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
    IconData icon;
    Color color;
    switch (status) {
      case AttendanceStatus.present:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AttendanceStatus.late:
        icon = Icons.warning_amber;
        color = Colors.orange;
        break;
      case AttendanceStatus.absent:
        icon = Icons.cancel;
        color = Colors.red;
        break;
    }
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
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }
}
