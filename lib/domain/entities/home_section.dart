import 'post.dart';

enum BannerPosition { above, below, none }

class HomeSection {
  final String id;
  final String title;
  final String categoryId;
  final List<Post> posts;
  final BannerPosition bannerPosition;
  final int order;
  final int postsLimit;
  final String? bannerId;

  const HomeSection({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.posts,
    this.bannerPosition = BannerPosition.none,
    required this.order,
    this.postsLimit = 5,
    this.bannerId,
  });
}
