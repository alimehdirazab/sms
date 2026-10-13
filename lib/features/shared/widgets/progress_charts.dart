import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A lightweight, dependency-free mini bar chart used to visualise progress
/// series (e.g. marks percentage across exams, weekly attendance). Provides its
/// own value labels and remains overflow-safe inside any Column/Card.
class MiniBarChart extends StatelessWidget {
  /// Labels for each bar, shown under the bar.
  final List<String> labels;

  /// Values in the range 0..[maxValue].
  final List<double> values;

  final double maxValue;
  final Color color;
  final double height;
  final String? valueSuffix;

  const MiniBarChart({
    super.key,
    required this.labels,
    required this.values,
    this.maxValue = 100,
    required this.color,
    this.height = 160,
    this.valueSuffix = '%',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Not enough data yet.',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final raw = values[index];
          final safeValue = raw.isFinite ? raw : 0.0;
          final ratio = maxValue == 0
              ? 0.0
              : (safeValue / maxValue).clamp(0.0, 1.0).toDouble();
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${safeValue.toStringAsFixed(0)}$valueSuffix',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Container(
                        height: math.max(6, value * (height - 44)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              color,
                              color.withValues(alpha: 0.55),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                            bottom: Radius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A horizontal progress bar with a label and percentage used for attendance /
/// completion summaries.
class ProgressStatBar extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;
  final String? trailingLabel;

  const ProgressStatBar({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final clamped = percentage.clamp(0, 100).toDouble() / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trailingLabel ?? '${percentage.toStringAsFixed(1)}%',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
      ],
    );
  }
}
