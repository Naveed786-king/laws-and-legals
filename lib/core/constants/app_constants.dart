class AppConstants {
  AppConstants._();

  static const String appName = 'Laws And Legals';
  static const String appTagline = 'Hindi Legal News, Anytime, Anywhere';

  /// Demo mode flag. This is the single switch that governs whether the app
  /// reads from bundled demo data or from the configured WordPress REST API.
  /// It flips to false automatically once "Configure Everything" succeeds.
  static const String demoModeKey = 'demo_mode_enabled';

  static const String hiveBookmarksBox = 'bookmarks_box';
  static const String hiveSettingsBox = 'settings_box';
  static const String hiveConfigBox = 'config_box';
  static const String hiveCacheBox = 'posts_cache_box';
  static const String hiveSearchHistoryBox = 'search_history_box';
}
