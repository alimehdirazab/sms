import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/parent_bloc.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../shared/widgets/academic_calendar_view.dart';

/// Full-screen academic calendar for parents.
class ParentCalendarScreen extends StatefulWidget {
  const ParentCalendarScreen({super.key});

  @override
  State<ParentCalendarScreen> createState() => _ParentCalendarScreenState();
}

class _ParentCalendarScreenState extends State<ParentCalendarScreen> {
  DateTime _month = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<ParentBloc>().add(LoadAcademicCalendar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Calendar')),
      body: BlocBuilder<ParentBloc, ParentState>(
        buildWhen: (_, state) =>
            state is ParentCalendarLoaded || state is ParentCalendarLoading,
        builder: (context, state) {
          if (state is! ParentCalendarLoaded) {
            return const ShimmerLoading(itemCount: 5, itemHeight: 90);
          }
          if (state.events.isEmpty) {
            return const EmptyStateWidget(
              message: 'No calendar events published yet.',
              icon: Icons.calendar_month,
            );
          }
          final events = state.events;
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ParentBloc>().add(LoadAcademicCalendar()),
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
