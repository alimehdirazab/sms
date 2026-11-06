import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/models/user_model.dart';
import '../../shared/widgets/stat_card.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/parent_bloc.dart';
import '../models/leave_api_model.dart';
import '../repositories/leave_repository.dart';

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
            applicantType: widget.isTeacher ? 'TEACHER' : 'STUDENT',
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.isTeacher ? 'Teacher leaves' : 'Student leaves',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.border,
          labelColor: AppColors.ink,
          unselectedLabelColor: AppColors.inkMuted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
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
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Apply leave',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'Search leaves by reason or type...',
                hintStyle: const TextStyle(
                  color: AppColors.inkMuted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.inkSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.inkSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _fetchLeaves();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.accent),
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
                      backgroundColor: AppColors.ink,
                    ),
                  );
                } else if (state is LeaveLoaded && state.actionErrorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionErrorMessage!),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                } else if (state is LeaveError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.danger,
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
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceInset,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.borderFaint),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.event_busy_outlined,
                                size: 26,
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No leaves found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'There are no leave applications matching your current filter.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _openApplyLeaveModal,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Apply leave'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _fetchLeaves(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: items.length + (state.hasNextPage ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: OutlinedButton(
                                onPressed: () =>
                                    _fetchLeaves(page: state.currentPage + 1),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.ink,
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                child: const Text('Load more'),
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
    String kind = 'neutral';
    if (item.status == LeaveStatus.approved) {
      kind = 'success';
    } else if (item.status == LeaveStatus.rejected) {
      kind = 'danger';
    } else if (item.status == LeaveStatus.pending) {
      kind = 'warning';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusPill.semantic(
                      context,
                      label: item.status.displayName,
                      kind: kind,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.inkSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateRange(item.startDate, item.endDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    if (item.studentId != null && item.studentId!.isNotEmpty) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceInset,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(color: AppColors.borderFaint),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 13,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID: ${item.studentId}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.inkSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (item.status == LeaveStatus.pending) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, thickness: 1, color: AppColors.borderFaint),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Requester can delete pending
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                        onPressed: () => _confirmDeleteLeave(item),
                      ),
                      if (widget.isTeacher) ...[
                        const SizedBox(width: 8),
                        // Teacher can approve or reject
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: AppColors.successBorder),
                            backgroundColor: AppColors.successBg,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          onPressed: () => _updateStatusDialog(item, 'APPROVED'),
                          child: const Text('Approve'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.dangerBorder),
                            backgroundColor: AppColors.dangerBg,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
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
      ),
    );
  }

  void _showLeaveDetailsModal(LeaveItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leave request details',
                    style: GoogleFonts.instrumentSerif(
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                      color: AppColors.ink,
                      letterSpacing: -0.02 * 22,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.inkMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 16, thickness: 1, color: AppColors.borderFaint),
              const SizedBox(height: 4),
              _detailRow('Leave type', item.leaveType),
              _detailRow('Status', item.status.displayName),
              _detailRow('Duration', _formatDateRange(item.startDate, item.endDate)),
              if (item.studentId != null && item.studentId!.isNotEmpty)
                _detailRow('Student ID', item.studentId!),
              if (item.applicantType.isNotEmpty)
                _detailRow('Applicant type', item.applicantType),
              _detailRow('Reason / Description', item.description),
              if (item.reviewReason != null && item.reviewReason!.isNotEmpty)
                _detailRow('Review reason', item.reviewReason!),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null || start.trim().isEmpty) return '—';
    try {
      final s = DateTime.parse(start.trim());
      final formattedStart = DateFormat('dd MMM yyyy').format(s);
      if (end == null || end.trim().isEmpty || end.trim() == start.trim()) {
        return formattedStart;
      }
      final e = DateTime.parse(end.trim());
      final formattedEnd = DateFormat('dd MMM yyyy').format(e);
      return '$formattedStart → $formattedEnd';
    } catch (_) {
      if (end != null && end.isNotEmpty && end != start) {
        return '$start → $end';
      }
      return start;
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : 'None',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLeave(LeaveItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Delete leave request',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.ink,
          ),
        ),
        content: const Text(
          'Are you sure you want to permanently delete this pending leave request?',
          style: TextStyle(color: AppColors.inkSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.inkSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          '${newStatus == 'APPROVED' ? 'Approve' : 'Reject'} leave',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provide a reason for ${newStatus.toLowerCase()}ing this request:',
              style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: newStatus == 'APPROVED'
                    ? 'Approved as requested.'
                    : 'Exams are scheduled on the requested dates.',
                hintStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
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
            style: FilledButton.styleFrom(
              backgroundColor: newStatus == 'APPROVED' ? AppColors.accent : AppColors.danger,
            ),
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

    // Resolve children and active child ID for parent flow
    final parentBlocState = context.read<ParentBloc>().state;
    List<StudentModel> children = [];
    String? selectedStudentId;

    if (!widget.isTeacher && parentBlocState is ParentProfileLoaded) {
      children = parentBlocState.profile.children;
      if (children.isNotEmpty) {
        if (widget.studentId != null && LeaveRepository.isValidUuid(widget.studentId)) {
          selectedStudentId = widget.studentId;
        } else if (parentBlocState.selectedChildIndex < children.length) {
          selectedStudentId = children[parentBlocState.selectedChildIndex].id;
        } else {
          selectedStudentId = children.first.id;
        }
      }
    }

    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final dateFormat = DateFormat('yyyy-MM-dd');
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isTeacher ? 'Apply teacher leave' : 'Apply student leave',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
                        color: AppColors.ink,
                        letterSpacing: -0.02 * 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: leaveTypeController.text,
                      decoration: const InputDecoration(
                        labelText: 'Leave type',
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
                    if (!widget.isTeacher && children.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStudentId,
                        decoration: const InputDecoration(
                          labelText: 'Select student',
                        ),
                        items: children.map((c) {
                          final label = c.className.isNotEmpty
                              ? '${c.name} (${c.className})'
                              : c.name;
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedStudentId = val;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today_outlined, size: 16),
                            label: Text(
                              dateFormat.format(startDate),
                              style: const TextStyle(fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.ink,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            ),
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
                            icon: const Icon(Icons.calendar_today_outlined, size: 16),
                            label: Text(
                              dateFormat.format(endDate),
                              style: const TextStyle(fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.ink,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            ),
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
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
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
                                ),
                              );
                        } else {
                          context.read<LeaveBloc>().add(
                                CreateParentLeaveRequested(
                                  leaveType: leaveTypeController.text,
                                  startDate: dateFormat.format(startDate),
                                  endDate: dateFormat.format(endDate),
                                  description: descController.text.trim(),
                                  studentId: selectedStudentId,
                                ),
                              );
                        }
                      },
                      child: const Text('Submit application'),
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
