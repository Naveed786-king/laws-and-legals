import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/banner_widget.dart';
import '../../post/presentation/post_detail_screen.dart';
import '../../menu/presentation/app_drawer.dart';

final postsByCategoryProvider =
    FutureProvider.family((ref, String categoryId) {
  return ref.watch(contentRepositoryProvider).getPostsByCategory(categoryId);
});

final categoryBannersProvider = FutureProvider((ref) {
  return ref.watch(contentRepositoryProvider).getBanners('category_bottom');
});

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.categoryId, required this.categoryName});
  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsByCategoryProvider(categoryId));
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        title: Text(categoryName),
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load posts.\n${e.toString()}', textAlign: TextAlign.center),
          ),
        ),
        data: (posts) => posts.isEmpty
            ? const EmptyState(
                icon: Icons.article_outlined,
                title: 'No posts in this category yet',
                subtitle: 'Add a published post in this category from the Admin Panel and it will show up here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length + 1, // +1 for the trailing banner slot
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return Consumer(
                      builder: (context, ref, _) {
                        final bannersAsync = ref.watch(categoryBannersProvider);
                        return bannersAsync.when(
                          data: (banners) => banners.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: AdBannerWidget(banner: banners.first),
                                ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    );
                  }
                  final p = posts[index];
                  return _CategoryPostCard(
                    title: p.title,
                    excerpt: p.excerpt,
                    imageUrl: p.imageUrl,
                    author: p.author,
                    date: p.publishedAt,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PostDetailScreen(postId: p.id)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Professional card layout: image with rounded corners, headline, snippet,
/// and a byline row - matching the reference site's list-item structure.
class _CategoryPostCard extends StatelessWidget {
  const _CategoryPostCard({
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.author,
    required this.date,
    required this.onTap,
  });
  final String title;
  final String excerpt;
  final String imageUrl;
  final String author;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        elevation: 0.5,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 100,
                  height: 88,
                  fit: BoxFit.cover,
                  placeholder: (c, _) => Container(width: 100, height: 88, color: theme.colorScheme.surfaceContainerHighest),
                  errorWidget: (c, _, __) => Container(width: 100, height: 88, color: theme.colorScheme.surfaceContainerHighest),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (excerpt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '$author · ${DateFormat.yMMMd().format(date)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
