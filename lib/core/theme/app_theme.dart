import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'dynamic_theme_provider.dart';

/// Builds Material 3 ThemeData for light and dark modes.
/// Typography uses Noto Sans Devanagari fallback so Hindi text renders
/// natively alongside the Latin UI chrome. Accepts optional color overrides
/// from [DynamicThemeColors] (Admin Panel > Theme & Colors) - any field left
/// null falls back to the built-in default palette.
class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color primaryText, Color secondaryText) {
    final base = GoogleFonts.notoSansTextTheme();
    return base.copyWith(
      headlineMedium: GoogleFonts.notoSerif(
          fontSize: 24, fontWeight: FontWeight.w700, color: primaryText),
      headlineSmall: GoogleFonts.notoSerif(
          fontSize: 20, fontWeight: FontWeight.w700, color: primaryText),
      titleLarge: GoogleFonts.notoSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: primaryText),
      titleMedium: GoogleFonts.notoSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: primaryText),
      bodyLarge: GoogleFonts.notoSans(fontSize: 15, color: primaryText),
      bodyMedium: GoogleFonts.notoSans(fontSize: 13, color: secondaryText),
      labelLarge: GoogleFonts.notoSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: primaryText),
    );
  }

  static ThemeData light([DynamicThemeColors? overrides]) {
    final primary = overrides?.primary ?? AppColors.primaryRed;
    final secondary = overrides?.secondary ?? AppColors.accentGold;
    final tertiary = overrides?.tertiary ?? AppColors.accentMaroon;
    final background = overrides?.background ?? AppColors.lightBackground;

    final scheme = ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(
          AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withOpacity(0.06),
        labelStyle: TextStyle(color: primary, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: secondary.withOpacity(0.25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: Colors.black12,
    );
  }

  static ThemeData dark([DynamicThemeColors? overrides]) {
    final primary = overrides?.primary ?? AppColors.primaryRedLight;
    final secondary = overrides?.secondary ?? AppColors.accentGold;
    final tertiary = overrides?.tertiary ?? AppColors.accentMaroon;

    final scheme = ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme:
          _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondary.withOpacity(0.12),
        labelStyle: TextStyle(color: secondary, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: secondary.withOpacity(0.25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: Colors.white12,
    );
  }
}
