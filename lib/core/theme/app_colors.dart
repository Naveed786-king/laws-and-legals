import 'package:flutter/material.dart';

/// Central color palette. This is the ONLY place brand colors are defined -
/// every screen reads colors through [AppTheme], never directly.
class AppColors {
  AppColors._();

  // Brand colors: red primary, black text, white background (as specified).
  static const Color primaryRed = Color(0xFFB80000);
  static const Color primaryRedLight = Color(0xFFD32424);
  static const Color accentGold = Color(0xFFC79A3B);
  static const Color accentMaroon = Color(0xFF7A1F2B);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFC77B00);
  static const Color error = Color(0xFFB80000);

  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF5C6066);
  static const Color textPrimaryDark = Color(0xFFE3E2E6);
  static const Color textSecondaryDark = Color(0xFFA9ACB2);
}
