import 'post.dart';

/// A home page section is either a category feed (title, posts, "see all")
/// or a standalone full-width banner - chosen explicitly by the admin when
/// creating the section, not attached as an accessory to a category section.
enum HomeSectionType { category, banner }

class HomeSection {
  final String id;
  final String type;
  final String title;
  final String categoryId;
  final List<Post> posts;
  final int order;
  final int postsLimit;
  final String? bannerId;

  const HomeSection({
    required this.id,
    this.type = 'category',
    required this.title,
    required this.categoryId,
    required this.posts,
    required this.order,
    this.postsLimit = 5,
    this.bannerId,
  });

  bool get isBanner => type == 'banner';
  bool get isYoutube => type == 'youtube';
}
