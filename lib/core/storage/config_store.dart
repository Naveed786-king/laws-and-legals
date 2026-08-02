import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/config_field.dart';
import '../constants/app_constants.dart';
import '../constants/config_keys.dart';

/// Persists each WordPress integration endpoint/value the user has entered
/// in Settings. Everything defaults to "Not Configured" until saved here.
class ConfigStore {
  Future<Box> get _box async => Hive.openBox(AppConstants.hiveConfigBox);

  Future<Map<String, ConfigField>> getAll() async {
    final box = await _box;
    final result = <String, ConfigField>{};
    for (final key in ConfigKeys.all) {
      final saved = box.get(key) as String?;
      result[key] = ConfigField(
        key: key,
        label: ConfigKeys.labels[key] ?? key,
        helpText: ConfigKeys.helpText[key] ?? '',
        value: saved ?? '',
        status: (saved != null && saved.isNotEmpty)
            ? ConfigStatus.configured
            : ConfigStatus.notConfigured,
      );
    }
    return result;
  }

  Future<void> setValue(String key, String value) async {
    final box = await _box;
    await box.put(key, value);
  }

  Future<bool> get isDemoMode async {
    final box = await Hive.openBox(AppConstants.hiveSettingsBox);
    return (box.get(AppConstants.demoModeKey) as bool?) ?? true;
  }

  Future<void> setDemoMode(bool value) async {
    final box = await Hive.openBox(AppConstants.hiveSettingsBox);
    await box.put(AppConstants.demoModeKey, value);
  }
}
