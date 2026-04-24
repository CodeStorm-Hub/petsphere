import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exact design tokens from "The Nurtured Atelier" (Amber Whisker) Stitch spec.
class AppTheme {
  // ── Primary: deep terracotta ───────────────────────────────────────
  static const Color primary = Color(0xFF99472C);
  static const Color primaryDim = Color(0xFF8A3B21);
  static const Color primaryContainer = Color(0xFFFFAD93);
  static const Color primaryFixed = Color(0xFFFFAD93);
  static const Color primaryFixedDim = Color(0xFFFF9878);
  static const Color onPrimary = Color(0xFFFFF7F5);
  static const Color onPrimaryContainer = Color(0xFF6C250D);
  static const Color onPrimaryFixed = Color(0xFF4F1200);

  // ── Secondary: amber/gold ──────────────────────────────────────────
  static const Color secondary = Color(0xFF745C00);
  static const Color secondaryContainer = Color(0xFFFFE087);
  static const Color secondaryFixed = Color(0xFFFFE087);
  static const Color secondaryFixedDim = Color(0xFFFAD04B);
  static const Color onSecondary = Color(0xFFFFF8EE);
  static const Color onSecondaryContainer = Color(0xFF644F00);

  // ── Tertiary: sage green ───────────────────────────────────────────
  static const Color tertiary = Color(0xFF506453);
  static const Color tertiaryDim = Color(0xFF445847);
  static const Color tertiaryContainer = Color(0xFFE5FDE6);
  static const Color tertiaryFixed = Color(0xFFE5FDE6);
  static const Color tertiaryFixedDim = Color(0xFFD7EED8);
  static const Color onTertiary = Color(0xFFE8FFE8);
  static const Color onTertiaryContainer = Color(0xFF4E6251);
  static const Color onTertiaryFixed = Color(0xFF3C503F);
  static const Color onTertiaryFixedVariant = Color(0xFF586D5B);

  // ── Surface hierarchy ──────────────────────────────────────────────
  static const Color background = Color(0xFFFEF8F3);
  static const Color surface = Color(0xFFFEF8F3);
  static const Color surfaceBright = Color(0xFFFEF8F3);
  static const Color surfaceDim = Color(0xFFE0D9D1);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF9F3ED);
  static const Color surfaceContainer = Color(0xFFF3EDE6);
  static const Color surfaceContainerHigh = Color(0xFFEEE7E0);
  static const Color surfaceContainerHighest = Color(0xFFE8E1DA);
  static const Color surfaceVariant = Color(0xFFE8E1DA);
  static const Color onBackground = Color(0xFF35322D);
  static const Color onSurface = Color(0xFF35322D);
  static const Color onSurfaceVariant = Color(0xFF625E59);

  // ── Error ──────────────────────────────────────────────────────────
  static const Color error = Color(0xFFAC3434);
  static const Color errorContainer = Color(0xFFF56965);
  static const Color onError = Color(0xFFFFF7F6);

  // ── Outline ────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF7F7A74);
  static const Color outlineVariant = Color(0xFFB7B1AA);

  // ── Inverse ────────────────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFF0F0E0B);
  static const Color inverseOnSurface = Color(0xFFA09C98);
  static const Color inversePrimary = Color(0xFFFD9574);

  // ── Dark mode ─────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1A1816);
  static const Color darkSurface = Color(0xFF252220);
  static const Color darkTextPrimary = Color(0xFFF5F0EB);
  static const Color darkTextSecondary = Color(0xFFA09B95);

  // ── Gradient helpers ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDim],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient primaryGradientFAB = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ──────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: const Color(0xFF65000B),
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      surfaceTint: primary,
    );
    return _buildTheme(colorScheme, Brightness.light);
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryContainer,
      onPrimary: onPrimaryFixed,
      primaryContainer: primaryDim,
      onPrimaryContainer: primaryFixed,
      secondary: secondaryFixedDim,
      onSecondary: const Color(0xFF3B2F00),
      secondaryContainer: const Color(0xFF584400),
      onSecondaryContainer: secondaryFixed,
      tertiary: tertiaryFixedDim,
      onTertiary: const Color(0xFF1A3320),
      tertiaryContainer: tertiaryDim,
      onTertiaryContainer: tertiaryFixed,
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: darkBackground,
      onSurface: darkTextPrimary,
      onSurfaceVariant: darkTextSecondary,
      outline: const Color(0xFF9F9991),
      outlineVariant: const Color(0xFF524E4A),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFFEDE0D4),
      onInverseSurface: const Color(0xFF1C1917),
      inversePrimary: primary,
      surfaceTint: primaryContainer,
    );
    return _buildTheme(colorScheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? darkBackground : background,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkSurface : background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? darkSurface : surfaceContainerLowest,
        elevation: 0,
        shadowColor: primary.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? darkSurface : surfaceContainerLowest,
        indicatorColor: primary.withAlpha(36),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: outlineVariant.withAlpha(80)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF302D2A) : surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary.withAlpha(51), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: error.withAlpha(128), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(150)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
        backgroundColor: isDark ? const Color(0xFF2A3A2B) : tertiaryContainer,
        selectedColor: isDark ? primary.withAlpha(60) : tertiary,
        labelStyle: GoogleFonts.plusJakartaSans(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outlineVariant.withAlpha(48),
        thickness: 0.8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tertiary,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? darkSurface : surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? darkSurface : surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: onSurfaceVariant,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: StadiumBorder(),
      ),
    );
  }
}
