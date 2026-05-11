import 'package:flutter/material.dart';
import 'package:petfolio/features/care/data/models/pet_care_log_model.dart';

/// A reusable task card for the Pet Care checklist.
class CareTaskCard extends StatelessWidget {
  const CareTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
  });

  final DailyTask task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = task.done;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone
              ? colorScheme.secondary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? colorScheme.secondary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDone ? colorScheme.secondary : colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? colorScheme.secondary
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Icon(
                task.icon,
                color: isDone
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    task.subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone
                  ? colorScheme.secondary
                  : colorScheme.outlineVariant,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
