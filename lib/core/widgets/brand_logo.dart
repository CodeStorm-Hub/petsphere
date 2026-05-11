import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petfolio/core/theme/colors.dart';
import 'package:petfolio/core/theme/icon_sizes.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'package:google_fonts/google_fonts.dart';

enum BrandLogoSize {
  small(AppIconSizes.m),
  medium(AppIconSizes.xxl),
  large(120);

  const BrandLogoSize(this.size);
  final double size;
}

enum BrandLogoVariant {
  icon('assets/icon.svg'),
  full('assets/logo_without_slogan.svg');

  const BrandLogoVariant(this.assetPath);
  final String assetPath;
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = BrandLogoSize.medium,
    this.customSize,
    this.color,
    this.withText = false,
    this.variant = BrandLogoVariant.icon,
  });

  final BrandLogoSize? size;
  final double? customSize;
  final Color? color;
  final bool withText;
  final BrandLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveSize = customSize ?? size?.size ?? BrandLogoSize.medium.size;
    final effectiveColor = color ?? colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? colorScheme.onSurface : AppColors.textPrimary;

    // Use the existing blue logo if full variant is requested
    final assetPath = variant == BrandLogoVariant.full 
        ? 'assets/logo_without_slogan.svg' 
        : 'assets/icon.svg';

    final svg = SvgPicture.asset(
      assetPath,
      width: effectiveSize,
      height: effectiveSize,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );

    if (withText && variant == BrandLogoVariant.icon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Icon(
              Icons.pets,
              size: effectiveSize,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Pet',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    fontSize: effectiveSize * 0.7,
                    letterSpacing: -1.0,
                  ),
                ),
                TextSpan(
                  text: 'Folio',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    color: effectiveColor,
                    fontSize: effectiveSize * 0.7,
                    letterSpacing: -1.0,
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
