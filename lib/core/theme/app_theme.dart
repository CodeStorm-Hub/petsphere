import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class PetFolioShadows extends ThemeExtension<PetFolioShadows> {

  const PetFolioShadows({
    required this.card,
    required this.button,
    required this.hoverLift,
  });
  final List<BoxShadow> card;
  final List<BoxShadow> button;
  final List<BoxShadow> hoverLift;

  @override
  PetFolioShadows copyWith({
    List<BoxShadow>? card,
    List<BoxShadow>? button,
    List<BoxShadow>? hoverLift,
  }) {
    return PetFolioShadows(
      card: card ?? this.card,
      button: button ?? this.button,
      hoverLift: hoverLift ?? this.hoverLift,
    );
  }

  @override
  PetFolioShadows lerp(ThemeExtension<PetFolioShadows>? other, double t) {
    if (other is! PetFolioShadows) return this;
    return PetFolioShadows(
      card: BoxShadow.lerpList(card, other.card, t) ?? card,
      button: BoxShadow.lerpList(button, other.button, t) ?? button,
      hoverLift: BoxShadow.lerpList(hoverLift, other.hoverLift, t) ?? hoverLift,
    );
  }
}

class AppTheme {
  const AppTheme._();

  // =========================================================================
  // PetFolio Blue Palette — Trust, Reliability, Calm
  // =========================================================================
  static const primary = Color(0xFF2563EB);          // Vibrant Blue
  static const secondary = Color(0xFF14B8A6);         // Teal — health/care
  static const bgLight = Color(0xFFF7FAFF);           // Cool off-white
  static const bgDark = Color(0xFF07111F);            // Deep navy-black

  // Semantic Colors
  static const primaryAccent = Color(0xFF2563EB);     // Brand Primary
  static const secondaryAccent = Color(0xFF14B8A6);   // Teal for care/health
  static const petWarmth = Color(0xFFFFB020);         // Warm accent for pet moments
  static const success = Color(0xFF22C55E);           // Healthy / completed
  static const warning = Color(0xFFF59E0B);           // Attention / due soon
  static const alertAccent = Color(0xFFEF4444);       // Overdue / urgent / delete
  static const textPrimary = Color(0xFF0F172A);       // Slate 900
  static const textSecondary = Color(0xFF64748B);     // Slate 500

  static const white = Colors.white;

  // Light-mode surfaces
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceAltLight = Color(0xFFEEF4FF);
  static const outlineLight = Color(0xFFCBD5E1);      // Slate 300

  // Dark-mode surfaces
  static const surfaceDark = Color(0xFF0F1B2D);
  static const surfaceAltDark = Color(0xFF1A2A42);
  static const outlineDark = Color(0xFF334155);        // Slate 700

  // Dark-mode text
  static const textPrimaryDark = Color(0xFFF1F5F9);   // Slate 100
  static const textSecondaryDark = Color(0xFF94A3B8);  // Slate 400

  // Dark-mode primary
  static const primaryDark = Color(0xFF7AA2FF);        // Lighter blue for dark bg
  static const primaryContainerLight = Color(0xFFDCE8FF);
  static const primaryContainerDark = Color(0xFF1E3A5F);

  // Layout Constants
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double cardRadius = 20.0;
  static const double inputRadius = 12.0;
  static const double pillRadius = 100.0;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final effectivePrimary = isDark ? primaryDark : primary;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          primary: effectivePrimary,
          onPrimary: white,
          secondary: secondary,
          onSecondary: white,
          surface: isDark ? surfaceDark : bgLight,
          surfaceContainerLowest: isDark ? bgDark : white,
          surfaceContainerHighest: isDark
              ? surfaceAltDark
              : surfaceAltLight,
          primaryContainer: isDark ? primaryContainerDark : primaryContainerLight,
        ).copyWith(
          outline: isDark ? outlineDark : outlineLight,
        );

    // Typography: Inter — clean, modern, universal
    final inter = GoogleFonts.interTextTheme();
    final textColor = isDark ? textPrimaryDark : textPrimary;
    final mutedColor = isDark ? textSecondaryDark : textSecondary;

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
        blurRadius: 24,
        offset: const Offset(0, 4),
      ),
    ];
    final buttonShadow = [
      BoxShadow(
        color: (isDark ? primaryDark : primary).withValues(alpha: 0.2),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
    final hoverLiftShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];

    final textTheme = inter.copyWith(
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

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? bgDark : bgLight,
      canvasColor: isDark ? bgDark : bgLight,
      cardColor: isDark ? surfaceDark : white,
      primaryColor: effectivePrimary,
      textTheme: textTheme,
      extensions: [
        PetFolioShadows(
          card: cardShadow,
          button: buttonShadow,
          hoverLift: hoverLiftShadow,
        ),
      ],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: isDark
            ? bgDark.withValues(alpha: 0.85)
            : bgLight.withValues(alpha: 0.85),
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: effectivePrimary,
          side: BorderSide(color: effectivePrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: effectivePrimary,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2A42) : surfaceAltLight,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputRadius),
          borderSide: BorderSide(color: effectivePrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputRadius),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputRadius),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodySmall?.copyWith(
          color: mutedColor.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        labelStyle: textTheme.bodySmall,
        floatingLabelStyle: textTheme.bodySmall?.copyWith(color: effectivePrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? bgDark.withValues(alpha: 0.96)
            : bgLight.withValues(alpha: 0.96),
        selectedItemColor: effectivePrimary,
        unselectedItemColor: mutedColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? bgDark.withValues(alpha: 0.96)
            : bgLight.withValues(alpha: 0.96),
        elevation: 0,
        indicatorColor: effectivePrimary.withValues(alpha: 0.10),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: effectivePrimary.withValues(alpha: 0.12),
        disabledColor: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: effectivePrimary),
        side: BorderSide(color: scheme.outline),
        shape: const StadiumBorder(),
        elevation: 0,
        pressElevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: effectivePrimary,
        linearTrackColor: isDark
            ? const Color(0xFF1A2A42)
            : surfaceAltLight,
        circularTrackColor: isDark
            ? const Color(0xFF1A2A42)
            : surfaceAltLight,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1A2A42)
            : const Color(0xFF0F172A),
        contentTextStyle: textTheme.bodySmall?.copyWith(color: white),
        actionTextColor: isDark ? primaryDark : const Color(0xFF93C5FD),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(inputRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? surfaceDark : white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? surfaceDark : white,
        elevation: 0,
        modalElevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
      ),
    );
  }
}
