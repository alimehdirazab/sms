import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/teacher_bloc.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/leave_model.dart';
import '../../shared/widgets/stat_card.dart';
import '../../parent/leave/parent_leave_screen.dart' show StatusPillLocal;

/// Teacher-facing leave management. Applications are sent to the Principal
/// (reviewed in the separate web application) and remain pending until then.
class TeacherLeaveScreen extends StatefulWidget {
  const TeacherLeaveScreen({super.key});

  @override
  State<TeacherLeaveScreen> createState() => _TeacherLeaveScreenState();
}

class _TeacherLeaveScreenState extends State<TeacherLeaveScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadTeacherLeaveApplications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Leave Applications')),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listenWhen: (_, state) =>
            state is TeacherLeaveLoaded || state is TeacherLeaveError,
        listener: (context, state) {
          if (state is TeacherLeaveLoaded && state.justSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Leave application sent to the Principal for approval.',
                ),
              ),
            );
          } else if (state is TeacherLeaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        buildWhen: (_, state) =>
            state is TeacherLeaveLoaded ||
            state is TeacherLeaveLoading ||
            state is TeacherLeaveSubmitting ||
            state is TeacherLeaveError,
        builder: (context, state) {
          if (state is TeacherLeaveLoading) {
            return const ShimmerLoading(itemCount: 5, itemHeight: 110);
          }
          if (state is TeacherLeaveError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<TeacherBloc>()
                  .add(LoadTeacherLeaveApplications()),
            );
          }
          final applications =
              state is TeacherLeaveLoaded ? state.applications : <LeaveApplicationModel>[];

          return RefreshIndicator(
            onRefresh: () async => context
                .read<TeacherBloc>()
                .add(LoadTeacherLeaveApplications()),
            child: applications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      EmptyStateWidget(
                        message:
                            'No leave applications yet.\nTap "Apply Leave" to request time off.',
                        icon: Icons.event_available,
                        actionLabel: 'Apply Leave',
                        onAction: _openApplySheet,
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummary(applications),
                      const SizedBox(height: 16),
                      ...applications.map(
                        (l) => _TeacherLeaveCard(
                          application: l,
                          onCancel: l.status == LeaveStatus.pending
                              ? () => _confirmCancel(l)
                              : null,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openApplySheet,
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave'),
      ),
    );
  }

  Widget _buildSummary(List<LeaveApplicationModel> applications) {
    final status = AppStatusColors.of(context);
    final pending =
        applications.where((a) => a.status == LeaveStatus.pending).length;
    final approved =
        applications.where((a) => a.status == LeaveStatus.approved).length;
    final usedDays = applications
        .where((a) => a.status == LeaveStatus.approved)
        .fold<int>(0, (sum, a) => sum + a.totalDays);

    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Pending',
            value: '$pending',
            icon: Icons.hourglass_top,
            color: status.warning,
            caption: 'Awaiting principal',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Approved',
            value: '$approved',
            icon: Icons.verified,
            color: status.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Days Used',
            value: '$usedDays',
            icon: Icons.event_busy,
            color: status.info,
          ),
        ),
      ],
    );
  }

  void _confirmCancel(LeaveApplicationModel leave) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Leave'),
        content: Text(
          'Withdraw your ${leave.type.label} request for '
          '${DateFormatter.formatDate(leave.fromDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<TeacherBloc>()
                  .add(CancelTeacherLeaveApplication(leave.id));
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  Future<void> _openApplySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TeacherBloc>(),
        child: const _TeacherApplyLeaveSheet(),
      ),
    );
  }
}

class _TeacherApplyLeaveSheet extends StatefulWidget {
  const _TeacherApplyLeaveSheet();

  @override
  State<_TeacherApplyLeaveSheet> createState() =>
      _TeacherApplyLeaveSheetState();
}

class _TeacherApplyLeaveSheetState extends State<_TeacherApplyLeaveSheet> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LeaveType _type = LeaveType.casual;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  String? _attachmentName;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: now.subtract(const Duration(days: 15)),
      lastDate: now.add(const Duration(days: 180)),
      helpText: isFrom ? 'Select start date' : 'Select end date',
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      } else {
        _toDate = picked.isBefore(_fromDate) ? _fromDate : picked;
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final profileState = context.read<TeacherBloc>().state;
    final name = profileState is TeacherProfileLoaded
        ? profileState.profile.name
        : 'Teacher';
    final employeeId = profileState is TeacherProfileLoaded
        ? profileState.profile.employeeId
        : 'EMP001';

    final application = LeaveApplicationModel(
      id: '',
      applicantId: employeeId,
      applicantName: name,
      applicantType: LeaveApplicant.teacher,
      type: _type,
      fromDate: _fromDate,
      toDate: _toDate,
      reason: _reasonController.text.trim(),
      appliedOn: DateTime.now(),
      attachmentName: _attachmentName,
    );
    context.read<TeacherBloc>().add(SubmitTeacherLeaveApplication(application));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSubmitting =
        context.watch<TeacherBloc>().state is TeacherLeaveSubmitting;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Apply for Leave',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Your request will be sent to the Principal for approval.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Leave Type',
                style: textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LeaveType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: _type == type,
                    onSelected: (_) => setState(() => _type = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: 'From',
                      date: _fromDate,
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateField(
                      label: 'To',
                      date: _toDate,
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Total ${_toDate.difference(_fromDate).inDays + 1} day(s) of leave',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText:
                      'Provide context for the Principal, e.g. reason, substitute arrangements...',
                  alignLabelWithHint: true,
                ),
              ),

              Card(
                elevation: 0,
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                child: ListTile(
                  leading: Icon(
                    _attachmentName == null
                        ? Icons.attach_file
                        : Icons.check_circle,
                    color: _attachmentName == null
                        ? colorScheme.primary
                        : AppStatusColors.of(context).success,
                  ),
                  title: Text(
                    _attachmentName ?? 'Attach supporting document',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
                  subtitle: const Text('Optional · medical certificate (mock)'),
                  trailing: _attachmentName == null
                      ? const Icon(Icons.add)
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _attachmentName = null),
                        ),
                  onTap: () => setState(() {
                    _attachmentName = 'attachment_${DateTime.now().day}.pdf';
                  }),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : _submit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label:
                      Text(isSubmitting ? 'Sending...' : 'Send to Principal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(DateFormatter.formatDate(date)),
      ),
    );
  }
}

class _TeacherLeaveCard extends StatelessWidget {
  final LeaveApplicationModel application;
  final VoidCallback? onCancel;

  const _TeacherLeaveCard({required this.application, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final status = AppStatusColors.of(context);
    final color = _statusColor(application.status, status);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.event_note, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        application.totalDays == 1
                            ? DateFormatter.formatDate(application.fromDate)
                            : '${DateFormatter.formatDate(application.fromDate)} → ${DateFormatter.formatDate(application.toDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusPillLocal(
                  label: application.status.label,
                  color: color,
                  icon: _statusIcon(application.status),
                ),
              ],
            ),
            if (application.reason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                application.reason,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
            ],
            if (application.principalRemarks != null &&
                application.principalRemarks!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.rate_review, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Principal: ${application.principalRemarks}',
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 9),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Withdraw'),
                  style: TextButton.styleFrom(foregroundColor: status.danger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(LeaveStatus status, AppStatusColors colors) {
    switch (status) {
      case LeaveStatus.approved:
        return colors.success;
      case LeaveStatus.rejected:
        return colors.danger;
      case LeaveStatus.cancelled:
        return colors.neutral;
      case LeaveStatus.pending:
        return colors.warning;
    }
  }

  IconData _statusIcon(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return Icons.check_circle;
      case LeaveStatus.rejected:
        return Icons.cancel;
      case LeaveStatus.cancelled:
        return Icons.block;
      case LeaveStatus.pending:
        return Icons.hourglass_top;
    }
  }
}
