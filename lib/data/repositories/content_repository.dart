import '../../domain/entities/post.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/home_section.dart';
import '../../domain/entities/banner_ad.dart';
import '../../domain/entities/app_page.dart';
import '../../domain/entities/youtube_video.dart';
import '../datasources/demo_data_source.dart';
import '../../core/storage/config_store.dart';

/// Single source of truth for all content in the app. Every screen goes
/// through this repository instead of talking to demo data or the network
/// directly - that's what makes the later WordPress connection a one-file
/// change instead of a rebuild.
///
/// Today (Demo Mode) it always returns bundled demo content. Once the user
/// completes Settings > Configure Everything, [ConfigStore.isDemoMode]
/// flips to false and the TODO branches below become live Dio calls against
/// the configured REST API URL - no screen code changes required.
class ContentRepository {
  ContentRepository(this._configStore);
  final ConfigStore _configStore;

  Future<List<HomeSection>> getHomeSections() async {
    final demo = await _configStore.isDemoMode;
    if (demo) return DemoDataSource.homeSections;
    // TODO(live): GET {restApiUrl}/posts grouped by category via Dio.
    return DemoDataSource.homeSections;
  }

  Future<List<Category>> getCategories() async {
    final demo = await _configStore.isDemoMode;
    if (demo) return DemoDataSource.categories;
    // TODO(live): GET {categoryApi}
    return DemoDataSource.categories;
  }

  Future<List<Post>> getPostsByCategory(String categoryId) async {
    final demo = await _configStore.isDemoMode;
    if (demo) {
      return DemoDataSource.allPosts
          .where((p) => p.categoryId == categoryId)
          .toList();
    }
    // TODO(live): GET {postApi}?category={categoryId}
    return DemoDataSource.allPosts
        .where((p) => p.categoryId == categoryId)
        .toList();
  }

  Future<Post?> getPostById(String id) async {
    final all = DemoDataSource.allPosts;
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Post>> getRelatedPosts(Post post, {int limit = 4}) async {
    return DemoDataSource.allPosts
        .where((p) => p.categoryId == post.categoryId && p.id != post.id)
        .take(limit)
        .toList();
  }

  Future<List<Post>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return DemoDataSource.allPosts
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.excerpt.toLowerCase().contains(q))
        .toList();
  }

  Future<List<BannerAd>> getBanners(String position) async {
    return DemoDataSource.banners
        .where((b) => b.position == position && b.isEnabled && b.isVisible)
        .toList();
  }

  Future<List<AppPage>> getPages() async => DemoDataSource.pages;

  Future<AppPage?> getPageBySlug(String slug) async {
    try {
      return DemoDataSource.pages.firstWhere((p) => p.slug == slug);
    } catch (_) {
      return null;
    }
  }

  Future<List<YoutubeVideo>> getYoutubeVideos() async {
    return DemoDataSource.demoVideos;
  }
}
