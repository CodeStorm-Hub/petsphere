import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';

import 'package:petfolio/core/theme/app_theme.dart';
import 'package:petfolio/core/theme/spacing.dart';

class CareTaskCard extends StatelessWidget {
  const CareTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.onChanged,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final ValueChanged<bool?> onChanged;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final shadows = theme.extension<PetFolioShadows>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isCompleted
            ? cs.primaryContainer.withValues(alpha: 0.3)
            : cs.surfaceContainerLowest,
        borderRadius: AppBorderRadius.cardRadius,
        boxShadow: shadows.card,
        border: Border.all(
          color: isCompleted
              ? cs.primary.withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppBorderRadius.cardRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? cs.primary
                        : cs.primary.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.circularMd,
                  ),
                  child: Icon(
                    icon,
                    color: isCompleted ? cs.onPrimary : cs.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? cs.onSurface.withValues(alpha: 0.5)
                              : cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: AppSpacing.s),
                ],
                Checkbox(
                  value: isCompleted,
                  onChanged: onChanged,
                  activeColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
