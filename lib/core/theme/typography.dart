import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petfolio/core/theme/colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme getTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final display = GoogleFonts.playfairDisplayTextTheme();
    final body = GoogleFonts.dmSansTextTheme();

    final textColor = isDark ? const Color(0xFFF5F5F5) : AppColors.textPrimary;
    final mutedColor = isDark
        ? const Color(0xFFA8A8A8)
        : const Color(0xFF737373);

    return body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: textColor,
        fontSize: 56,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.12,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: textColor,
        fontSize: 44,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.88,
      ),
      displaySmall: display.displaySmall?.copyWith(
        color: textColor,
        fontSize: 40,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: textColor,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.36,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.32,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.28,
      ),
      titleLarge: body.titleLarge?.copyWith(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: body.titleSmall?.copyWith(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: mutedColor,
        fontSize: 18,
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: mutedColor,
        fontSize: 16,
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: mutedColor,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: body.labelLarge?.copyWith(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.56,
      ),
      labelMedium: body.labelMedium?.copyWith(
        color: mutedColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: body.labelSmall?.copyWith(
        color: mutedColor,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.1,
      ),
    );
  }
}
