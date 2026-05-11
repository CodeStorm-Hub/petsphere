import 'package:flutter/material.dart';

/// A circular progress indicator with a label and center text for care goals.
class CareGoalProgressRing extends StatelessWidget {
  const CareGoalProgressRing({
    super.key,
    required this.label,
    required this.progress,
    required this.color,
    required this.centerText,
    this.size = 72,
    this.strokeWidth = 8,
  });

  final String label;
  final double progress;
  final Color color;
  final String centerText;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueDescription = centerText.replaceAll('\n', ' ');
    final pctRounded = (progress.clamp(0.0, 1.0) * 100).round();

    return Semantics(
      label: '$label, $valueDescription, $pctRounded percent',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: strokeWidth,
                    backgroundColor: colorScheme.outlineVariant,
                    color: color,
                  ),
                ),
                Center(
                  child: Text(
                    centerText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size * 0.18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
