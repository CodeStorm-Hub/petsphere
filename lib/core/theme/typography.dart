import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petfolio/core/theme/colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme getTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final inter = GoogleFonts.interTextTheme();

    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;

    return inter.copyWith(
      displayLarge: inter.displayLarge?.copyWith(
        color: textColor,
        fontSize: 56,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.12,
      ),
      displayMedium: inter.displayMedium?.copyWith(
        color: textColor,
        fontSize: 44,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.88,
      ),
      displaySmall: inter.displaySmall?.copyWith(
        color: textColor,
        fontSize: 40,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
      headlineLarge: inter.headlineLarge?.copyWith(
        color: textColor,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.36,
      ),
      headlineMedium: inter.headlineMedium?.copyWith(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.32,
      ),
      headlineSmall: inter.headlineSmall?.copyWith(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.28,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: inter.titleSmall?.copyWith(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        color: mutedColor,
        fontSize: 18,
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        color: mutedColor,
        fontSize: 16,
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        color: mutedColor,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.56,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        color: mutedColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        color: mutedColor,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.1,
      ),
    );
  }
}
