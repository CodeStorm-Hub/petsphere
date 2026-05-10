import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petsphere/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

enum BrandLogoSize {
  small(24),
  medium(48),
  large(120);

  final double size;
  const BrandLogoSize(this.size);
}

enum BrandLogoVariant {
  icon('assets/icon.svg'),
  full('assets/logo_without_slogan.svg');

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
    final isDark = theme.brightness == Brightness.dark;
    const textPrimary = AppTheme.textPrimary;
    final textColor = isDark ? const Color(0xFFF5F5F5) : textPrimary;

    final svg = SvgPicture.asset(
      variant.assetPath,
      width: effectiveSize,
      height: effectiveSize,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );

    if (withText && variant == BrandLogoVariant.icon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          svg,
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Pet ',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.w900,
                    color: isDark ? textColor : textPrimary,
                    fontSize: effectiveSize * 0.7,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Folio',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.w900,
                    color: effectiveColor,
                    fontSize: effectiveSize * 0.7,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return svg;
  }
}
