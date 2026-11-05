import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/parent_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../auth/models/marks_model.dart';
import '../../shared/widgets/stat_card.dart';

class ParentMarksScreen extends StatefulWidget {
  const ParentMarksScreen({super.key});

  @override
  State<ParentMarksScreen> createState() => _ParentMarksScreenState();
}

class _ParentMarksScreenState extends State<ParentMarksScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ParentBloc>();
    bloc.add(LoadParentProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Marks & progress',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report card download coming soon')),
              );
            },
            tooltip: 'Download report card',
          ),
        ],
      ),
      body: BlocBuilder<ParentBloc, ParentState>(
        buildWhen: (_, state) =>
            state is ParentProfileLoaded ||
            state is ParentProfileLoading,
        builder: (context, state) {
          if (state is ParentProfileLoading) {
            return const ShimmerLoading(itemCount: 6, itemHeight: 80);
          }
          if (state is ParentProfileLoaded) {
            final profile = state.profile;
            final selectedChild =
                profile.children[state.selectedChildIndex];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              context
                  .read<ParentBloc>()
                  .add(LoadStudentMarks(selectedChild.id));
            });

            return Column(
              children: [
                // Child Switcher
                if (profile.children.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInset,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.children.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 4),
                        itemBuilder: (context, index) {
                          final child = profile.children[index];
                          final isSelected =
                              index == state.selectedChildIndex;
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<ParentBloc>()
                                  .add(SelectChild(index));
                              context.read<ParentBloc>().add(
                                  LoadStudentMarks(child.id));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: AppColors.border, width: 1)
                                    : null,
                                boxShadow: isSelected ? AppShadows.subtle : null,
                              ),
                              child: Center(
                                child: Text(
                                  child.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? AppColors.accent : AppColors.inkMuted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: BlocBuilder<ParentBloc, ParentState>(
                    buildWhen: (_, state) =>
                        state is ParentMarksLoaded ||
                        state is ParentMarksLoading ||
                        state is ParentError,
                    builder: (context, state) {
                      if (state is ParentMarksLoading) {
                        return const ShimmerLoading(
                            itemCount: 6, itemHeight: 72);
                      }
                      if (state is ParentError) {
                        return AppErrorWidget(
                          message: state.message,
                          onRetry: () {
                            context.read<ParentBloc>().add(
                                LoadStudentMarks(selectedChild.id));
                          },
                        );
                      }
                      if (state is ParentMarksLoaded) {
                        if (state.marks.isEmpty) {
                          return const EmptyStateWidget(
                            message: 'No marks available',
                            subtitle: 'Examination results will appear here once published.',
                            icon: Icons.grade_outlined,
                          );
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Progress Graph matching DESIGN.md Section 8.3
                              _buildProgressGraph(state.marks),
                              const SizedBox(height: 20),

                              // Teacher Remarks
                              _buildTeacherRemarks(state.marks),
                              const SizedBox(height: 20),

                              // Marks Table
                              Text(
                                'Subject-wise marks',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildMarksTable(state.marks),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      }
                      return const ShimmerLoading(
                          itemCount: 6, itemHeight: 72);
                    },
                  ),
                ),
              ],
            );
          }
          return const ShimmerLoading(itemCount: 6, itemHeight: 80);
        },
      ),
    );
  }

  Widget _buildProgressGraph(List<StudentMarkModel> marks) {
    final examGroups = <String, List<StudentMarkModel>>{};
    for (final m in marks) {
      examGroups.putIfAbsent(m.examId, () => []).add(m);
    }

    final spots = <FlSpot>[];
    final labels = <String>[];
    int index = 0;
    for (final entry in examGroups.entries) {
      final avg = entry.value.fold<double>(0, (s, m) => s + m.percentage) /
          entry.value.length;
      spots.add(FlSpot(index.toDouble(), avg));
      labels.add(entry.value.first.studentName.split(' ').first);
      index++;
    }

    if (spots.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: Text(
            'Additional exam data needed for trajectory trend.',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.inkMuted),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance trajectory',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.borderFaint,
                    strokeWidth: 1,
                    dashArray: [3, 3],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[idx],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.accent,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, _, _) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: AppColors.accent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.14),
                          AppColors.accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherRemarks(List<StudentMarkModel> marks) {
    final remarks = marks
        .where((m) =>
            m.teacherRemarks != null && m.teacherRemarks!.isNotEmpty)
        .toList();
    if (remarks.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Teacher's remarks",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          ...remarks.map((m) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.rate_review_outlined,
                        size: 16, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.studentName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            m.teacherRemarks!,
                            style: GoogleFonts.poppins(
                              color: AppColors.inkSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMarksTable(List<StudentMarkModel> marks) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 18,
          headingRowHeight: 42,
          headingRowColor: const WidgetStatePropertyAll(AppColors.bg),
          columns: [
            DataColumn(
              label: Text(
                'Subject',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Obtained',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '%',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Grade',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
          ],
          rows: marks.map((m) {
            final isPublished = m.status == MarkStatus.published;
            return DataRow(cells: [
              DataCell(
                Text(
                  m.studentName.split(' ').first,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink),
                ),
              ),
              DataCell(
                Text(
                  '${m.obtainedMarks.toInt()}',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  '${m.totalMarks.toInt()}',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.inkMuted),
                ),
              ),
              DataCell(
                Text(
                  '${m.percentage.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: m.percentage >= 40 ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),
              DataCell(
                Text(
                  m.grade,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: m.percentage >= 40 ? AppColors.success : AppColors.danger,
                  ),
                ),
              ),
              DataCell(
                StatusPill.semantic(
                  context,
                  label: isPublished ? 'Published' : 'Draft',
                  kind: isPublished ? 'success' : 'warning',
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
