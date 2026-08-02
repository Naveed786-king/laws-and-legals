import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class SearchHistoryStore {
  Future<Box> get _box async => Hive.openBox(AppConstants.hiveSearchHistoryBox);

  Future<List<String>> getRecent() async {
    final box = await _box;
    final list = (box.get('recent') as List?)?.cast<String>() ?? [];
    return list;
  }

  Future<void> add(String term) async {
    if (term.trim().isEmpty) return;
    final box = await _box;
    final list = (box.get('recent') as List?)?.cast<String>() ?? [];
    list.remove(term);
    list.insert(0, term);
    if (list.length > 12) list.removeRange(12, list.length);
    await box.put('recent', list);
  }

  Future<void> clear() async {
    final box = await _box;
    await box.put('recent', <String>[]);
  }

  /// Static trending terms shown until a real trending-search endpoint is
  /// configured. Original placeholder terms, not scraped.
  static const List<String> trending = [
    'सुप्रीम कोर्ट',
    'हाईकोर्ट',
    'मध्यस्थता',
    'बार काउंसिल',
    'जमानत',
  ];
}
