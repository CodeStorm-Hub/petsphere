import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A selector for logging the pet's mood.
class CareMoodSelector extends ConsumerWidget {
  const CareMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final String? selectedMood;
  final ValueChanged<String?> onMoodSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MoodButton(
          emoji: '😴',
          label: 'Sleepy',
          selected: selectedMood == 'Sleepy',
          onTap: () => onMoodSelected(selectedMood == 'Sleepy' ? null : 'Sleepy'),
        ),
        _MoodButton(
          emoji: '😊',
          label: 'Happy',
          selected: selectedMood == 'Happy',
          onTap: () => onMoodSelected(selectedMood == 'Happy' ? null : 'Happy'),
        ),
        _MoodButton(
          emoji: '🤩',
          label: 'Excited',
          selected: selectedMood == 'Excited',
          onTap: () => onMoodSelected(selectedMood == 'Excited' ? null : 'Excited'),
        ),
      ],
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
