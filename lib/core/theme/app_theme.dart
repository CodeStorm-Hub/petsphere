import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class PetFolioShadows extends ThemeExtension<PetFolioShadows> {
  final List<BoxShadow> card;
  final List<BoxShadow> button;
  final List<BoxShadow> hoverLift;

  const PetFolioShadows({
    required this.card,
    required this.button,
    required this.hoverLift,
  });

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

  // Brand color: PetFolio Blue (#4A7DF7)
  static const primary = Color(0xFF4A7DF7);
  static const secondary = Color(0xFF47B4FF); // Sky Blue Accent
  static const bgLight = Color(0xFFFCFAF8); // Off-white/cream
  static const bgDark = Color(0xFF121212); // Deep black

  // Semantic Colors (Restored to PetFolio Blue System)
  static const primaryAccent = Color(0xFF4A7DF7); // Brand Primary
  static const secondaryAccent = Color(
    0xFF47B4FF,
  ); // Light Blue (for active/given statuses)
  static const alertAccent = Color(
    0xFFFF5252,
  ); // Material Red Accent (for overdue/alerts)
  static const textPrimary = Color(0xFF1C1C2E); // Deep Navy/Black from logo
  static const textSecondary = Color(0xFF737373);

  static const white = Colors.white;

  // Layout Constants
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double cardRadius = 24.0;
  static const double inputRadius = 12.0;
  static const double pillRadius = 100.0;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          primary: primary,
          onPrimary: white,
          secondary: secondary,
          onSecondary: white,
          surface: isDark ? const Color(0xFF1A1A1A) : bgLight,
          surfaceContainerLowest: isDark ? bgDark : white,
          surfaceContainerHighest: isDark
              ? const Color(0xFF252525)
              : const Color(0xFFF0F4F8),
        ).copyWith(
          outline: isDark ? const Color(0xFF333333) : const Color(0xFFE1E8F0),
        );

    final display = GoogleFonts.playfairDisplayTextTheme();
    final body = GoogleFonts.dmSansTextTheme();
    final textColor = isDark ? const Color(0xFFF5F5F5) : textPrimary;
    final mutedColor = isDark
        ? const Color(0xFFA8A8A8)
        : const Color(0xFF737373);

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
    final buttonShadow = [
      BoxShadow(
        color: primary.withValues(alpha: 0.2),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
    const hoverLiftShadow = [
      BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8)),
    ];

    final textTheme = body.copyWith(
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
      cardColor: isDark ? const Color(0xFF1E1E1E) : white,
      primaryColor: primary,
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
        foregroundColor: isDark ? textColor : textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? textColor : textPrimary),
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
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF5F5F5),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.inputRadius),
          borderSide: const BorderSide(color: primary, width: 1.5),
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
        floatingLabelStyle: textTheme.bodySmall?.copyWith(color: primary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? bgDark.withValues(alpha: 0.96)
            : bgLight.withValues(alpha: 0.96),
        selectedItemColor: primary,
        unselectedItemColor: isDark ? mutedColor : const Color(0xFF737373),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? bgDark.withValues(alpha: 0.96)
            : bgLight.withValues(alpha: 0.96),
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.10),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: primary.withValues(alpha: 0.12),
        disabledColor: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: primary),
        side: BorderSide(color: scheme.outline),
        shape: const StadiumBorder(),
        elevation: 0,
        pressElevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: isDark
            ? const Color(0xFF1C1C1C)
            : const Color(0xFFF5F5F5),
        circularTrackColor: isDark
            ? const Color(0xFF1C1C1C)
            : const Color(0xFFF5F5F5),
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
            ? const Color(0xFF1C1C1C)
            : const Color(0xFF1D1D1F),
        contentTextStyle: textTheme.bodySmall?.copyWith(color: white),
        actionTextColor: primary,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(inputRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF121212) : white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF121212) : white,
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
