import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/parent_bloc.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/leave_model.dart';
import '../../auth/models/user_model.dart';

/// Parent-facing leave management: list existing applications, submit a new
/// one with type + date range + optional description, and cancel pending ones.
class ParentLeaveScreen extends StatefulWidget {
  const ParentLeaveScreen({super.key});

  @override
  State<ParentLeaveScreen> createState() => _ParentLeaveScreenState();
}

class _ParentLeaveScreenState extends State<ParentLeaveScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ParentBloc>();
    bloc.add(LoadParentProfile());
  }

  void _loadLeaves(StudentModel child) {
    context.read<ParentBloc>().add(LoadLeaveApplications(child.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Applications')),
      body: BlocBuilder<ParentBloc, ParentState>(
        buildWhen: (_, state) =>
            state is ParentProfileLoaded ||
            state is ParentProfileLoading ||
            state is ParentProfileError,
        builder: (context, state) {
          if (state is ParentProfileLoading) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 90);
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
              _loadLeaves(child);
            });

            return Column(
              children: [
                if (profile.children.length > 1) _buildChildSwitcher(state),
                Expanded(
                  child: BlocConsumer<ParentBloc, ParentState>(
                    listenWhen: (_, state) =>
                        state is ParentLeaveLoaded ||
                        state is ParentLeaveError,
                    listener: (context, state) {
                      if (state is ParentLeaveLoaded && state.justSubmitted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Leave application submitted. Awaiting principal approval.',
                            ),
                          ),
                        );
                      } else if (state is ParentLeaveError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                    },
                    buildWhen: (_, state) =>
                        state is ParentLeaveLoaded ||
                        state is ParentLeaveLoading ||
                        state is ParentLeaveSubmitting ||
                        state is ParentLeaveError,
                    builder: (context, state) {
                      if (state is ParentLeaveLoading) {
                        return const ShimmerLoading(
                          itemCount: 5,
                          itemHeight: 110,
                        );
                      }
                      if (state is ParentLeaveError) {
                        return AppErrorWidget(
                          message: state.message,
                          onRetry: () => _loadLeaves(child),
                        );
                      }
                      final applications = state is ParentLeaveLoaded
                          ? state.applications
                          : <LeaveApplicationModel>[];

                      return RefreshIndicator(
                        onRefresh: () async => _loadLeaves(child),
                        child: applications.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 80),
                                  EmptyStateWidget(
                                    message:
                                        'No leave applications yet.\nTap "Apply Leave" to create one.',
                                    icon: Icons.event_available,
                                    actionLabel: 'Apply Leave',
                                    onAction: () =>
                                        _openApplySheet(child),
                                  ),
                                ],
                              )
                            : ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                children: [
                                  _buildSummary(applications),
                                  const SizedBox(height: 12),
                                  ...applications.map(
                                    (l) => _LeaveCard(
                                      application: l,
                                      onCancel: l.status ==
                                              LeaveStatus.pending
                                          ? () => _confirmCancel(
                                                l,
                                                child,
                                              )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const ShimmerLoading(itemCount: 6, itemHeight: 90);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final state = context.read<ParentBloc>().state;
          if (state is ParentProfileLoaded) {
            _openApplySheet(state.profile.children[state.selectedChildIndex]);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave'),
      ),
    );
  }

  Widget _buildChildSwitcher(ParentProfileLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: state.profile.children.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final child = state.profile.children[index];
            return ChoiceChip(
              label: Text(child.name),
              selected: index == state.selectedChildIndex,
              onSelected: (_) {
                context.read<ParentBloc>().add(SelectChild(index));
                _loadLeaves(child);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(List<LeaveApplicationModel> applications) {
    final status = AppStatusColors.of(context);
    final pending = applications
        .where((a) => a.status == LeaveStatus.pending)
        .length;
    final approved = applications
        .where((a) => a.status == LeaveStatus.approved)
        .length;
    final totalDays = applications
        .where((a) => a.status == LeaveStatus.approved)
        .fold<int>(0, (sum, a) => sum + a.totalDays);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _summaryItem(
                'Pending',
                '$pending',
                status.warning,
                Icons.hourglass_top,
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: _summaryItem(
                'Approved',
                '$approved',
                status.success,
                Icons.verified,
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: _summaryItem(
                'Days',
                '$totalDays',
                status.info,
                Icons.today,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  void _confirmCancel(LeaveApplicationModel leave, StudentModel child) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Leave'),
        content: Text(
          'Cancel the ${leave.type.label} from '
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
                  .read<ParentBloc>()
                  .add(CancelLeaveApplication(leave.id, child.id));
            },
            child: const Text('Cancel Leave'),
          ),
        ],
      ),
    );
  }

  Future<void> _openApplySheet(StudentModel child) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ParentBloc>(),
        child: _ApplyLeaveSheet(child: child),
      ),
    );
  }
}

/// Bottom sheet form used to submit a new leave application.
class _ApplyLeaveSheet extends StatefulWidget {
  final StudentModel child;

  const _ApplyLeaveSheet({required this.child});

  @override
  State<_ApplyLeaveSheet> createState() => _ApplyLeaveSheetState();
}

class _ApplyLeaveSheetState extends State<_ApplyLeaveSheet> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LeaveType _type = LeaveType.sick;
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
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 180)),
      helpText: isFrom ? 'Select start date' : 'Select end date',
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      } else {
        if (picked.isBefore(_fromDate)) {
          _toDate = _fromDate;
        } else {
          _toDate = picked;
        }
      }
    });
  }

  void _attachDocument() {
    // Mocked file picker — real implementation would use file_picker.
    setState(() {
      _attachmentName = 'medical_certificate.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock attachment added.')),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final application = LeaveApplicationModel(
      id: '',
      applicantId: widget.child.id,
      applicantName: widget.child.name,
      className: widget.child.className,
      applicantType: LeaveApplicant.parent,
      type: _type,
      fromDate: _fromDate,
      toDate: _toDate,
      reason: _reasonController.text.trim(),
      appliedOn: DateTime.now(),
      attachmentName: _attachmentName,
    );
    context.read<ParentBloc>().add(SubmitLeaveApplication(application));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSubmitting =
        context.watch<ParentBloc>().state is ParentLeaveSubmitting;
    final textTheme = Theme.of(context).textTheme;

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
              Text(
                'For ${widget.child.name} · ${widget.child.className}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total ${_toDate.difference(_fromDate).inDays + 1} day(s) of leave',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
                      'Add any details the principal should know, e.g. doctor\'s advice, travel plans...',
                  alignLabelWithHint: true,
                ),
              ),

              // Attachment (mock)
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
                  subtitle: const Text('Optional · PDF / JPG (mock)'),
                  trailing: _attachmentName == null
                      ? const Icon(Icons.add)
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _attachmentName = null),
                        ),
                  onTap: _attachDocument,
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
                  label: Text(isSubmitting ? 'Submitting...' : 'Submit Application'),
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

/// A single leave card in the parent list, showing type, dates, status and the
/// principal's remarks when reviewed.
class _LeaveCard extends StatelessWidget {
  final LeaveApplicationModel application;
  final VoidCallback? onCancel;

  const _LeaveCard({required this.application, this.onCancel});

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
                  child: Icon(_typeIcon(application.type), color: color),
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _metaChip(
                  context,
                  Icons.event,
                  '${application.totalDays} day(s)',
                  colorScheme,
                ),
                _metaChip(
                  context,
                  Icons.history,
                  'Applied ${DateFormatter.formatShortDate(application.appliedOn)}',
                  colorScheme,
                ),
                if (application.attachmentName != null)
                  _metaChip(
                    context,
                    Icons.attachment,
                    application.attachmentName!,
                    colorScheme,
                  ),
              ],
            ),
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
                  label: const Text('Cancel Leave'),
                  style: TextButton.styleFrom(foregroundColor: status.danger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metaChip(
    BuildContext context,
    IconData icon,
    String label,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
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

  IconData _typeIcon(LeaveType type) {
    switch (type) {
      case LeaveType.sick:
        return Icons.sick;
      case LeaveType.casual:
        return Icons.wb_sunny_outlined;
      case LeaveType.emergency:
        return Icons.emergency;
      case LeaveType.familyFunction:
        return Icons.celebration;
      case LeaveType.vacation:
        return Icons.flight_takeoff;
      case LeaveType.medical:
        return Icons.local_hospital;
      case LeaveType.sports:
        return Icons.sports_soccer;
      case LeaveType.exam:
        return Icons.assignment;
      case LeaveType.halfDay:
        return Icons.schedule;
      case LeaveType.lateArrival:
        return Icons.more_time;
      case LeaveType.other:
        return Icons.more_horiz;
    }
  }
}

/// Small pill used by the leave card (kept local to avoid cross-imports).
class StatusPillLocal extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const StatusPillLocal({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
