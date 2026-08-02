import 'package:flutter/material.dart';

/// Central color palette. This is the ONLY place brand colors are defined.
/// When Settings > Theme API is connected to WordPress later, these values
/// can be swapped without touching any screen code, because every screen
/// reads colors through [AppTheme] / [ThemeManagerNotifier], never directly.
class AppColors {
  AppColors._();

  // Primary brand colors - deep navy + gold accent, a common register for
  // Indian legal/judiciary journalism. Fully original palette, configurable.
  static const Color primaryNavy = Color(0xFF0B1F3A);
  static const Color primaryNavyLight = Color(0xFF16305A);
  static const Color accentGold = Color(0xFFC79A3B);
  static const Color accentMaroon = Color(0xFF7A1F2B);

  static const Color lightBackground = Color(0xFFF7F7F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0A0E14);
  static const Color darkSurface = Color(0xFF12161F);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFC77B00);
  static const Color error = Color(0xFFB3261E);

  static const Color textPrimaryLight = Color(0xFF1A1C1E);
  static const Color textSecondaryLight = Color(0xFF5C6066);
  static const Color textPrimaryDark = Color(0xFFE3E2E6);
  static const Color textSecondaryDark = Color(0xFFA9ACB2);
}
