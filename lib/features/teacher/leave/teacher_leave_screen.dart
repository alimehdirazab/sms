import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../parent/models/leave_api_model.dart';
import '../../parent/repositories/leave_repository.dart';

/// Teacher-facing leave management.
/// Supports 2 types of leaves:
/// 1. Teacher's own leaves record (applicantType = 'TEACHER')
/// 2. Leaves asked by students (applicantType = 'STUDEN')
class TeacherLeaveScreen extends StatefulWidget {
  const TeacherLeaveScreen({super.key});

  @override
  State<TeacherLeaveScreen> createState() => _TeacherLeaveScreenState();
}

class _TeacherLeaveScreenState extends State<TeacherLeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // 2 Types of leaves: TEACHER (own leaves) or STUDEN (student leave requests)
  String _selectedApplicantType = 'TEACHER';

  bool _isLoading = true;
  String? _errorMessage;
  List<LeaveItemModel> _leaves = [];
  int _currentPage = 1;
  bool _hasNextPage = false;

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
    _loadLeaves();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadLeaves(page: 1);
    }
  }

  Future<void> _loadLeaves({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statusFilter = _tabs[_tabController.index];
      final statusParam = statusFilter == LeaveStatus.unknown
          ? null
          : statusFilter.toApiString();

      final leaveRepo = context.read<LeaveRepository>();
      final result = await leaveRepo.getLeaves(
        applicantType: _selectedApplicantType,
        status: statusParam,
        page: page,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _currentPage = result.currentPage;
        _hasNextPage = result.hasNextPage;
        if (page == 1) {
          _leaves = result.items;
        } else {
          _leaves = [..._leaves, ...result.items];
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
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
        title: const Text('Teacher Leaves'),
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
      floatingActionButton: _selectedApplicantType == 'TEACHER'
          ? FloatingActionButton.extended(
              onPressed: _openApplyLeaveModal,
              icon: const Icon(Icons.add),
              label: const Text('Apply Leave'),
            )
          : null,
      body: Column(
        children: [
          // 2 Types Switcher: Teacher's own leaves vs Student leave requests
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: colorScheme.primaryContainer,
                  selectedForegroundColor: colorScheme.onPrimaryContainer,
                ),
                segments: const [
                  ButtonSegment<String>(
                    value: 'TEACHER',
                    label: Text('My Leaves'),
                    icon: Icon(Icons.badge_outlined, size: 18),
                  ),
                  ButtonSegment<String>(
                    value: 'STUDEN',
                    label: Text('Student Leaves'),
                    icon: Icon(Icons.school_outlined, size: 18),
                  ),
                ],
                selected: {_selectedApplicantType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedApplicantType = newSelection.first;
                  });
                  _loadLeaves(page: 1);
                },
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _selectedApplicantType == 'TEACHER'
                    ? 'Search my leaves by type or reason...'
                    : 'Search student requests by name or reason...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _loadLeaves(page: 1);
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _loadLeaves(page: 1),
            ),
          ),

          // Content Area
          Expanded(child: _buildBody(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading && _leaves.isEmpty) {
      return const ShimmerLoading(itemCount: 5, itemHeight: 100);
    }

    if (_errorMessage != null && _leaves.isEmpty) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: () => _loadLeaves(page: 1),
      );
    }

    if (_leaves.isEmpty) {
      final isOwn = _selectedApplicantType == 'TEACHER';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOwn ? Icons.event_available : Icons.school_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isOwn
                  ? 'No teacher leaves found'
                  : 'No student leave requests found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (isOwn)
              FilledButton.tonal(
                onPressed: _openApplyLeaveModal,
                child: const Text('Apply for Leave'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadLeaves(page: 1),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _leaves.length + (_hasNextPage ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _leaves.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () => _loadLeaves(page: _currentPage + 1),
                  child: const Text('Load More'),
                ),
              ),
            );
          }

          final item = _leaves[index];
          return _buildLeaveCard(item);
        },
      ),
    );
  }

  Widget _buildLeaveCard(LeaveItemModel item) {
    final statusColor = _resolveStatusColor(item.status);
    final theme = Theme.of(context);
    final isStudentLeave = _selectedApplicantType == 'STUDEN';

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
              // Top Row: Type and Status
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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

              // Student Info Badge (When viewing student leaves)
              if (isStudentLeave || item.applicantName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 15,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.applicantName.isNotEmpty
                          ? item.applicantName
                          : 'Student',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (item.roleOrClass.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${item.roleOrClass})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (item.studentId != null &&
                        item.studentId!.isNotEmpty) ...[
                      const Spacer(),
                      Text(
                        'ID: ${item.studentId}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // Date Range & Duration
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
                  const Spacer(),
                  Text(
                    '${item.totalDays} day(s)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
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

              // Action Buttons for Pending leaves
              if (item.status == LeaveStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Teacher can withdraw/delete their OWN pending leave
                    if (!isStudentLeave) ...[
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Withdraw'),
                        onPressed: () => _confirmDeleteLeave(item),
                      ),
                    ],
                    // Teacher can APPROVE or REJECT student leaves
                    if (isStudentLeave) ...[
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
                    'Leave Details',
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
              if (item.applicantName.isNotEmpty)
                _detailRow('Applicant Name', item.applicantName),
              if (item.studentId != null && item.studentId!.isNotEmpty)
                _detailRow('Student ID', item.studentId!),
              if (item.roleOrClass.isNotEmpty)
                _detailRow('Role / Class', item.roleOrClass),
              _detailRow('Leave Type', item.leaveType),
              _detailRow('Status', item.status.displayName),
              _detailRow(
                'Duration',
                '${item.startDate} to ${item.endDate} (${item.totalDays} days)',
              ),
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
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        title: const Text('Withdraw Leave Application'),
        content: const Text(
          'Are you sure you want to withdraw this pending leave application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final leaveRepo = context.read<LeaveRepository>();
                await leaveRepo.deleteLeave(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Leave application withdrawn.'),
                    ),
                  );
                  _loadLeaves(page: 1);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Withdraw'),
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
        title: Text(
          '${newStatus == 'APPROVED' ? 'Approve' : 'Reject'} Student Leave',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Provide a reason for ${newStatus.toLowerCase()}ing this request:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: newStatus == 'APPROVED'
                    ? 'Approved as requested.'
                    : 'Exam dates clash with the requested dates.',
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
            onPressed: () async {
              final reason = reasonController.text.trim().isEmpty
                  ? (newStatus == 'APPROVED'
                        ? 'Approved as requested.'
                        : 'Exam dates clash with the requested dates.')
                  : reasonController.text.trim();
              Navigator.pop(ctx);

              try {
                final leaveRepo = context.read<LeaveRepository>();
                await leaveRepo.updateLeaveStatus(
                  leaveId: item.id,
                  status: newStatus,
                  reason: reason,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Leave request $newStatus successfully.'),
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                  _loadLeaves(page: 1);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
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
                      'Apply for Teacher Leave',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: leaveTypeController.text,
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                      ),
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
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
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
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
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
                      onPressed: () async {
                        if (descController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please describe the reason'),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          final leaveRepo = context.read<LeaveRepository>();
                          await leaveRepo.createTeacherLeave(
                            leaveType: leaveTypeController.text,
                            startDate: dateFormat.format(startDate),
                            endDate: dateFormat.format(endDate),
                            description: descController.text.trim(),
                            attachment: 'base64-attachment-demo',
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Leave application submitted successfully.',
                                ),
                              ),
                            );
                            _loadLeaves(page: 1);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Submission failed: $e')),
                            );
                          }
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
