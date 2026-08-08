import '../../domain/entities/post.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/home_section.dart';
import '../../domain/entities/banner_ad.dart';
import '../../domain/entities/app_page.dart';
import '../../domain/entities/youtube_video.dart';
import '../datasources/firestore_data_source.dart';
import '../../core/storage/content_cache_store.dart';

/// Single source of truth for all content in the app.
///
/// Fallback chain for every read: Firestore (live, written by the Admin
/// Panel) -> Hive cache (last successful live fetch, for offline reading).
/// There is no bundled demo-content fallback - if nothing has been added
/// in the Admin Panel yet, screens show their proper empty state instead
/// (e.g. "No posts in this category yet") rather than sample content.
class ContentRepository {
  ContentRepository()
      : _firestore = FirestoreDataSource(),
        _cache = ContentCacheStore();

  final FirestoreDataSource _firestore;
  final ContentCacheStore _cache;

  Future<List<Category>> getCategories() async {
    final live = await _firestore.getCategories();
    if (live.isNotEmpty) {
      await _cache.save('categories', live.map((c) => {'id': c.id, 'name': c.name}).toList());
      return live;
    }
    final cached = await _cache.read<List>('categories');
    if (cached != null && cached.isNotEmpty) {
      return cached.map((m) => Category(id: m['id'], name: m['name'])).toList();
    }
    return [];
  }

  Future<List<HomeSection>> getHomeSections() async {
    final liveCategories = await _firestore.getCategories();

    if (liveCategories.isNotEmpty) {
      final sectionConfigs = await _firestore.getHomeSectionConfigs();
      final allPosts = await _firestore.getPublishedPosts();
      final sections = <HomeSection>[];
      for (final cfg in sectionConfigs) {
        final categoryId = cfg['categoryId'] as String? ?? '';
        final posts = allPosts.where((p) => p.categoryId == categoryId).toList();
        if (posts.isEmpty) continue;
        sections.add(HomeSection(
          id: cfg['id'] as String,
          title: cfg['title'] as String? ?? '',
          categoryId: categoryId,
          posts: posts,
          bannerPosition: switch (cfg['bannerPosition']) {
            'above' => BannerPosition.above,
            'below' => BannerPosition.below,
            _ => BannerPosition.none,
          },
          order: (cfg['order'] ?? 0) as int,
        ));
      }
      if (sections.isNotEmpty) {
        await _cache.save('posts', allPosts.map((p) => p.toMap()..['id'] = p.id).toList());
        return sections;
      }
    }

    final cachedPosts = await _cache.read<List>('posts');
    if (cachedPosts != null && cachedPosts.isNotEmpty) {
      final posts = cachedPosts.map((m) => Post.fromMap(m)).toList();
      final byCategory = <String, List<Post>>{};
      for (final p in posts) {
        byCategory.putIfAbsent(p.categoryId, () => []).add(p);
      }
      var order = 0;
      return byCategory.entries.map((e) {
        return HomeSection(
          id: 'cached-${e.key}',
          title: e.value.first.categoryName,
          categoryId: e.key,
          posts: e.value,
          bannerPosition: BannerPosition.none,
          order: order++,
        );
      }).toList();
    }

    return [];
  }

  Future<List<Post>> getPostsByCategory(String categoryId) async {
    final live = await _firestore.getPublishedPosts();
    if (live.isNotEmpty) {
      return live.where((p) => p.categoryId == categoryId).toList();
    }
    final cachedPosts = await _cache.read<List>('posts');
    if (cachedPosts != null && cachedPosts.isNotEmpty) {
      return cachedPosts
          .map((m) => Post.fromMap(m))
          .where((p) => p.categoryId == categoryId)
          .toList();
    }
    return [];
  }

  Future<Post?> getPostById(String id) async {
    final live = await _firestore.getPostById(id);
    if (live != null) return live;
    final cachedPosts = await _cache.read<List>('posts');
    if (cachedPosts != null) {
      for (final m in cachedPosts) {
        final p = Post.fromMap(m);
        if (p.id == id) return p;
      }
    }
    return null;
  }

  Future<List<Post>> getRelatedPosts(Post post, {int limit = 4}) async {
    final all = await getPostsByCategory(post.categoryId);
    return all.where((p) => p.id != post.id).take(limit).toList();
  }

  Future<List<Post>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    final live = await _firestore.getPublishedPosts();
    return live
        .where((p) => p.title.toLowerCase().contains(q) || p.excerpt.toLowerCase().contains(q))
        .toList();
  }

  Future<List<BannerAd>> getBanners(String position) async {
    return _firestore.getBanners(position);
  }

  Future<List<AppPage>> getPages() async {
    return _firestore.getPages();
  }

  Future<AppPage?> getPageBySlug(String slug) async {
    return _firestore.getPageBySlug(slug);
  }

  Future<List<YoutubeVideo>> getYoutubeVideos() async {
    return [];
  }
}
