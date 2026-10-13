import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        buildWhen: (_, state) =>
            state is TeacherProfileLoaded ||
            state is TeacherProfileLoading ||
            state is TeacherProfileError,
        builder: (context, state) {
          if (state is TeacherProfileLoading) {
            return const ShimmerLoading(itemCount: 5, itemHeight: 72);
          }
          if (state is TeacherProfileError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<TeacherBloc>().add(LoadTeacherProfile());
              },
            );
          }
          if (state is TeacherProfileLoaded) {
            final profile = state.profile;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Profile Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      profile.name
                          .split(' ')
                          .map((e) => e.isNotEmpty ? e[0] : '')
                          .take(2)
                          .join(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.department,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            Icons.badge,
                            'Employee ID',
                            profile.employeeId,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.call,
                            'Phone',
                            profile.phoneNumber ?? 'N/A',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.email,
                            'Email',
                            profile.email ?? 'N/A',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.class_,
                            'Assigned Classes',
                            profile.assignedClasses.join(', '),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.admin_panel_settings,
                            'Publish Rights',
                            profile.canPublishMarks ? 'Yes' : 'No',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick links to schedule, calendar and leave
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_view_week),
                            title: const Text('Weekly Timetable'),
                            subtitle: const Text('Full week class schedule'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context
                                .pushNamed(RouteNames.teacherWeeklySchedule),
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(Icons.event_available),
                            title: const Text('Leave Applications'),
                            subtitle:
                                const Text('Send requests to the Principal'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.pushNamed(RouteNames.teacherLeave),
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(Icons.calendar_month),
                            title: const Text('Academic Calendar'),
                            subtitle: const Text('Meetings, exams & events'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                context.pushNamed(RouteNames.teacherCalendar),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<TeacherBloc>().add(LoadTeacherProfile());
          });
          return const ShimmerLoading(itemCount: 5, itemHeight: 72);
        },
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.goNamed(RouteNames.roleSelection);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
