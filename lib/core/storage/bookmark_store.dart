import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/post.dart';
import '../constants/app_constants.dart';

/// Offline bookmark storage. Cloud-sync ready: once a user account exists
/// (Google/Email login), this same store can be mirrored to a backend
/// without changing any calling code, since callers only see [BookmarkStore].
class BookmarkStore {
  Future<Box> get _box async =>
      Hive.openBox(AppConstants.hiveBookmarksBox);

  Future<List<Post>> getAll() async {
    final box = await _box;
    return box.values
        .map((e) => Post.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  Future<bool> isBookmarked(String postId) async {
    final box = await _box;
    return box.containsKey(postId);
  }

  Future<void> toggle(Post post) async {
    final box = await _box;
    if (box.containsKey(post.id)) {
      await box.delete(post.id);
    } else {
      await box.put(post.id, post.toMap());
    }
  }
}
