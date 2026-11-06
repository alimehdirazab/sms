import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'My profile',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
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
            final initials = profile.name
                .split(' ')
                .map((e) => e.isNotEmpty ? e[0] : '')
                .take(2)
                .join()
                .toUpperCase();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // Profile Avatar matching DESIGN.md Section 5
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.accentTint,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    profile.name,
                    style: GoogleFonts.instrumentSerif(
                      fontSize: 26,
                      fontWeight: FontWeight.normal,
                      color: AppColors.ink,
                      letterSpacing: -0.02 * 26,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.department,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.badge_outlined,
                          'Employee ID',
                          profile.employeeId,
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.call_outlined,
                          'Phone',
                          profile.phoneNumber ?? 'N/A',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.mail_outline_rounded,
                          'Email',
                          profile.email ?? 'N/A',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.class_outlined,
                          'Assigned classes',
                          profile.assignedClasses.join(', '),
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.admin_panel_settings_outlined,
                          'Publish rights',
                          profile.canPublishMarks ? 'Yes' : 'No',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Navigation Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_view_week_rounded, size: 20, color: AppColors.accent),
                          title: Text(
                            'Weekly timetable',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
                          ),
                          subtitle: Text(
                            'Full week schedule',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.inkMuted),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.inkFaint),
                          onTap: () => context
                              .pushNamed(RouteNames.teacherWeeklySchedule),
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.event_available_rounded, size: 20, color: AppColors.accent),
                          title: Text(
                            'Leave applications',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
                          ),
                          subtitle: Text(
                            'My records & student requests',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.inkMuted),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.inkFaint),
                          onTap: () =>
                              context.pushNamed(RouteNames.teacherLeave),
                        ),
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.accent),
                          title: Text(
                            'Academic calendar',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
                          ),
                          subtitle: Text(
                            'Meetings, exams & campus events',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.inkMuted),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.inkFaint),
                          onTap: () =>
                              context.pushNamed(RouteNames.teacherCalendar),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button (Destructive variant matching DESIGN.md Section 7.1)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                      label: Text(
                        'Sign out',
                        style: GoogleFonts.poppins(
                          color: AppColors.danger,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.dangerBorder, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
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
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.inkMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.ink,
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
        title: Text(
          'Sign out',
          style: GoogleFonts.instrumentSerif(fontSize: 22, color: AppColors.ink),
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.inkSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
              context.goNamed(RouteNames.login);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
