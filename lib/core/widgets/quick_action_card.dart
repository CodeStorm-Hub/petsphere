import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';
import 'package:petfolio/core/theme/icon_sizes.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'package:petfolio/core/theme/app_shadows.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final effectiveColor = color ?? cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppBorderRadius.cardRadius,
          border: Border.all(color: cs.outline.withAlpha(50)),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: effectiveColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: effectiveColor,
                size: AppIconSizes.l,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

