import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/spacing.dart';

class PetfolioEmptyState extends StatelessWidget {
  const PetfolioEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.buttonIcon,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData? buttonIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(120),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.primary.withAlpha(200),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onButtonPressed,
                icon: Icon(buttonIcon ?? Icons.add, size: 18),
                label: Text(buttonText!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
