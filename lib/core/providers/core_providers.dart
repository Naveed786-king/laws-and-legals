import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/bookmark_store.dart';
import '../storage/search_history_store.dart';
import '../../data/repositories/content_repository.dart';

final bookmarkStoreProvider = Provider((ref) => BookmarkStore());
final searchHistoryStoreProvider = Provider((ref) => SearchHistoryStore());

final contentRepositoryProvider = Provider((ref) {
  return ContentRepository();
});
