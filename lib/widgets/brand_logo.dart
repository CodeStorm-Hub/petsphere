import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum BrandLogoSize {
  small(24),
  medium(48),
  large(120);

  final double size;
  const BrandLogoSize(this.size);
}

enum BrandLogoVariant {
  icon('assets/icon.svg'),
  full('assets/logo_without_slogan.svg'),
  blue('assets/petfolio_logo_blue.svg');

  final String assetPath;
  const BrandLogoVariant(this.assetPath);
}

class BrandLogo extends StatelessWidget {
  final BrandLogoSize? size;
  final double? customSize;
  final Color? color;
  final bool withText;
  final BrandLogoVariant variant;

  const BrandLogo({
    super.key,
    this.size = BrandLogoSize.medium,
    this.customSize,
    this.color,
    this.withText = false,
    this.variant = BrandLogoVariant.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveSize = customSize ?? size?.size ?? BrandLogoSize.medium.size;
    final effectiveColor = color ?? colorScheme.primary;

    final svg = SvgPicture.asset(
      variant.assetPath,
      width: effectiveSize,
      height: effectiveSize,
      colorFilter: variant == BrandLogoVariant.blue 
          ? null // Keep original blue colors
          : ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );

    if (withText && variant == BrandLogoVariant.icon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          svg,
          const SizedBox(width: 10),
          Text(
            'PetFolio',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
              fontSize: effectiveSize * 0.8, // Scale text with logo
            ),
          ),
        ],
      );
    }

    return svg;
  }
}
