import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';

import 'package:petfolio/core/theme/app_theme.dart';
import 'package:petfolio/core/theme/spacing.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadows = theme.extension<PetFolioShadows>()!;
    final effectiveBorderRadius = borderRadius ?? AppBorderRadius.cardRadius;

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: shadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap == null
            ? card
            : InkWell(
                borderRadius: effectiveBorderRadius,
                onTap: onTap,
                child: card,
              ),
      ),
    );
  }
}
