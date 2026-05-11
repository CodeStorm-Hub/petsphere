import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'package:petfolio/core/theme/app_shadows.dart';

/// A card for displaying pet health vitals (weight, temperature, etc.)
class HealthVitalsCard extends StatelessWidget {
  const HealthVitalsCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.trend, // 'up', 'down', 'stable'
    this.onTap,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final String? trend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppBorderRadius.cardRadius,
          boxShadow: AppShadows.small,
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (trend != null) ...[
              const SizedBox(width: AppSpacing.sm),
              _TrendIndicator(trend: trend!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({required this.trend});
  final String trend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    IconData icon;
    Color color;
    
    switch (trend) {
      case 'up':
        icon = Icons.trending_up;
        color = Colors.orange;
        break;
      case 'down':
        icon = Icons.trending_down;
        color = Colors.blue;
        break;
      case 'stable':
      default:
        icon = Icons.trending_flat;
        color = colorScheme.outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}
