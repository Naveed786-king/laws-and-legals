import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persists the user's theme choice (system / light / dark) so it survives
/// app restarts. Backed by Hive so it works fully offline.
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _load();
  }

  static const _boxName = 'settings_box';
  static const _key = 'theme_mode';

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    final saved = box.get(_key) as String?;
    state = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox(_boxName);
    await box.put(_key, mode.name);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>(
        (ref) => ThemeController());
