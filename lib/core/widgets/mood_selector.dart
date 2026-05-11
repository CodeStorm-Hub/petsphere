import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';
import 'package:petfolio/core/theme/spacing.dart';

/// A reusable mood item data model.
class MoodItem {
  const MoodItem({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;
}

/// A generic mood selector widget for logging pet moods or other emotional states.
class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.moods,
    required this.selectedMoodValue,
    required this.onMoodSelected,
    this.axis = Axis.horizontal,
  });

  final List<MoodItem> moods;
  final String? selectedMoodValue;
  final void Function(String?) onMoodSelected;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.horizontal) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: moods.map((mood) => _MoodButton(
          mood: mood,
          selected: selectedMoodValue == mood.value,
          onTap: () => onMoodSelected(selectedMoodValue == mood.value ? null : mood.value),
        )).toList(),
      );
    } else {
      return Column(
        children: moods.map((mood) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _MoodButton(
            mood: mood,
            selected: selectedMoodValue == mood.value,
            onTap: () => onMoodSelected(selectedMoodValue == mood.value ? null : mood.value),
            isFullWidth: true,
          ),
        )).toList(),
      );
    }
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.mood,
    required this.selected,
    required this.onTap,
    this.isFullWidth = false,
  });

  final MoodItem mood;
  final bool selected;
  final VoidCallback onTap;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.buttonRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: AppBorderRadius.buttonRadius,
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              mood.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
