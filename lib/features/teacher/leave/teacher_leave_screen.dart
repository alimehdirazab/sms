import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../parent/models/leave_api_model.dart';
import '../../parent/repositories/leave_repository.dart';
import '../../shared/widgets/stat_card.dart';

/// Teacher-facing leave management aligned with DESIGN.md.
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Teacher leaves',
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
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.inkMuted,
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
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Apply leave',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          // Segmented Control Pill Track matching DESIGN.md Section 7.4
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceInset,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'My leaves',
                      icon: Icons.badge_outlined,
                      isSelected: _selectedApplicantType == 'TEACHER',
                      onTap: () {
                        if (_selectedApplicantType != 'TEACHER') {
                          setState(() => _selectedApplicantType = 'TEACHER');
                          _loadLeaves(page: 1);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Student leaves',
                      icon: Icons.school_outlined,
                      isSelected: _selectedApplicantType == 'STUDEN',
                      onTap: () {
                        if (_selectedApplicantType != 'STUDEN') {
                          setState(() => _selectedApplicantType = 'STUDEN');
                          _loadLeaves(page: 1);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _selectedApplicantType == 'TEACHER'
                    ? 'Search my leaves by type or reason...'
                    : 'Search student requests by name or reason...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
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
              ),
              onSubmitted: (_) => _loadLeaves(page: 1),
            ),
          ),

          // Content Area
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.border, width: 1)
              : null,
          boxShadow: isSelected ? AppShadows.subtle : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.accent : AppColors.inkMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.accent : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _leaves.isEmpty) {
      return const ShimmerLoading(itemCount: 5, itemHeight: 110);
    }

    if (_errorMessage != null && _leaves.isEmpty) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: () => _loadLeaves(page: 1),
      );
    }

    if (_leaves.isEmpty) {
      final isOwn = _selectedApplicantType == 'TEACHER';
      return EmptyStateWidget(
        message: isOwn ? 'No leave records found' : 'No student requests found',
        subtitle: isOwn
            ? 'All caught up. Submit a leave application when you need time off.'
            : 'No pending student leave requests requiring your review.',
        icon: isOwn ? Icons.event_available_outlined : Icons.school_outlined,
        actionLabel: isOwn ? 'Apply for leave' : null,
        onAction: isOwn ? _openApplyLeaveModal : null,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () async => _loadLeaves(page: 1),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _leaves.length + (_hasNextPage ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _leaves.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () => _loadLeaves(page: _currentPage + 1),
                  child: const Text('Load more'),
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
    final isStudentLeave = _selectedApplicantType == 'STUDEN';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusPill.semantic(
                    context,
                    label: _statusSentenceCase(item.status),
                    kind: item.status.name,
                  ),
                ],
              ),

              // Student Info Badge (When viewing student leaves)
              if (isStudentLeave || item.applicantName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 15,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.applicantName.isNotEmpty
                          ? item.applicantName
                          : 'Student',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                    if (item.roleOrClass.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${item.roleOrClass})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                    if (item.studentId != null &&
                        item.studentId!.isNotEmpty) ...[
                      const Spacer(),
                      Text(
                        'ID: ${item.studentId}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMuted,
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
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.inkMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDateRange(item.startDate, item.endDate),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${item.totalDays} day(s)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),

              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.inkSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Action Buttons for Pending leaves
              if (item.status == LeaveStatus.pending) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isStudentLeave) ...[
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: const Text('Withdraw'),
                        onPressed: () => _confirmDeleteLeave(item),
                      ),
                    ],
                    if (isStudentLeave) ...[
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: const BorderSide(color: AppColors.successBorder),
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        onPressed: () => _updateStatusDialog(item, 'APPROVED'),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.dangerBorder),
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
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

  String _statusSentenceCase(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.withdrawn:
        return 'Withdrawn';
      case LeaveStatus.unknown:
        return 'All';
    }
  }

  void _showLeaveDetailsModal(LeaveItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderHover,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leave details',
                    style: GoogleFonts.instrumentSerif(
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              if (item.applicantName.isNotEmpty)
                _detailRow('Applicant name', item.applicantName),
              if (item.studentId != null && item.studentId!.isNotEmpty)
                _detailRow('Student ID', item.studentId!),
              if (item.roleOrClass.isNotEmpty)
                _detailRow('Class / Section', item.roleOrClass),
              _detailRow('Leave type', item.leaveType),
              _detailRow('Status', _statusSentenceCase(item.status)),
              _detailRow(
                'Duration',
                '${_formatDateRange(item.startDate, item.endDate)} (${item.totalDays} day${item.totalDays == 1 ? '' : 's'})',
              ),
              _detailRow('Reason / description', item.description),
              if (item.reviewReason != null && item.reviewReason!.isNotEmpty)
                _detailRow('Review remark', item.reviewReason!),
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
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : 'None',
            style: GoogleFonts.poppins(
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
        title: Text(
          'Withdraw leave application',
          style: GoogleFonts.instrumentSerif(fontSize: 22, color: AppColors.ink),
        ),
        content: Text(
          'Are you sure you want to withdraw this pending leave application?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.inkSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
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
    final isApprove = newStatus == 'APPROVED';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${isApprove ? 'Approve' : 'Reject'} student leave',
          style: GoogleFonts.instrumentSerif(fontSize: 22, color: AppColors.ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provide a reason for ${isApprove ? 'approving' : 'rejecting'} this request:',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.inkSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: isApprove
                    ? 'Approved as requested.'
                    : 'Exam dates clash with requested absence.',
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
            style: FilledButton.styleFrom(
              backgroundColor: isApprove ? AppColors.success : AppColors.danger,
            ),
            onPressed: () async {
              final reason = reasonController.text.trim().isEmpty
                  ? (isApprove
                        ? 'Approved as requested.'
                        : 'Exam dates clash with requested absence.')
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
                      content: Text('Leave request ${isApprove ? 'approved' : 'rejected'} successfully.'),
                      backgroundColor: isApprove ? AppColors.success : AppColors.danger,
                    ),
                  );
                  _loadLeaves(page: 1);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: Text(isApprove ? 'Approve' : 'Reject'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final dateFormat = DateFormat('yyyy-MM-dd');
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
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
                          color: AppColors.borderHover,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Apply for leave',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: AppColors.ink,
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range_rounded, size: 16),
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
                            icon: const Icon(Icons.date_range_rounded, size: 16),
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
                        labelText: 'Reason / description',
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
