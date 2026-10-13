import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/parent_bloc.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../auth/models/attendance_model.dart';
import '../../auth/models/user_model.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Child Switcher for profile
                  if (profile.children.length > 1) ...[
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.children.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final c = profile.children[index];
                          final isSelected = index == state.selectedChildIndex;
                          return ChoiceChip(
                            label: Text(c.name),
                            selected: isSelected,
                            onSelected: (_) {
                              context
                                  .read<ParentBloc>()
                                  .add(SelectChild(index));
                              _loadAttendance(c.id);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Child Details Card
                  _buildChildDetails(child, colorScheme),
                  const SizedBox(height: 16),

                  // Quick links to the new modules
                  _buildQuickLinks(),
                  const SizedBox(height: 16),

                  // Parent Contact Card
                  _buildParentContact(profile, colorScheme),
                  const SizedBox(height: 16),

                  // PTM Schedule
                  _buildPTMSchedule(colorScheme),
                  const SizedBox(height: 16),

                  // Monthly Attendance Calendar
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Monthly Attendance',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () async {
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
                                child: Text(
                                  DateFormatter.formatMonthYear(
                                      _selectedMonth ?? DateTime.now()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildAttendanceCalendar(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Change Password
                  OutlinedButton.icon(
                    onPressed: () => _showChangePasswordDialog(context),
                    icon: const Icon(Icons.lock_outlined),
                    label: const Text('Change Password'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Logout
                  OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
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

  Widget _buildQuickLinks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('Leave Applications'),
              subtitle: const Text('Apply & track leave requests'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(RouteNames.parentLeave),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Fees & Payments'),
              subtitle: const Text('View dues, pay and track verification'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(RouteNames.parentFees),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Academic Calendar'),
              subtitle: const Text('Holidays, exams and events'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(RouteNames.parentCalendar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildDetails(StudentModel child, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              child.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${child.className} | Section ${child.section}',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            _buildInfoChip('Roll: ${child.rollNumber}', Icons.badge, colorScheme),
            const SizedBox(height: 4),
            _buildInfoChip(
                'RFID: ${child.rfidCardId ?? "N/A"}', Icons.credit_card, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildParentContact(ParentModel profile, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parent Information',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _contactRow(Icons.person, 'Name', profile.name, colorScheme),
            const SizedBox(height: 8),
            _contactRow(Icons.call, 'Phone', profile.phoneNumber ?? 'N/A', colorScheme),
            const SizedBox(height: 8),
            _contactRow(Icons.email, 'Email', profile.email ?? 'N/A', colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(
      IconData icon, String label, String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPTMSchedule(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups, color: Colors.teal),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PTM Scheduled',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('15 July 2026 at 10:00 AM',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
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
            return const Text('Loading...');
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
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

                    return SizedBox(
                      width: 36,
                      height: 36,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isPresent
                              ? Colors.green.withValues(alpha: 0.3)
                              : isAbsent
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isPresent
                                  ? Colors.green.shade800
                                  : isAbsent
                                      ? Colors.red.shade800
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendDot(Colors.green, 'Present'),
                  const SizedBox(width: 16),
                  _legendDot(Colors.red, 'Absent'),
                  const SizedBox(width: 16),
                  _legendDot(Colors.grey, 'No Data'),
                ],
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
