import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';
import 'package:petfolio/core/theme/app_shadows.dart';
import 'package:petfolio/core/theme/colors.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'package:petfolio/core/theme/typography.dart';

@immutable
class PetFolioShadows extends ThemeExtension<PetFolioShadows> {
  const PetFolioShadows({
    required this.card,
    required this.button,
    required this.hoverLift,
    required this.premium,
  });

  final List<BoxShadow> card;
  final List<BoxShadow> button;
  final List<BoxShadow> hoverLift;
  final List<BoxShadow> premium;

  @override
  PetFolioShadows copyWith({
    List<BoxShadow>? card,
    List<BoxShadow>? button,
    List<BoxShadow>? hoverLift,
    List<BoxShadow>? premium,
  }) {
    return PetFolioShadows(
      card: card ?? this.card,
      button: button ?? this.button,
      hoverLift: hoverLift ?? this.hoverLift,
      premium: premium ?? this.premium,
    );
  }

  @override
  PetFolioShadows lerp(ThemeExtension<PetFolioShadows>? other, double t) {
    if (other is! PetFolioShadows) return this;
    return PetFolioShadows(
      card: BoxShadow.lerpList(card, other.card, t) ?? card,
      button: BoxShadow.lerpList(button, other.button, t) ?? button,
      hoverLift: BoxShadow.lerpList(hoverLift, other.hoverLift, t) ?? hoverLift,
      premium: BoxShadow.lerpList(premium, other.premium, t) ?? premium,
    );
  }
}

class AppTheme {
  const AppTheme._();

  // Semantic Colors (Convenience Getters)
  static const Color primaryAccent = AppColors.primary;
  static const Color secondaryAccent = AppColors.secondary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color alertAccent = AppColors.error;

  // Semantic Radius (Convenience Getters)
  static const double pillRadius = AppBorderRadius.pill;
  static const double inputRadius = AppBorderRadius.input;
  static const double cardRadius = AppBorderRadius.card;

  // Semantic Spacing (Convenience Getters)
  static const double xs = AppSpacing.xs;
  static const double s = AppSpacing.s;
  static const double sm = AppSpacing.sm;
  static const double md = AppSpacing.md;
  static const double lg = AppSpacing.lg;
  static const double xl = AppSpacing.xl;

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
      primary: isDark ? const Color(0xFF7AA2FF) : AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.tertiary,
      surface: isDark ? AppColors.bgDark : AppColors.bgLight,
      error: AppColors.error,
    );

    final textTheme = AppTypography.getTextTheme(brightness);

    final shadows = PetFolioShadows(
      card: AppShadows.md,
      button: AppShadows.sm,
      hoverLift: AppShadows.lg,
      premium: AppShadows.premium,
    );

    const inputBorder = OutlineInputBorder(
      borderRadius: AppBorderRadius.inputRadius,
      borderSide: BorderSide(color: AppColors.outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      textTheme: textTheme,
      extensions: [shadows],

      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),

      cardTheme: CardThemeData(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.cardRadius,
          side: BorderSide(
            color: scheme.outline.withValues(alpha: isDark ? 0.1 : 0.05),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.white,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.inputRadius,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.m,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        selectedItemColor: scheme.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        selectedColor: scheme.primary.withValues(alpha: 0.1),
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
        shape: const StadiumBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? Colors.white : AppColors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.textPrimary : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.circularMd,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        modalElevation: 0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBorderRadius.xxl),
          ),
        ),
      ),
    );
  }
}
