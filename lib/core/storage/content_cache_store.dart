import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Caches the last successfully-fetched live (Firestore) content so the app
/// can still show real articles when offline, instead of falling back to
/// demo content every time there's no connection. Stores plain
/// List<Map>/Map data - callers convert to/from their own entity types.
class ContentCacheStore {
  Future<Box> get _box async => Hive.openBox(AppConstants.hiveCacheBox);

  Future<void> save(String key, dynamic value) async {
    final box = await _box;
    await box.put(key, value);
  }

  Future<T?> read<T>(String key) async {
    final box = await _box;
    final value = box.get(key);
    return value as T?;
  }
}
