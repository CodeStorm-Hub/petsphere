import 'package:flutter/material.dart';

/// A banner showing the current care streak and recent daily completion status.
class CareStreakBanner extends StatelessWidget {
  const CareStreakBanner({
    super.key,
    required this.streakDays,
    required this.flags,
  });

  final int streakDays;
  final List<bool> flags;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                streakDays > 0
                    ? '$streakDays-Day Streak!'
                    : 'Start today\u2019s streak',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < flags.length; i++)
                _StreakDot(label: 'D${i + 1}', complete: flags[i]),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakDot extends StatelessWidget {
  const _StreakDot({required this.label, required this.complete});

  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: complete
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.surface,
        border: Border.all(
          color: complete ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      alignment: Alignment.center,
      child: complete
          ? Icon(Icons.check, size: 16, color: colorScheme.primary)
          : Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}
