import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../auth/models/attendance_model.dart';
import '../../shared/widgets/stat_card.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadTeacherAttendance());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'My attendance',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              size: 20,
              color: _dateRange != null ? AppColors.accent : AppColors.inkSecondary,
            ),
            onPressed: _pickDateRange,
            tooltip: 'Filter by date',
          ),
          if (_dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _dateRange = null;
                });
              },
              tooltip: 'Clear filter',
            ),
        ],
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        buildWhen: (_, state) =>
            state is TeacherAttendanceLoaded ||
            state is TeacherAttendanceLoading ||
            state is TeacherAttendanceError,
        builder: (context, state) {
          if (state is TeacherAttendanceLoading) {
            return const ShimmerLoading(itemCount: 8, itemHeight: 76);
          }
          if (state is TeacherAttendanceError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<TeacherBloc>().add(LoadTeacherAttendance());
              },
            );
          }
          if (state is TeacherAttendanceLoaded) {
            final records = _filterRecords(state.records);
            if (records.isEmpty) {
              return const EmptyStateWidget(
                message: 'No attendance records found',
                subtitle: 'All caught up. Attendance logs will appear here.',
                icon: Icons.event_busy_outlined,
              );
            }
            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () async {
                context.read<TeacherBloc>().add(LoadTeacherAttendance());
              },
              child: Column(
                children: [
                  if (_dateRange != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceInset,
                        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                      ),
                      child: Text(
                        'Showing: ${DateFormatter.formatShortDate(_dateRange!.start)} – ${DateFormatter.formatShortDate(_dateRange!.end)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.inkSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _AttendanceCard(
                          record: record,
                          onCorrectionRequest: () =>
                              _showCorrectionDialog(record),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const ShimmerLoading(itemCount: 8, itemHeight: 76);
        },
      ),
    );
  }

  List<AttendanceModel> _filterRecords(List<AttendanceModel> records) {
    if (_dateRange == null) return records;
    return records.where((r) {
      return r.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
          r.date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _showCorrectionDialog(AttendanceModel record) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Attendance correction',
          style: GoogleFonts.instrumentSerif(fontSize: 22, color: AppColors.ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specify the reason for modifying your attendance record:',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.inkSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for correction',
                hintText: 'e.g., Forgot to check in at main gate',
              ),
              maxLines: 3,
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
              if (reasonController.text.trim().isNotEmpty) {
                context.read<TeacherBloc>().add(
                      SubmitAttendanceCorrection(
                        record.id,
                        reasonController.text.trim(),
                      ),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Correction request submitted.'),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceModel record;
  final VoidCallback onCorrectionRequest;

  const _AttendanceCard({
    required this.record,
    required this.onCorrectionRequest,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = switch (record.status) {
      AttendanceStatus.present => (Icons.check_circle_outline_rounded, AppColors.success),
      AttendanceStatus.late => (Icons.access_time_rounded, AppColors.warning),
      AttendanceStatus.absent => (Icons.highlight_off_rounded, AppColors.danger),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceInset,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatDate(record.date),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildTimeChip(
                      'In: ${record.checkInTime != null ? DateFormatter.formatTime(record.checkInTime!) : '--'}',
                    ),
                    const SizedBox(width: 8),
                    _buildTimeChip(
                      'Out: ${record.checkOutTime != null ? DateFormatter.formatTime(record.checkOutTime!) : '--'}',
                    ),
                  ],
                ),
                if (record.status == AttendanceStatus.absent) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onCorrectionRequest,
                    child: Text(
                      'Request correction',
                      style: GoogleFonts.poppins(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill.semantic(
            context,
            label: _statusSentenceCase(record.status),
            kind: record.status.name,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: AppColors.inkSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _statusSentenceCase(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }
}
