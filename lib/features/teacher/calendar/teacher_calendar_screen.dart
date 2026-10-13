import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/teacher_bloc.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../shared/widgets/academic_calendar_view.dart';

/// Full-screen academic calendar for teachers.
class TeacherCalendarScreen extends StatefulWidget {
  const TeacherCalendarScreen({super.key});

  @override
  State<TeacherCalendarScreen> createState() => _TeacherCalendarScreenState();
}

class _TeacherCalendarScreenState extends State<TeacherCalendarScreen> {
  DateTime _month = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(LoadTeacherCalendar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Calendar')),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        buildWhen: (_, state) =>
            state is TeacherCalendarLoaded || state is TeacherCalendarLoading,
        builder: (context, state) {
          if (state is! TeacherCalendarLoaded) {
            return const ShimmerLoading(itemCount: 5, itemHeight: 90);
          }
          final events = state.events;
          if (events.isEmpty) {
            return const EmptyStateWidget(
              message: 'No calendar events published yet.',
              icon: Icons.calendar_month,
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<TeacherBloc>().add(LoadTeacherCalendar()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AcademicCalendarView(
                    month: _month,
                    events: events,
                    selectedDate: _selected,
                    onSelectDate: (d) => setState(() => _selected = d),
                    onChangeMonth: (m) => setState(() => _month = m),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
