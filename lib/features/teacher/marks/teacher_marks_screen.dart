import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/teacher_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/animated_button.dart';
import '../../auth/models/marks_model.dart';
import '../../shared/widgets/stat_card.dart';

// --- Teacher Marks Home ---
class TeacherMarksScreen extends StatelessWidget {
  const TeacherMarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Marks management',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import/Export feature coming soon')),
              );
            },
            tooltip: 'Import / Export',
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
                message: 'No classes assigned',
                subtitle: 'Classes assigned by administration will appear here.',
                icon: Icons.school_outlined,
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: state.classes.length,
              itemBuilder: (context, index) {
                final className = state.classes[index];
                return InkWell(
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
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accentTint,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.infoBorder, width: 1),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            size: 22,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          className,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
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
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          className,
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {},
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
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final subject = state.subjects[index];
                return InkWell(
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
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 18,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            subject,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.inkFaint,
                        ),
                      ],
                    ),
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
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          '$subject exams',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
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
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final exam = state.exams[index];
                final isPublished = exam.status == MarkStatus.published;
                return InkWell(
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
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          child: Icon(
                            isPublished
                                ? Icons.check_circle_outline_rounded
                                : Icons.edit_note_rounded,
                            size: 20,
                            color: isPublished ? AppColors.success : AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                exam.subjectName,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusPill.semantic(
                          context,
                          label: isPublished ? 'Published' : 'Draft',
                          kind: isPublished ? 'success' : 'warning',
                        ),
                      ],
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          widget.exam.name,
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.ink,
            letterSpacing: -0.02 * 24,
          ),
        ),
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherMarksSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.accent,
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
            return const ShimmerLoading(itemCount: 6, itemHeight: 140);
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
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBouncyButton(
                          label: 'Save as draft',
                          icon: Icons.save_outlined,
                          isLoading: state is TeacherMarksSaving,
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
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const ShimmerLoading(itemCount: 6, itemHeight: 140);
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
    final isPublished = widget.mark.status == MarkStatus.published;

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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentTint,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.infoBorder, width: 1),
                ),
                child: Center(
                  child: Text(
                    widget.mark.rollNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
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
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Roll no. ${widget.mark.rollNumber}',
                      style: GoogleFonts.poppins(
                        color: AppColors.inkMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill.semantic(
                context,
                label: isPublished ? 'Published' : 'Draft',
                kind: isPublished ? 'success' : 'warning',
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
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${_percentage.toStringAsFixed(1)}%',
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                    color: _percentage >= 40
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
                const SizedBox(width: 10),
                StatusPill.semantic(
                  context,
                  label: 'Grade: $_grade',
                  kind: _percentage >= 40 ? 'success' : 'danger',
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
              prefixIcon: Icon(Icons.rate_review_outlined, size: 18),
              isDense: true,
            ),
            onChanged: (_) => widget.onChanged(),
          ),
        ],
      ),
    );
  }
}
