import 'package:flutter/material.dart';

/// A row showing the care completion status for each day of the week.
class CareWeekMask extends StatelessWidget {
  const CareWeekMask({
    super.key,
    required this.weekStartMonday,
    required this.mask,
  });

  final DateTime? weekStartMonday;
  final int mask;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final start = weekStartMonday ?? _mondayOf(DateTime.now());
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week (care day complete)',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                _WeekDayCell(
                  label: labels[i],
                  done: (mask & (1 << i)) != 0,
                  isToday: _isSameDate(
                    start.add(Duration(days: i)),
                    DateTime.now(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime _mondayOf(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return x.subtract(Duration(days: x.weekday - 1));
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.label,
    required this.done,
    required this.isToday,
  });

  final String label;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: done
                ? colorScheme.primary.withValues(alpha: 0.2)
                : colorScheme.surface,
            border: Border.all(
              color: done ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          child: done
              ? Icon(Icons.check, size: 16, color: colorScheme.primary)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
