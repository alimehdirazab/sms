import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/user_model.dart';
import '../bloc/parent_bloc.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    final bloc = context.read<ParentBloc>();
    bloc.add(LoadParentProfile());
  }

  void _loadAttendance(String studentId) {
    if (_selectedMonth != null) {
      context.read<ParentBloc>().add(
            LoadMonthlyAttendance(studentId, _selectedMonth!),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
      ),
      body: BlocBuilder<ParentBloc, ParentState>(
        buildWhen: (_, state) =>
            state is ParentProfileLoaded ||
            state is ParentProfileLoading ||
            state is ParentProfileError,
        builder: (context, state) {
          if (state is ParentProfileLoading) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 72);
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
            final child = profile.children[state.selectedChildIndex];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadAttendance(child.id);
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inset Child Switcher
                  if (profile.children.length > 1) ...[
                    _buildChildSwitcher(
                      children: profile.children,
                      selectedIndex: state.selectedChildIndex,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Student Details Card
                  _buildChildDetails(child),
                  const SizedBox(height: 16),

                  // Quick links to key modules
                  _buildQuickLinks(),
                  const SizedBox(height: 16),

                  // Parent Contact Information Card
                  _buildParentContact(profile),
                  const SizedBox(height: 16),

                  // PTM Schedule Card
                  _buildPTMSchedule(),
                  const SizedBox(height: 16),

                  // Monthly Attendance Calendar Card
                  _buildAttendanceSection(child),
                  const SizedBox(height: 20),

                  // Security & Account actions
                  OutlinedButton.icon(
                    onPressed: () => _showChangePasswordDialog(context),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text('Change password'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.dangerBorder),
                      backgroundColor: AppColors.dangerBg,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ParentBloc>().add(LoadParentProfile());
          });
          return const ShimmerLoading(itemCount: 6, itemHeight: 72);
        },
      ),
    );
  }

  Widget _buildChildSwitcher({
    required List<StudentModel> children,
    required int selectedIndex,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderFaint),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(children.length, (index) {
          final isSelected = index == selectedIndex;
          final c = children[index];
          return Expanded(
            child: InkWell(
              onTap: () {
                context.read<ParentBloc>().add(SelectChild(index));
                _loadAttendance(c.id);
              },
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: isSelected
                      ? Border.all(color: AppColors.border)
                      : Border.all(color: Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    c.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.ink : AppColors.inkSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChildDetails(StudentModel child) {
    final initials = child.name.trim().isNotEmpty
        ? child.name.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentTint,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderFaint),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            child.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${child.className} · Section ${child.section}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkSecondary,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoChip(
                label: 'Roll: ${child.rollNumber}',
                icon: Icons.badge_outlined,
              ),
              _buildInfoChip(
                label: 'RFID: ${child.rfidCardId ?? "N/A"}',
                icon: Icons.credit_card_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.borderFaint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.inkSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildLinkTile(
            icon: Icons.event_available_outlined,
            title: 'Leave applications',
            subtitle: 'Apply & track leave requests',
            onTap: () => context.pushNamed(RouteNames.parentLeave),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderFaint, indent: 56),
          _buildLinkTile(
            icon: Icons.receipt_long_outlined,
            title: 'Fees & payments',
            subtitle: 'View dues, pay and track verification',
            onTap: () => context.pushNamed(RouteNames.parentFees),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderFaint, indent: 56),
          _buildLinkTile(
            icon: Icons.calendar_month_outlined,
            title: 'Academic calendar',
            subtitle: 'Holidays, exams and school events',
            onTap: () => context.pushNamed(RouteNames.parentCalendar),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surfaceInset,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: AppColors.borderFaint),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: AppColors.accent),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.inkSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.inkMuted),
      onTap: onTap,
    );
  }

  Widget _buildParentContact(ParentModel profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parent information',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: 12),
          _contactRow(Icons.person_outline, 'Name', profile.name),
          const Divider(height: 16, thickness: 1, color: AppColors.borderFaint),
          _contactRow(Icons.phone_outlined, 'Phone', profile.phoneNumber ?? 'N/A'),
          const Divider(height: 16, thickness: 1, color: AppColors.borderFaint),
          _contactRow(Icons.email_outlined, 'Email', profile.email ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.inkSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPTMSchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceInset,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.borderFaint),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.groups_outlined, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PTM scheduled',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '15 July 2026 at 10:00 AM',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.inkMuted),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(StudentModel child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly attendance',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedMonth ?? DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedMonth = picked;
                    });
                    _loadAttendance(child.id);
                  }
                },
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatter.formatMonthYear(
                          _selectedMonth ?? DateTime.now(),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAttendanceCalendar(),
        ],
      ),
    );
  }

  Widget _buildAttendanceCalendar() {
    return BlocBuilder<ParentBloc, ParentState>(
      buildWhen: (_, state) => state is ParentAttendanceLoaded,
      builder: (context, state) {
        if (state is ParentAttendanceLoaded) {
          final records = state.monthlyAttendance;
          if (records.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No attendance data found',
                  style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
                ),
              ),
            );
          }

          final month = _selectedMonth ?? DateTime.now();
          final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
          final firstDayOffset =
              DateTime(month.year, month.month, 1).weekday % 7;

          return Column(
            children: [
              // Day headers
              Row(
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 6),
              // Calendar grid
              Wrap(
                children: [
                  ...List.generate(firstDayOffset, (_) => const SizedBox(
                    width: 36,
                    height: 36,
                  )),
                  ...List.generate(daysInMonth, (index) {
                    final day = index + 1;
                    final record = records.length > index ? records[index] : null;
                    final isPresent =
                        record?.status == AttendanceStatus.present;
                    final isAbsent =
                        record?.status == AttendanceStatus.absent;

                    Color bg = AppColors.surfaceInset;
                    Color border = AppColors.borderFaint;
                    Color text = AppColors.inkMuted;

                    if (isPresent) {
                      bg = AppColors.successBg;
                      border = AppColors.successBorder;
                      text = AppColors.success;
                    } else if (isAbsent) {
                      bg = AppColors.dangerBg;
                      border = AppColors.dangerBorder;
                      text = AppColors.danger;
                    }

                    return SizedBox(
                      width: 36,
                      height: 36,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: bg,
                          border: Border.all(color: border),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: text,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendDot(AppColors.success, 'Present'),
                  const SizedBox(width: 16),
                  _legendDot(AppColors.danger, 'Absent'),
                  const SizedBox(width: 16),
                  _legendDot(AppColors.inkMuted, 'No data'),
                ],
              ),
            ],
          );
        }
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.inkSecondary,
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Change password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.inkSecondary)),
          ),
          FilledButton(
            onPressed: () {
              if (oldPwdCtrl.text.isNotEmpty && newPwdCtrl.text.isNotEmpty) {
                context.read<ParentBloc>().add(
                      ChangePasswordRequested(
                        oldPwdCtrl.text,
                        newPwdCtrl.text,
                      ),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully.')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Sign out',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.ink,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.inkSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.inkSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
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
