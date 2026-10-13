import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/parent_bloc.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../auth/models/marks_model.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks & Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report Card download - Coming soon')),
              );
            },
            tooltip: 'Download Report Card',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.children.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final child = profile.children[index];
                          final isSelected =
                              index == state.selectedChildIndex;
                          return ChoiceChip(
                            label: Text(child.name),
                            selected: isSelected,
                            onSelected: (_) {
                              context
                                  .read<ParentBloc>()
                                  .add(SelectChild(index));
                              context.read<ParentBloc>().add(
                                  LoadStudentMarks(child.id));
                            },
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
                            message: 'No marks available.',
                            icon: Icons.grade_outlined,
                          );
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Progress Graph
                              _buildProgressGraph(state.marks, colorScheme),
                              const SizedBox(height: 20),

                              // Teacher Remarks
                              _buildTeacherRemarks(state.marks, colorScheme),
                              const SizedBox(height: 20),

                              // Marks Table
                              Text(
                                'Subject-wise Marks',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _buildMarksTable(state.marks, colorScheme),
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

  Widget _buildProgressGraph(
      List<StudentMarkModel> marks, ColorScheme colorScheme) {
    // Group by exam and calculate average
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
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'More exam data needed for progress graph.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Graph',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 11),
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
                              child: Text(labels[idx],
                                  style: const TextStyle(fontSize: 10)),
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
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, _, _, _) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherRemarks(
      List<StudentMarkModel> marks, ColorScheme colorScheme) {
    final remarks = marks
        .where((m) =>
            m.teacherRemarks != null && m.teacherRemarks!.isNotEmpty)
        .toList();
    if (remarks.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Teacher's Remarks",
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...remarks.map((m) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.comment,
                          size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.studentName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              m.teacherRemarks!,
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksTable(
      List<StudentMarkModel> marks, ColorScheme colorScheme) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          columns: const [
            DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Obtained', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('%', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: marks.map((m) {
            return DataRow(cells: [
              DataCell(Text(m.studentName.split(' ').first,
                  style: const TextStyle(fontSize: 13))),
              DataCell(Text('${m.obtainedMarks.toInt()}')),
              DataCell(Text('${m.totalMarks.toInt()}')),
              DataCell(Text('${m.percentage.toStringAsFixed(1)}%')),
              DataCell(Text(m.grade,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: m.percentage >= 40 ? Colors.green : Colors.red,
                  ))),
              DataCell(Chip(
                label: Text(m.status.name.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
                backgroundColor: m.status == MarkStatus.published
                    ? Colors.green
                    : Colors.orange,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
