import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Complete Material Design 3 Theme Implementation
/// Based on DESIGN_SYSTEM_SPECIFICATION.md
/// Seed Color: #D4845A (Warm Amber)
class AppThemeV2 {
  // ============================================================================
  // DESIGN TOKENS - Core Color Palette
  // ============================================================================

  // Primary (Warm Amber)

  static const Color _primaryColor = Color(0xFFD4845A);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _primaryContainer = Color(0xFFFFDCC4);
  static const Color _onPrimaryContainer = Color(0xFF3E2817);

  // Secondary (Sage Green)
  static const Color _secondaryColor = Color(0xFF4A7C59);
  static const Color _onSecondary = Color(0xFFFFFFFF);
  static const Color _secondaryContainer = Color(0xFFC8EFD5);
  static const Color _onSecondaryContainer = Color(0xFF0A2818);

  // Tertiary (Warm Mauve)
  static const Color _tertiaryColor = Color(0xFF8B5A7D);
  static const Color _onTertiary = Color(0xFFFFFFFF);
  static const Color _tertiaryContainer = Color(0xFFE8D7E8);
  static const Color _onTertiaryContainer = Color(0xFF32223C);

  // Neutral (Grayscale)
  static const Color _backgroundColor = Color(0xFF0F0E0C);
  static const Color _onBackground = Color(0xFFF2EDE4);
  static const Color _surfaceColor = Color(0xFF1A1814);
  static const Color _onSurface = Color(0xFFF2EDE4);
  static const Color _surfaceDim = Color(0xFF0F0E0C);
  static const Color _surfaceBright = Color(0xFF2B2620);
  static const Color _outlineColor = Color(0xFF6B645B);
  static const Color _outlineVariant = Color(0xFF8B8377);
  static const Color _scrimColor = Color(0xFF000000);

  // Error (Alert Red)
  static const Color _errorColor = Color(0xFFB3261E);
  static const Color _onError = Color(0xFFFFFFFF);
  static const Color _errorContainer = Color(0xFFF9DEDC);
  static const Color _onErrorContainer = Color(0xFF410E0B);

  // Additional semantic colors for UI elements
  static const Color _successColor = Color(0xFF2E7D32); // Green for success
  static const Color _warningColor = Color(0xFFF57C00); // Orange for warnings
  static const Color _infoColor = Color(0xFF1976D2);    // Blue for info

  // ============================================================================
  // SPACING TOKENS (8px Base Unit)
  // ============================================================================
  static const double spacingXs = 4.0;   // 0.5x
  static const double spacingSm = 8.0;   // 1x
  static const double spacingMd = 16.0;  // 2x
  static const double spacingLg = 24.0;  // 3x
  static const double spacingXl = 32.0;  // 4x
  static const double spacingXxl = 48.0; // 6x

  // ============================================================================
  // CORNER RADIUS TOKENS
  // ============================================================================
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusRound = 999.0; // Fully rounded/pill shape

  // ============================================================================
  // ELEVATION TOKENS
  // ============================================================================
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0;
  static const double elevationMd = 3.0;
  static const double elevationLg = 6.0;
  static const double elevationXl = 8.0;

  // ============================================================================
  // TOUCH TARGET SIZES (Accessibility)
  // ============================================================================
  static const double minimumTouchTarget = 48.0; // Material spec minimum
  static const double preferredTouchTarget = 56.0; // Preferred for mobile

  // ============================================================================
  // BUILD THEME - Dark Mode (Primary)
  // ============================================================================
  static ThemeData buildDarkTheme() {
    // Create ColorScheme with Material Design 3 semantics
    const colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      // Primary
      primary: _primaryColor,
      onPrimary: _onPrimary,
      primaryContainer: _primaryContainer,
      onPrimaryContainer: _onPrimaryContainer,
      // Secondary
      secondary: _secondaryColor,
      onSecondary: _onSecondary,
      secondaryContainer: _secondaryContainer,
      onSecondaryContainer: _onSecondaryContainer,
      // Tertiary
      tertiary: _tertiaryColor,
      onTertiary: _onTertiary,
      tertiaryContainer: _tertiaryContainer,
      onTertiaryContainer: _onTertiaryContainer,
      // Neutral

      surface: _surfaceColor,
      onSurface: _onSurface,
      surfaceDim: _surfaceDim,
      surfaceBright: _surfaceBright,
      outline: _outlineColor,
      outlineVariant: _outlineVariant,
      scrim: _scrimColor,
      // Error
      error: _errorColor,
      onError: _onError,
      errorContainer: _errorContainer,
      onErrorContainer: _onErrorContainer,
    );

    // Typography: Playfair Display for headlines, DM Sans for body
    final displayFont = GoogleFonts.playfairDisplayTextTheme().apply(
      bodyColor: _onBackground,
      displayColor: _onBackground,
    );
    final bodyFont = GoogleFonts.dmSansTextTheme().apply(
      bodyColor: _onBackground,
      displayColor: _onBackground,
    );

    final textTheme = bodyFont.copyWith(
      // Display styles (headline equivalents, using Playfair)
      displayLarge: displayFont.displayLarge?.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      displayMedium: displayFont.displayMedium?.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      displaySmall: displayFont.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      // Headline styles (using Playfair)
      headlineLarge: displayFont.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineMedium: displayFont.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineSmall: displayFont.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      // Title styles (DM Sans Bold)
      titleLarge: bodyFont.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      titleMedium: bodyFont.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
      ),
      titleSmall: bodyFont.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      // Body styles (DM Sans Regular)
      bodyLarge: bodyFont.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      bodyMedium: bodyFont.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: bodyFont.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      // Label styles (DM Sans Medium)
      labelLarge: bodyFont.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: bodyFont.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: bodyFont.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundColor,
      textTheme: textTheme,

      // ========================================================================
      // APP BAR THEME
      // ========================================================================
      appBarTheme: AppBarThemeData(
        backgroundColor: _backgroundColor,
        foregroundColor: _onBackground,
        elevation: elevationNone,
        scrolledUnderElevation: elevationSm,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _onBackground, size: 24),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: _onBackground,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),

      // ========================================================================
      // BUTTON THEMES
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimary,
          disabledBackgroundColor: _outlineColor.withValues(alpha: 0.12),
          disabledForegroundColor: _outlineColor.withValues(alpha: 0.38),
          elevation: elevationNone,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          minimumSize: const Size(64, minimumTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          minimumSize: const Size(64, minimumTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _outlineColor, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          minimumSize: const Size(64, minimumTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          minimumSize: const Size(64, minimumTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      // ========================================================================
      // INPUT DECORATION THEME
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _outlineColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _outlineColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(
            color: _outlineColor.withValues(alpha: 0.38),
            width: 1,
          ),
        ),
        labelStyle: const TextStyle(color: _onBackground),
        hintStyle: const TextStyle(color: _outlineVariant),
        errorStyle: const TextStyle(color: _errorColor),
        prefixIconColor: _outlineVariant,
        suffixIconColor: _outlineVariant,
        floatingLabelStyle: const TextStyle(color: _primaryColor),
      ),

      // ========================================================================
      // CARD THEME
      // ========================================================================
      cardTheme: CardThemeData(
        color: _surfaceColor,
        shadowColor: _scrimColor,
        elevation: elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: const BorderSide(color: _outlineColor, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // ========================================================================
      // CHIP THEME
      // ========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceColor,
        disabledColor: _surfaceColor.withValues(alpha: 0.38),
        selectedColor: _primaryColor.withValues(alpha: 0.2),
        secondarySelectedColor: _secondaryColor.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        labelStyle: GoogleFonts.dmSans(
          color: _onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.dmSans(
          color: _primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        brightness: Brightness.dark,
        elevation: elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
          side: const BorderSide(color: _outlineColor, width: 1),
        ),
        side: const BorderSide(color: _outlineColor, width: 1),
      ),

      // ========================================================================
      // DIALOG THEME
      // ========================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceColor,
        elevation: elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        alignment: Alignment.center,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: _onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          color: _onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ========================================================================
      // BOTTOM SHEET THEME
      // ========================================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _surfaceColor,
        elevation: elevationLg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        surfaceTintColor: _primaryColor,
        showDragHandle: true,
        modalElevation: elevationXl,
      ),

      // ========================================================================
      // PROGRESS INDICATOR THEME
      // ========================================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: _outlineColor,
        circularTrackColor: _outlineColor,
      ),

      // ========================================================================
      // DIVIDER THEME
      // ========================================================================
      dividerTheme: const DividerThemeData(
        color: _outlineColor,
        thickness: 1,
        space: spacingMd,
      ),

      // ========================================================================
      // SWITCH THEME
      // ========================================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor;
          }
          return _outlineColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor.withValues(alpha: 0.5);
          }
          return _outlineColor.withValues(alpha: 0.38);
        }),
      ),

      // ========================================================================
      // SNACKBAR THEME
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceColor,
        contentTextStyle: GoogleFonts.dmSans(
          color: _onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: _primaryColor,
        elevation: elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ========================================================================
      // FLOATING ACTION BUTTON THEME
      // ========================================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimary,
        elevation: elevationLg,
        hoverElevation: elevationXl,
        focusElevation: elevationXl,
        highlightElevation: elevationXl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: preferredTouchTarget,
          height: preferredTouchTarget,
        ),
      ),

      // ========================================================================
      // BOTTOM NAVIGATION BAR THEME
      // ========================================================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceColor,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _outlineVariant,
        selectedIconTheme: IconThemeData(color: _primaryColor, size: 24),
        unselectedIconTheme: IconThemeData(color: _outlineVariant, size: 24),
        type: BottomNavigationBarType.fixed,
        elevation: elevationLg,
      ),

      // ========================================================================
      // CHECKBOX & RADIO THEME
      // ========================================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(color: _outlineColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor;
          }
          return Colors.transparent;
        }),
      ),

      // ========================================================================
      // SLIVER APP BAR THEME (inherits from appBarTheme)
      // ========================================================================
      // Uses appBarTheme by default

      // ========================================================================
      // ADDITIONAL PROPERTIES
      // ========================================================================
      primaryColor: _primaryColor,
      secondaryHeaderColor: _secondaryColor,
      canvasColor: _backgroundColor,
      shadowColor: _scrimColor,
      splashColor: _primaryColor.withValues(alpha: 0.12),
      highlightColor: _primaryColor.withValues(alpha: 0.08),
      hoverColor: _primaryColor.withValues(alpha: 0.08),
      focusColor: _primaryColor.withValues(alpha: 0.12),
      disabledColor: _outlineColor.withValues(alpha: 0.38),

    );
  }

  // ============================================================================
  // BUILD THEME - Light Mode
  // ============================================================================

  // Light-mode neutral palette
  static const Color _lightBackground = Color(0xFFFAF7F4);
  static const Color _lightOnBackground = Color(0xFF1A1410);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightOnSurface = Color(0xFF1A1410);
  static const Color _lightSurfaceDim = Color(0xFFEDE9E4);
  static const Color _lightSurfaceBright = Color(0xFFFAF7F4);
  static const Color _lightOutlineColor = Color(0xFFADA69D);
  static const Color _lightOutlineVariant = Color(0xFFCEC8C0);

  static ThemeData buildLightTheme() {
    const colorScheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: _primaryColor,
      onPrimary: _onPrimary,
      primaryContainer: _primaryContainer,
      onPrimaryContainer: _onPrimaryContainer,
      secondary: _secondaryColor,
      onSecondary: _onSecondary,
      secondaryContainer: _secondaryContainer,
      onSecondaryContainer: _onSecondaryContainer,
      tertiary: _tertiaryColor,
      onTertiary: _onTertiary,
      tertiaryContainer: _tertiaryContainer,
      onTertiaryContainer: _onTertiaryContainer,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceDim: _lightSurfaceDim,
      surfaceBright: _lightSurfaceBright,
      outline: _lightOutlineColor,
      outlineVariant: _lightOutlineVariant,
      scrim: _scrimColor,
      error: _errorColor,
      onError: _onError,
      errorContainer: _errorContainer,
      onErrorContainer: _onErrorContainer,
    );

    final displayFont = GoogleFonts.playfairDisplayTextTheme().apply(
      bodyColor: _lightOnBackground,
      displayColor: _lightOnBackground,
    );
    final bodyFont = GoogleFonts.dmSansTextTheme().apply(
      bodyColor: _lightOnBackground,
      displayColor: _lightOnBackground,
    );

    final textTheme = bodyFont.copyWith(
      displayLarge: displayFont.displayLarge?.copyWith(
          fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.25),
      displayMedium: displayFont.displayMedium?.copyWith(
          fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: 0),
      displaySmall: displayFont.displaySmall?.copyWith(
          fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: 0),
      headlineLarge: displayFont.headlineLarge?.copyWith(
          fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: 0),
      headlineMedium: displayFont.headlineMedium?.copyWith(
          fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 0),
      headlineSmall: displayFont.headlineSmall?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 0),
      titleLarge: bodyFont.titleLarge?.copyWith(
          fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.1),
      titleMedium: bodyFont.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.15),
      titleSmall: bodyFont.titleSmall?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1),
      bodyLarge: bodyFont.bodyLarge?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
      bodyMedium: bodyFont.bodyMedium?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall: bodyFont.bodySmall?.copyWith(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelLarge: bodyFont.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelMedium: bodyFont.labelMedium?.copyWith(
          fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: bodyFont.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: _lightBackground,
        foregroundColor: _lightOnBackground,
        elevation: elevationNone,
        scrolledUnderElevation: elevationSm,
        centerTitle: true,
        iconTheme:
            const IconThemeData(color: _lightOnBackground, size: 24),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: _lightOnBackground,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimary,
          elevation: elevationNone,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
              horizontal: spacingLg, vertical: spacingMd),
          minimumSize: const Size(64, minimumTouchTarget),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.dmSans(
              fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimary,
          padding: const EdgeInsets.symmetric(
              horizontal: spacingLg, vertical: spacingMd),
          minimumSize: const Size(64, minimumTouchTarget),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _lightOutlineColor, width: 1),
          padding: const EdgeInsets.symmetric(
              horizontal: spacingLg, vertical: spacingMd),
          minimumSize: const Size(64, minimumTouchTarget),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(
              horizontal: spacingLg, vertical: spacingMd),
          minimumSize: const Size(64, minimumTouchTarget),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceDim,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMd, vertical: spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _lightOutlineColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _lightOutlineColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: _lightOnBackground),
        hintStyle: TextStyle(color: _lightOnBackground.withValues(alpha: 0.5)),
        floatingLabelStyle: const TextStyle(color: _primaryColor),
        prefixIconColor: _lightOutlineColor,
        suffixIconColor: _lightOutlineColor,
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        shadowColor: _scrimColor,
        elevation: elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: const BorderSide(color: _lightOutlineVariant, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurfaceDim,
        selectedColor: _primaryColor.withValues(alpha: 0.15),
        secondarySelectedColor: _secondaryColor.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(
            horizontal: spacingMd, vertical: spacingSm),
        labelStyle: GoogleFonts.dmSans(
            color: _lightOnSurface, fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: GoogleFonts.dmSans(
            color: _primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
        brightness: Brightness.light,
        elevation: elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
          side: const BorderSide(color: _lightOutlineColor, width: 1),
        ),
        side: const BorderSide(color: _lightOutlineColor, width: 1),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        elevation: elevationLg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl)),
        titleTextStyle: GoogleFonts.playfairDisplay(
            color: _lightOnSurface, fontSize: 24, fontWeight: FontWeight.w700),
        contentTextStyle: GoogleFonts.dmSans(
            color: _lightOnSurface, fontSize: 14, fontWeight: FontWeight.w400),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _lightSurface,
        elevation: elevationLg,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        surfaceTintColor: _primaryColor,
        showDragHandle: true,
        modalElevation: elevationXl,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: _lightOutlineColor,
        circularTrackColor: _lightOutlineColor,
      ),
      dividerTheme: DividerThemeData(
        color: _lightOutlineVariant,
        thickness: 1,
        space: spacingMd,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return _lightOutlineColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor.withValues(alpha: 0.5);
          }
          return _lightOutlineColor.withValues(alpha: 0.38);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightSurface,
        contentTextStyle: GoogleFonts.dmSans(
            color: _lightOnSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        actionTextColor: _primaryColor,
        elevation: elevationLg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd)),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimary,
        elevation: elevationLg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl)),
        sizeConstraints: const BoxConstraints.tightFor(
            width: preferredTouchTarget, height: preferredTouchTarget),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _lightOutlineColor,
        selectedIconTheme:
            const IconThemeData(color: _primaryColor, size: 24),
        unselectedIconTheme:
            IconThemeData(color: _lightOutlineColor, size: 24),
        type: BottomNavigationBarType.fixed,
        elevation: elevationLg,
      ),
      primaryColor: _primaryColor,
      secondaryHeaderColor: _secondaryColor,
      canvasColor: _lightBackground,
      shadowColor: _scrimColor,
      splashColor: _primaryColor.withValues(alpha: 0.12),
      highlightColor: _primaryColor.withValues(alpha: 0.08),
      hoverColor: _primaryColor.withValues(alpha: 0.08),
      focusColor: _primaryColor.withValues(alpha: 0.12),
    );
  }

  // ============================================================================
  // CONVENIENT THEME GETTERS
  // ============================================================================
  static ThemeData get darkTheme => buildDarkTheme();
  static ThemeData get lightTheme => buildLightTheme();

  // ============================================================================
  // COLOR UTILITY METHODS
  // ============================================================================

  /// Get primary color with custom opacity
  static Color getPrimaryColor({double opacity = 1.0}) {
    return _primaryColor.withValues(alpha: opacity);
  }

  /// Get secondary color with custom opacity
  static Color getSecondaryColor({double opacity = 1.0}) {
    return _secondaryColor.withValues(alpha: opacity);
  }

  /// Get success color (for positive feedback)
  static Color get successColor => _successColor;

  /// Get warning color (for warnings)
  static Color get warningColor => _warningColor;

  /// Get info color (for information)
  static Color get infoColor => _infoColor;
}
