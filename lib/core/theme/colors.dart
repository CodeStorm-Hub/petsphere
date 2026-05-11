import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand color: PetFolio Blue (#2563EB)
  static const seed = Color(0xFF2563EB);

  // Core palette
  static const primary = seed;
  static const primaryContainer = Color(0xFFDBE1FF);
  static const secondary = Color(0xFF64748B);
  static const tertiary = Color(0xFF0EA5E9);
  static const accent = Color(0xFFF97316);

  // Backgrounds
  static const bgLight = Color(0xFFF8FAFC);
  static const bgDark = Color(0xFF07111F); // Deep slate/blue black

  // Surface
  static const surface = Colors.white;
  static const surfaceDark = Color(0xFF0F1B2D);
  static const surfaceAlt = Color(0xFFF1F5F9);

  // Semantic Colors
  static const success = Color(0xFF22C55E); // Green
  static const warning = Color(0xFFF59E0B); // Amber
  static const error = Color(0xFFEF4444); // Red
  static const info = Color(0xFF3B82F6); // Blue

  // Text
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const textMuted = Color(0xFF94A3B8); // Slate 400

  // Outlines
  static const outline = Color(0xFFCBD5E1); // Slate 200

  static const white = Colors.white;
}
