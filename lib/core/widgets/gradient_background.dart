import 'package:flutter/material.dart';

class PetFolioGradientBackground extends StatelessWidget {
  const PetFolioGradientBackground({
    super.key,
    required this.child,
    this.opacity,
  });

  final Widget child;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.8, -0.6),
          radius: 1.5,
          colors: [
            theme.colorScheme.primary.withValues(
              alpha: opacity ?? (isDark ? 0.12 : 0.06),
            ),
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}
