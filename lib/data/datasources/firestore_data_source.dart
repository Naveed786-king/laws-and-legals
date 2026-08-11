import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/banner_ad.dart';
import '../../domain/entities/app_page.dart';

/// Reads live content from Firestore, written by the Admin Panel. Every
/// method returns an empty list/null on any failure (offline, not yet
/// configured, permission error) rather than throwing - callers decide
/// what to fall back to (demo content or Hive cache).
class FirestoreDataSource {
  final _db = FirebaseFirestore.instance;

  DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Post _postFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Post(
      id: doc.id,
      title: d['title'] ?? '',
      excerpt: d['excerpt'] ?? '',
      content: d['content'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      author: d['author'] ?? '',
      publishedAt: _toDate(d['publishedAt']),
      categoryId: d['categoryId'] ?? '',
      categoryName: d['categoryName'] ?? '',
      tags: (d['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Future<List<Post>> getPublishedPosts() async {
    try {
      // Single-field orderBy only (no compound where+orderBy) so this never
      // needs a Firestore composite index to be created manually - filter
      // by status client-side instead.
      final snap = await _db
          .collection('posts')
          .orderBy('publishedAt', descending: true)
          .get();
      return snap.docs
          .where((doc) => (doc.data()['status'] as String?) == 'published')
          .map(_postFromDoc)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Post?> getPostById(String id) async {
    try {
      final doc = await _db.collection('posts').doc(id).get();
      if (!doc.exists) return null;
      return _postFromDoc(doc as QueryDocumentSnapshot<Map<String, dynamic>>);
    } catch (_) {
      return null;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final snap = await _db.collection('categories').orderBy('order').get();
      return snap.docs
          .map((d) => Category(id: d.id, name: d.data()['name'] ?? ''))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<BannerAd>> getBanners(String position) async {
    try {
      // Single-field where only, filter isEnabled and sort by priority
      // client-side to avoid needing a composite index.
      final snap = await _db
          .collection('banners')
          .where('position', isEqualTo: position)
          .get();
      final banners = snap.docs.map((d) {
        final data = d.data();
        return BannerAd(
          id: d.id,
          imageUrl: data['imageUrl'] ?? '',
          destinationUrl: data['destinationUrl'] ?? '',
          position: data['position'] ?? '',
          priority: (data['priority'] ?? 0) as int,
          isEnabled: data['isEnabled'] ?? true,
          isVisible: data['isVisible'] ?? true,
        );
      }).toList();
      final filtered = banners.where((b) => b.isEnabled).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
      return filtered;
    } catch (_) {
      return [];
    }
  }

  Future<BannerAd?> getBannerById(String bannerId) async {
    try {
      final doc = await _db.collection('banners').doc(bannerId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      final banner = BannerAd(
        id: doc.id,
        imageUrl: data['imageUrl'] ?? '',
        destinationUrl: data['destinationUrl'] ?? '',
        position: data['position'] ?? '',
        priority: (data['priority'] ?? 0) as int,
        isEnabled: data['isEnabled'] ?? true,
        isVisible: data['isVisible'] ?? true,
      );
      return banner.isEnabled ? banner : null;
    } catch (_) {
      return null;
    }

  Future<List<AppPage>> getPages() async {
    try {
      final snap = await _db.collection('pages').get();
      return snap.docs.map((d) {
        final data = d.data();
        return AppPage(
          slug: d.id,
          title: data['title'] ?? '',
          htmlContent: data['content'] ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<AppPage?> getPageBySlug(String slug) async {
    try {
      final doc = await _db.collection('pages').doc(slug).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return AppPage(slug: slug, title: data['title'] ?? '', htmlContent: data['content'] ?? '');
    } catch (_) {
      return null;
    }
  }

  /// Raw map so the repository can build ordered home sections without this
  /// data source needing to know about HomeSection's construction rules.
  Future<List<Map<String, dynamic>>> getHomeSectionConfigs() async {
    try {
      final snap = await _db.collection('homeSections').orderBy('order').get();
      return snap.docs
          .where((d) => (d.data()['isEnabled'] ?? true) == true)
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
    } catch (_) {
      return [];
    }
  }
}
