import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds Material 3 ThemeData for light and dark modes.
/// Typography uses Noto Sans Devanagari fallback so Hindi text renders
/// natively alongside the Latin UI chrome.
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

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.primaryRed,
      secondary: AppColors.accentGold,
      tertiary: AppColors.accentMaroon,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _textTheme(
          AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryRed,
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
        backgroundColor: AppColors.primaryRed.withOpacity(0.06),
        labelStyle: const TextStyle(color: AppColors.primaryRed, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.accentGold.withOpacity(0.25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: Colors.black12,
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.primaryRedLight,
      secondary: AppColors.accentGold,
      tertiary: AppColors.accentMaroon,
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
        backgroundColor: AppColors.accentGold.withOpacity(0.12),
        labelStyle: const TextStyle(color: AppColors.accentGold, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.accentGold.withOpacity(0.25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: Colors.white12,
    );
  }
}
