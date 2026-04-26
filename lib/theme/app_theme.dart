import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exact design tokens from "The Nurtured Atelier" (Amber Whisker) Stitch spec.
class AppTheme {
  // New PawSync Dark Mode Palette
  static const Color background = Color(0xFF0F0E0C);
  static const Color surface = Color(0xFF1A1814);
  static const Color cardColor = Color(0xFF211F1B);
  static const Color border = Color(0xFF2E2B26);
  static const Color primaryAccent = Color(0xFFD4845A);
  static const Color secondaryAccent = Color(0xFF4A7C59);
  static const Color textPrimary = Color(0xFFF2EDE4);
  static const Color textSecondary = Color(0xFFB8B0A4);

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primaryAccent,
      onPrimary: Colors.white,
      secondary: secondaryAccent,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: Colors.redAccent,
      onError: Colors.white,
    );

    final displayFont = GoogleFonts.playfairDisplayTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );
    final bodyFont = GoogleFonts.dmSansTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    final textTheme = bodyFont.copyWith(
      displayLarge: displayFont.displayLarge,
      displayMedium: displayFont.displayMedium,
      displaySmall: displayFont.displaySmall,
      headlineLarge: displayFont.headlineLarge,
      headlineMedium: displayFont.headlineMedium,
      headlineSmall: displayFont.headlineSmall,
      titleLarge: displayFont.titleLarge,
      titleMedium: bodyFont.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: border),
        ),
        backgroundColor: cardColor,
        selectedColor: primaryAccent.withOpacity(0.2),
        labelStyle: GoogleFonts.dmSans(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
    );
  }

  // Fallback to darkTheme since we're forcing premium dark mode
  static ThemeData get lightTheme => darkTheme;
}
