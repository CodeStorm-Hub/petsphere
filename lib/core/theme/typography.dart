import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petfolio/core/theme/colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme getTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Unified Inter Typography
    final baseTheme = GoogleFonts.interTextTheme();

    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        color: textColor,
        fontSize: 56,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        color: textColor,
        fontSize: 44,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        color: textColor,
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        color: textColor,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        color: textColor,
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        color: mutedColor,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        color: mutedColor,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        color: mutedColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        color: mutedColor,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.1,
      ),
    );
  }
}
