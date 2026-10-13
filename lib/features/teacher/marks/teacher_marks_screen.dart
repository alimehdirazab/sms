import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/animated_button.dart';
import '../../auth/models/marks_model.dart';

// --- Teacher Marks Home ---
class TeacherMarksScreen extends StatelessWidget {
  const TeacherMarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import/Export - Coming soon')),
              );
            },
            tooltip: 'Import/Export',
          ),
        ],
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        buildWhen: (_, state) =>
            state is TeacherClassesLoaded ||
            state is TeacherClassesLoading ||
            state is TeacherError,
        builder: (context, state) {
          if (state is TeacherClassesLoading) {
            return const ShimmerGrid(itemCount: 6, crossAxisCount: 2);
          }
          if (state is TeacherError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<TeacherBloc>().add(LoadTeacherClasses());
              },
            );
          }
          if (state is TeacherClassesLoaded) {
            if (state.classes.isEmpty) {
              return const EmptyStateWidget(
                message: 'No classes assigned.',
                icon: Icons.class_,
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: state.classes.length,
              itemBuilder: (context, index) {
                final className = state.classes[index];
                final colorScheme = Theme.of(context).colorScheme;
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherSubjectsScreen(
                            className: className,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.class_,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            className,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          // Initial state - trigger load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<TeacherBloc>().add(LoadTeacherClasses());
          });
          return const ShimmerGrid(itemCount: 6, crossAxisCount: 2);
        },
      ),
    );
  }
}

// --- Subjects Screen ---
class TeacherSubjectsScreen extends StatelessWidget {
  final String className;

  const TeacherSubjectsScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherSubjectsLoaded && state.selectedClass == className) {
            // Done
          }
        },
        buildWhen: (_, state) =>
            state is TeacherSubjectsLoaded ||
            state is TeacherSubjectsLoading ||
            state is TeacherError,
        builder: (context, state) {
          if (state is TeacherSubjectsLoading) {
            return const ShimmerLoading(itemCount: 5, itemHeight: 72);
          }
          if (state is TeacherError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context
                    .read<TeacherBloc>()
                    .add(LoadTeacherSubjects(className));
              },
            );
          }
          if (state is TeacherSubjectsLoaded &&
              state.selectedClass == className) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.subjects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subject = state.subjects[index];
                final colorScheme = Theme.of(context).colorScheme;
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherExamsScreen(
                            className: className,
                            subject: subject,
                          ),
                        ),
                      );
                    },
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      subject,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<TeacherBloc>().add(LoadTeacherSubjects(className));
          });
          return const ShimmerLoading(itemCount: 5, itemHeight: 72);
        },
      ),
    );
  }
}

// --- Exams Screen ---
class TeacherExamsScreen extends StatelessWidget {
  final String className;
  final String subject;

  const TeacherExamsScreen({
    super.key,
    required this.className,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$subject - Exams'),
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        buildWhen: (_, state) =>
            state is TeacherExamsLoaded ||
            state is TeacherExamsLoading ||
            state is TeacherError,
        builder: (context, state) {
          if (state is TeacherExamsLoading) {
            return const ShimmerLoading(itemCount: 4, itemHeight: 80);
          }
          if (state is TeacherError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context
                    .read<TeacherBloc>()
                    .add(LoadTeacherExams(className, subject));
              },
            );
          }
          if (state is TeacherExamsLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.exams.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final exam = state.exams[index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentMarksEntryScreen(
                            exam: exam,
                          ),
                        ),
                      );
                    },
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: exam.status == MarkStatus.published
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        exam.status == MarkStatus.published
                            ? Icons.check_circle
                            : Icons.edit_note,
                        color: exam.status == MarkStatus.published
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    title: Text(
                      exam.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(exam.subjectName),
                    trailing: Chip(
                      label: Text(
                        exam.status.name.toUpperCase(),
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                      backgroundColor: exam.status == MarkStatus.published
                          ? Colors.green
                          : Colors.orange,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                );
              },
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context
                .read<TeacherBloc>()
                .add(LoadTeacherExams(className, subject));
          });
          return const ShimmerLoading(itemCount: 4, itemHeight: 80);
        },
      ),
    );
  }
}

// --- Student Marks Entry Screen ---
class StudentMarksEntryScreen extends StatefulWidget {
  final ExamModel exam;

  const StudentMarksEntryScreen({super.key, required this.exam});

  @override
  State<StudentMarksEntryScreen> createState() =>
      _StudentMarksEntryScreenState();
}

class _StudentMarksEntryScreenState extends State<StudentMarksEntryScreen> {
  final Map<String, TextEditingController> _obtainedControllers = {};
  final Map<String, TextEditingController> _totalControllers = {};
  final Map<String, TextEditingController> _remarkControllers = {};
  bool _allFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadStudentMarks(widget.exam.id));
  }

  @override
  void dispose() {
    for (final c in _obtainedControllers.values) {
      c.dispose();
    }
    for (final c in _totalControllers.values) {
      c.dispose();
    }
    for (final c in _remarkControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkAllFields() {
    bool allFilled = _obtainedControllers.values.every(
          (c) => c.text.trim().isNotEmpty,
        ) &&
        _totalControllers.values.every(
          (c) => c.text.trim().isNotEmpty,
        );
    if (allFilled != _allFieldsFilled) {
      setState(() {
        _allFieldsFilled = allFilled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.name),
        actions: [
          BlocBuilder<TeacherBloc, TeacherState>(
            builder: (context, state) {
              return const IconButton(
                icon: Icon(Icons.publish),
                // Publish disabled for teacher role; enable for admin
                onPressed: null,
                tooltip: 'Only admin can publish marks',
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherMarksSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.primary,
              ),
            );
          }
        },
        buildWhen: (_, state) =>
            state is TeacherStudentMarksLoaded ||
            state is TeacherStudentMarksLoading ||
            state is TeacherMarksSaving ||
            state is TeacherError,
        builder: (context, state) {
          if (state is TeacherStudentMarksLoading) {
            return const ShimmerLoading(itemCount: 8, itemHeight: 120);
          }
          if (state is TeacherError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context
                    .read<TeacherBloc>()
                    .add(LoadStudentMarks(widget.exam.id));
              },
            );
          }
          if (state is TeacherStudentMarksLoaded ||
              state is TeacherMarksSaving) {
            final marks = state is TeacherStudentMarksLoaded
                ? state.marks
                : <StudentMarkModel>[];

            // Initialize controllers
            for (final mark in marks) {
              if (!_obtainedControllers.containsKey(mark.studentId)) {
                _obtainedControllers[mark.studentId] =
                    TextEditingController(
                        text: mark.obtainedMarks > 0
                            ? mark.obtainedMarks.toString()
                            : '');
                _totalControllers[mark.studentId] = TextEditingController(
                    text: mark.totalMarks > 0
                        ? mark.totalMarks.toString()
                        : '');
                _remarkControllers[mark.studentId] = TextEditingController(
                    text: mark.teacherRemarks ?? '');
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: marks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final mark = marks[index];
                      return _StudentMarkCard(
                        mark: mark,
                        obtainedController:
                            _obtainedControllers[mark.studentId]!,
                        totalController: _totalControllers[mark.studentId]!,
                        remarkController: _remarkControllers[mark.studentId]!,
                        onChanged: _checkAllFields,
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AnimatedBouncyButton(
                          label: 'Save as Draft',
                          icon: Icons.save_outlined,
                          onPressed: (state is TeacherMarksSaving || !_allFieldsFilled)
                              ? null
                              : () {
                                  final updatedMarks = marks.map((m) {
                                    final obtained = double.tryParse(
                                        _obtainedControllers[m.studentId]
                                                ?.text ??
                                            '0');
                                    final total = double.tryParse(
                                        _totalControllers[m.studentId]
                                                ?.text ??
                                            '100');
                                    final remarks =
                                        _remarkControllers[m.studentId]
                                                ?.text
                                                .trim() ??
                                            '';
                                    return m.copyWith(
                                      obtainedMarks: obtained ?? 0,
                                      totalMarks: total ?? 100,
                                      status: MarkStatus.draft,
                                      teacherRemarks:
                                          remarks.isEmpty ? null : remarks,
                                    );
                                  }).toList();
                                  context
                                      .read<TeacherBloc>()
                                      .add(SaveStudentMarks(updatedMarks));
                                },
                        ),
                        if (state is TeacherMarksSaving) ...[
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const ShimmerLoading(itemCount: 8, itemHeight: 120);
        },
      ),
    );
  }
}

class _StudentMarkCard extends StatefulWidget {
  final StudentMarkModel mark;
  final TextEditingController obtainedController;
  final TextEditingController totalController;
  final TextEditingController remarkController;
  final VoidCallback onChanged;

  const _StudentMarkCard({
    required this.mark,
    required this.obtainedController,
    required this.totalController,
    required this.remarkController,
    required this.onChanged,
  });

  @override
  State<_StudentMarkCard> createState() => _StudentMarkCardState();
}

class _StudentMarkCardState extends State<_StudentMarkCard> {
  double _percentage = 0;
  String _grade = '';

  void _calculate() {
    final obtained =
        double.tryParse(widget.obtainedController.text) ?? 0;
    final total = double.tryParse(widget.totalController.text) ?? 100;
    setState(() {
      _percentage = total > 0 ? (obtained / total) * 100 : 0;
      _grade = calculateGrade(_percentage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    widget.mark.rollNumber,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mark.studentName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Roll: ${widget.mark.rollNumber}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.mark.status == MarkStatus.published
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.mark.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.mark.status == MarkStatus.published
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.obtainedController,
                    decoration: const InputDecoration(
                      labelText: 'Obtained',
                      hintText: '0',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      _calculate();
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.totalController,
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      hintText: '100',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      _calculate();
                      widget.onChanged();
                    },
                  ),
                ),
              ],
            ),
            if (_percentage > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${_percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _percentage >= 40
                          ? AppStatusColors.of(context).success
                          : AppStatusColors.of(context).danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _gradeColor(_grade).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Grade: $_grade',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _gradeColor(_grade),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: widget.remarkController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                hintText: 'e.g. Needs improvement in algebra',
                prefixIcon: Icon(Icons.rate_review_outlined, size: 20),
                isDense: true,
              ),
              onChanged: (_) => widget.onChanged(),
            ),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    final colors = AppStatusColors.of(context);
    if (grade == 'A+' || grade == 'A') return colors.success;
    if (grade == 'B+' || grade == 'B') return colors.info;
    if (grade == 'C') return colors.warning;
    return colors.danger;
  }
}
