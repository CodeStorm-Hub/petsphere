import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class PetfolioShadows extends ThemeExtension<PetfolioShadows> {
  final List<BoxShadow> card;
  final List<BoxShadow> button;
  final List<BoxShadow> hoverLift;

  const PetfolioShadows({
    required this.card,
    required this.button,
    required this.hoverLift,
  });

  @override
  PetfolioShadows copyWith({
    List<BoxShadow>? card,
    List<BoxShadow>? button,
    List<BoxShadow>? hoverLift,
  }) {
    return PetfolioShadows(
      card: card ?? this.card,
      button: button ?? this.button,
      hoverLift: hoverLift ?? this.hoverLift,
    );
  }

  @override
  PetfolioShadows lerp(ThemeExtension<PetfolioShadows>? other, double t) {
    if (other is! PetfolioShadows) return this;
    return PetfolioShadows(
      card: BoxShadow.lerpList(card, other.card, t) ?? card,
      button: BoxShadow.lerpList(button, other.button, t) ?? button,
      hoverLift: BoxShadow.lerpList(hoverLift, other.hoverLift, t) ?? hoverLift,
    );
  }
}

class AppTheme {
  const AppTheme._();

  // Instagram blue as primary for the modern social feel
  static const primary = Color(0xFF0095F6);
  static const primaryLight = Color(0xFF47B4FF);
  static const amber = Color(0xFFFFA726);
  static const deepNavy = Color(0xFF1D1D1F);
  static const midNavy = Color(0xFF737373);
  static const bgLight = Color(0xFFFFFFFF);
  static const bgSoft = Color(0xFFF5F5F5);
  static const glassWhite = Color(0x99FFFFFF);
  static const glassBorder = Color(0x1A000000);
  static const white = Colors.white;

  // Backward-compatible aliases for existing visual helper getters.
  static const primaryAccent = primary;
  static const secondaryAccent = amber;
  static const textPrimary = deepNavy;
  static const textSecondary = midNavy;

  // Instagram-inspired dark palette
  static const darkBackground = Color(0xFF000000);   // Pure black (IG bg)
  static const darkSurface = Color(0xFF121212);       // Cards / sheets
  static const darkSoft = Color(0xFF1C1C1C);          // Elevated containers
  static const darkInput = Color(0xFF262626);         // Input fields
  static const darkBorder = Color(0xFF262626);        // Dividers / borders
  static const darkText = Color(0xFFF5F5F5);          // Primary text
  static const darkMuted = Color(0xFFA8A8A8);         // Secondary / muted text

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  static const cardRadius = 16.0;
  static const pillRadius = 100.0;
  static const inputRadius = 12.0;

  static const cardShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const buttonShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const hoverLiftShadow = [
    BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: white,
      primaryContainer: primary.withValues(alpha: isDark ? 0.18 : 0.10),
      onPrimaryContainer: isDark ? darkText : deepNavy,
      secondary: amber,
      onSecondary: isDark ? deepNavy : white,
      secondaryContainer: amber.withValues(alpha: isDark ? 0.18 : 0.14),
      onSecondaryContainer: isDark ? darkText : deepNavy,
      tertiary: primaryLight,
      onTertiary: white,
      tertiaryContainer: primaryLight.withValues(alpha: isDark ? 0.16 : 0.12),
      onTertiaryContainer: isDark ? darkText : deepNavy,
      error: const Color(0xFFED4956),  // Instagram red
      onError: white,
      errorContainer: const Color(0xFFED4956).withValues(alpha: 0.15),
      onErrorContainer: isDark ? darkText : deepNavy,
      surface: isDark ? darkSurface : white,
      onSurface: isDark ? darkText : deepNavy,
      surfaceContainerLowest: isDark ? darkBackground : white,
      surfaceContainerLow: isDark ? darkSurface : bgLight,
      surfaceContainer: isDark ? darkSoft : glassWhite,
      surfaceContainerHigh: isDark ? darkSoft : bgSoft,
      surfaceContainerHighest: isDark ? darkSoft : bgSoft,
      onSurfaceVariant: isDark ? darkMuted : midNavy,
      outline: isDark ? const Color(0xFF363636) : glassBorder,
      outlineVariant: isDark ? const Color(0xFF262626) : glassBorder,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? bgLight : deepNavy,
      onInverseSurface: isDark ? deepNavy : bgLight,
      inversePrimary: primaryLight,
      surfaceTint: Colors.transparent,
    );

    final display = GoogleFonts.playfairDisplayTextTheme();
    final body = GoogleFonts.dmSansTextTheme();
    final textColor = isDark ? darkText : deepNavy;
    final mutedColor = isDark ? darkMuted : midNavy;
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
      borderRadius: BorderRadius.circular(inputRadius),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? darkBackground : bgLight,
      canvasColor: isDark ? darkBackground : bgLight,
      primaryColor: primary,
      textTheme: textTheme,
      extensions: const [
        PetfolioShadows(
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
            ? darkBackground.withValues(alpha: 0.85)
            : bgLight.withValues(alpha: 0.85),
        foregroundColor: isDark ? darkText : deepNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? darkText : deepNavy),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: scheme.outline, width: 1),
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
        fillColor: isDark ? darkInput : bgSoft,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
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
            ? darkBackground.withValues(alpha: 0.96)
            : bgLight.withValues(alpha: 0.96),
        selectedItemColor: primary,
        unselectedItemColor: isDark ? darkMuted : midNavy,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? darkBackground.withValues(alpha: 0.96)
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
        side: BorderSide(color: scheme.outline, width: 1),
        shape: const StadiumBorder(),
        elevation: 0,
        pressElevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: isDark ? darkSoft : bgSoft,
        circularTrackColor: isDark ? darkSoft : bgSoft,
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
        backgroundColor: isDark ? darkSoft : deepNavy,
        contentTextStyle: textTheme.bodySmall?.copyWith(color: white),
        actionTextColor: primaryLight,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(inputRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? darkSurface : white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? darkSurface : white,
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
