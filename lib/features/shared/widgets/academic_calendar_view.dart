import 'package:flutter/material.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../auth/models/academic_calendar_model.dart';
import '../../../core/utils/date_formatter.dart';

/// Returns the semantic colour + icon for a calendar event type.
Color calendarEventColor(BuildContext context, CalendarEventType type) {
  final status = AppStatusColors.of(context);
  switch (type) {
    case CalendarEventType.holiday:
      return status.success;
    case CalendarEventType.exam:
      return status.danger;
    case CalendarEventType.event:
      return status.info;
    case CalendarEventType.meeting:
      return status.warning;
    case CalendarEventType.result:
      return status.neutral;
    case CalendarEventType.vacation:
      return status.success;
    case CalendarEventType.activity:
      return status.info;
  }
}

IconData calendarEventIcon(CalendarEventType type) {
  switch (type) {
    case CalendarEventType.holiday:
      return Icons.beach_access;
    case CalendarEventType.exam:
      return Icons.assignment;
    case CalendarEventType.event:
      return Icons.celebration;
    case CalendarEventType.meeting:
      return Icons.groups;
    case CalendarEventType.result:
      return Icons.emoji_events;
    case CalendarEventType.vacation:
      return Icons.flight_takeoff;
    case CalendarEventType.activity:
      return Icons.sports_soccer;
  }
}

/// Month grid + event list for the academic calendar. Kept as a widget so it
/// can be embedded on dashboards and pushed as a full screen alike.
class AcademicCalendarView extends StatelessWidget {
  final DateTime month;
  final List<AcademicCalendarEvent> events;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onChangeMonth;

  const AcademicCalendarView({
    super.key,
    required this.month,
    required this.events,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onChangeMonth,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month navigator
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () =>
                  onChangeMonth(DateTime(month.year, month.month - 1)),
              tooltip: 'Previous month',
            ),
            Expanded(
              child: Text(
                DateFormatter.formatMonthYear(month),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () =>
                  onChangeMonth(DateTime(month.year, month.month + 1)),
              tooltip: 'Next month',
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildWeekdayHeader(context),
        const SizedBox(height: 8),
        _buildMonthGrid(context, colorScheme),
        const SizedBox(height: 16),
        _buildSelectedDayEvents(context),
      ],
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMonthGrid(BuildContext context, ColorScheme colorScheme) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday-first offset: weekday is 1(Mon)..7(Sun)
    final leading = firstDay.weekday - 1;
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final dayNumber = cellIndex - leading + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const Expanded(child: SizedBox(height: 46));
            }
            final date = DateTime(month.year, month.month, dayNumber);
            final dayEvents = events.where((e) => e.occursOn(date)).toList();
            return Expanded(
              child: _DayCell(
                date: date,
                events: dayEvents,
                isSelected: DateFormatter.formatShortDate(date) ==
                    DateFormatter.formatShortDate(selectedDate),
                isToday: DateFormatter.formatShortDate(date) ==
                    DateFormatter.formatShortDate(DateTime.now()),
                onTap: () => onSelectDate(date),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildSelectedDayEvents(BuildContext context) {
    final dayEvents = events.where((e) => e.occursOn(selectedDate)).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.today, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Events on ${DateFormatter.formatDate(selectedDate)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (dayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No events scheduled.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          ...dayEvents.map((e) => CalendarEventTile(event: e)),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final List<AcademicCalendarEvent> events;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final markerColor =
        events.isEmpty ? null : calendarEventColor(context, events.first.type);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : (isToday
                    ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : null),
            borderRadius: BorderRadius.circular(12),
            border: isToday && !isSelected
                ? Border.all(color: colorScheme.primary, width: 1.2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
              if (markerColor != null) ...[
                const SizedBox(height: 3),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.onPrimary : markerColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A single calendar event row (used in the calendar screen and dashboard).
class CalendarEventTile extends StatelessWidget {
  final AcademicCalendarEvent event;
  final bool dense;

  const CalendarEventTile({
    super.key,
    required this.event,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = calendarEventColor(context, event.type);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: dense ? 8 : 10),
      child: Padding(
        padding: EdgeInsets.all(dense ? 12 : 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: dense ? 40 : 46,
              height: dense ? 40 : 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                calendarEventIcon(event.type),
                color: color,
                size: dense ? 20 : 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.isMultiDay
                        ? '${DateFormatter.formatDate(event.date)} → ${DateFormatter.formatDate(event.endDate!)} (${event.spanDays} days)'
                        : DateFormatter.formatDate(event.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (!dense && event.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusPillColor(
              label: event.type.label,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal pill used by [CalendarEventTile] to avoid a circular import with
/// the shared `stat_card.dart` widget file.
class StatusPillColor extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPillColor({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
