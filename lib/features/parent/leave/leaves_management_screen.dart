import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../bloc/leave_bloc.dart';
import '../models/leave_api_model.dart';

class LeavesManagementScreen extends StatefulWidget {
  final bool isTeacher;
  final String? studentId;

  const LeavesManagementScreen({
    super.key,
    this.isTeacher = false,
    this.studentId,
  });

  @override
  State<LeavesManagementScreen> createState() => _LeavesManagementScreenState();
}

class _LeavesManagementScreenState extends State<LeavesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<LeaveStatus> _tabs = [
    LeaveStatus.unknown, // All
    LeaveStatus.pending,
    LeaveStatus.approved,
    LeaveStatus.rejected,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchLeaves();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _fetchLeaves();
    }
  }

  void _fetchLeaves({int page = 1}) {
    final status = _tabs[_tabController.index];
    context.read<LeaveBloc>().add(
          LoadLeavesRequested(
            status: status,
            page: page,
            applicantType: widget.isTeacher ? 'TEACHER' : null,
            studentId: widget.studentId,
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
          ),
        );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTeacher ? 'Teacher Leaves' : 'Student Leaves'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openApplyLeaveModal,
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search leaves by reason or type...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _fetchLeaves();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _fetchLeaves(),
            ),
          ),
          Expanded(
            child: BlocConsumer<LeaveBloc, LeaveState>(
              listener: (context, state) {
                if (state is LeaveLoaded && state.actionSuccessMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionSuccessMessage!),
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                } else if (state is LeaveError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is LeaveLoading) {
                  return const ShimmerLoading(itemCount: 6, itemHeight: 90);
                }

                if (state is LeaveError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: _fetchLeaves,
                  );
                }

                if (state is LeaveLoaded) {
                  final items = state.leaves;
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No leaves found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: _openApplyLeaveModal,
                            child: const Text('Submit Application'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _fetchLeaves(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length + (state.hasNextPage ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: OutlinedButton(
                                onPressed: () =>
                                    _fetchLeaves(page: state.currentPage + 1),
                                child: const Text('Load More'),
                              ),
                            ),
                          );
                        }

                        final item = items[index];
                        return _buildLeaveCard(item);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(LeaveItemModel item) {
    final statusColor = _resolveStatusColor(item.status);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showLeaveDetailsModal(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.leaveType,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status.displayName,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item.startDate} → ${item.endDate}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (item.studentId != null && item.studentId!.isNotEmpty) ...[
                    const Spacer(),
                    Icon(
                      Icons.school_outlined,
                      size: 15,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ID: ${item.studentId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.status == LeaveStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Requester can delete pending
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      onPressed: () => _confirmDeleteLeave(item),
                    ),
                    if (widget.isTeacher) ...[
                      const SizedBox(width: 8),
                      // Teacher can approve or reject
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _updateStatusDialog(item, 'APPROVED'),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _updateStatusDialog(item, 'REJECTED'),
                        child: const Text('Reject'),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _resolveStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return Colors.green.shade700;
      case LeaveStatus.rejected:
        return Colors.red.shade700;
      case LeaveStatus.pending:
        return Colors.orange.shade800;
      case LeaveStatus.withdrawn:
      case LeaveStatus.unknown:
        return Colors.grey.shade700;
    }
  }

  void _showLeaveDetailsModal(LeaveItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leave Request Details',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _detailRow('Leave Type', item.leaveType),
              _detailRow('Status', item.status.displayName),
              _detailRow('Duration', '${item.startDate} to ${item.endDate}'),
              if (item.studentId != null)
                _detailRow('Student ID', item.studentId!),
              if (item.applicantType.isNotEmpty)
                _detailRow('Applicant Type', item.applicantType),
              _detailRow('Reason / Description', item.description),
              if (item.reviewReason != null && item.reviewReason!.isNotEmpty)
                _detailRow('Review Reason', item.reviewReason!),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : 'None',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLeave(LeaveItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Leave Request'),
        content: const Text(
          'Are you sure you want to permanently delete this pending leave request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LeaveBloc>().add(DeleteLeaveRequested(leaveId: item.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateStatusDialog(LeaveItemModel item, String newStatus) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${newStatus == 'APPROVED' ? 'Approve' : 'Reject'} Leave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Provide a reason for ${newStatus.toLowerCase()}ing this request:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: newStatus == 'APPROVED'
                    ? 'Approved as requested.'
                    : 'Exams are scheduled on the requested dates.',
                border: const OutlineInputBorder(),
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
              final reason = reasonController.text.trim().isEmpty
                  ? (newStatus == 'APPROVED'
                      ? 'Approved as requested.'
                      : 'Exams are scheduled on the requested dates.')
                  : reasonController.text.trim();
              Navigator.pop(ctx);
              context.read<LeaveBloc>().add(
                    UpdateLeaveStatusRequested(
                      leaveId: item.id,
                      status: newStatus,
                      reason: reason,
                    ),
                  );
            },
            child: Text(newStatus == 'APPROVED' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _openApplyLeaveModal() {
    final leaveTypeController = TextEditingController(text: 'Casual Leave');
    final descController = TextEditingController();
    final studentIdController = TextEditingController(text: widget.studentId ?? '768-9876');
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final dateFormat = DateFormat('yyyy-MM-dd');
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.isTeacher ? 'Apply Teacher Leave' : 'Apply Student Leave',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: leaveTypeController.text,
                      decoration: const InputDecoration(labelText: 'Leave Type'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Casual Leave',
                          child: Text('Casual Leave'),
                        ),
                        DropdownMenuItem(
                          value: 'Sick Leave',
                          child: Text('Sick Leave'),
                        ),
                        DropdownMenuItem(
                          value: 'Medical Leave',
                          child: Text('Medical Leave'),
                        ),
                        DropdownMenuItem(
                          value: 'Emergency Leave',
                          child: Text('Emergency Leave'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) leaveTypeController.text = val;
                      },
                    ),
                    if (!widget.isTeacher) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: studentIdController,
                        decoration: const InputDecoration(
                          labelText: 'Student ID',
                          hintText: 'e.g. 768-9876',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range, size: 18),
                            label: Text(dateFormat.format(startDate)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  startDate = picked;
                                  if (endDate.isBefore(startDate)) {
                                    endDate = startDate;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range, size: 18),
                            label: Text(dateFormat.format(endDate)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  endDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Reason / Description',
                        hintText: 'Explain the reason for requesting leave...',
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        if (descController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please describe the reason')),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        if (widget.isTeacher) {
                          context.read<LeaveBloc>().add(
                                CreateTeacherLeaveRequested(
                                  leaveType: leaveTypeController.text,
                                  startDate: dateFormat.format(startDate),
                                  endDate: dateFormat.format(endDate),
                                  description: descController.text.trim(),
                                  attachment: 'base64-attachment-demo',
                                ),
                              );
                        } else {
                          context.read<LeaveBloc>().add(
                                CreateParentLeaveRequested(
                                  leaveType: leaveTypeController.text,
                                  startDate: dateFormat.format(startDate),
                                  endDate: dateFormat.format(endDate),
                                  description: descController.text.trim(),
                                  studentId: studentIdController.text.trim(),
                                  attachment: 'base64-attachment-demo',
                                ),
                              );
                        }
                      },
                      child: const Text('Submit Application'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
