import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../auth/models/attendance_model.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _dateRange != null ? colorScheme.primary : null,
            ),
            onPressed: _pickDateRange,
            tooltip: 'Filter by date',
          ),
          if (_dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
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
            return const ShimmerLoading(itemCount: 10, itemHeight: 72);
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
                message: 'No attendance records found.',
                icon: Icons.event_busy,
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TeacherBloc>().add(LoadTeacherAttendance());
              },
              child: Column(
                children: [
                  if (_dateRange != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: colorScheme.primaryContainer,
                      child: Text(
                        'Showing: ${DateFormatter.formatShortDate(_dateRange!.start)} - ${DateFormatter.formatShortDate(_dateRange!.end)}',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
          return const ShimmerLoading(itemCount: 10, itemHeight: 72);
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
        title: const Text('Attendance Correction'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for correction',
            hintText: 'e.g., Forgot to check-in',
          ),
          maxLines: 3,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor(record.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _statusIcon(record.status),
                color: _statusColor(record.status),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatDate(record.date),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTimeChip(
                        'In: ${record.checkInTime != null ? DateFormatter.formatTime(record.checkInTime!) : '--'}',
                        colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildTimeChip(
                        'Out: ${record.checkOutTime != null ? DateFormatter.formatTime(record.checkOutTime!) : '--'}',
                        colorScheme.secondary,
                      ),
                    ],
                  ),
                  if (record.status == AttendanceStatus.absent) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onCorrectionRequest,
                      child: Text(
                        'Request Correction',
                        style: TextStyle(
                          color: colorScheme.primary,
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
            Chip(
              label: Text(
                record.status.name.toUpperCase(),
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
              backgroundColor: _statusColor(record.status),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }

  IconData _statusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.warning_amber;
      case AttendanceStatus.absent:
        return Icons.cancel;
    }
  }
}
