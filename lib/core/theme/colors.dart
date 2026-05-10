import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand color: Amber Whisker (#D4845A)
  static const primary = Color(0xFFD4845A);
  static const secondary = Color(0xFF47B4FF); // Sky Blue Accent
  static const bgLight = Color(0xFFFCFAF8); // Off-white/cream
  static const bgDark = Color(0xFF121212); // Deep black

  // Semantic Colors
  static const primaryAccent = Color(0xFFD4845A); // Brand Primary
  static const secondaryAccent = Color(
    0xFF47B4FF,
  ); // Light Blue (for active/given statuses)
  static const alertAccent = Color(
    0xFFFF5252,
  ); // Material Red Accent (for overdue/alerts)
  static const textPrimary = Color(0xFF1C1C2E); // Deep Navy/Black from logo
  static const textSecondary = Color(0xFF737373);

  static const white = Colors.white;
}
