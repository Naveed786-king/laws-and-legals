import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/banner_widget.dart';
import '../../../core/widgets/html_lite.dart';
import '../../../domain/entities/post.dart';

final postByIdProvider = FutureProvider.family((ref, String id) {
  return ref.watch(contentRepositoryProvider).getPostById(id);
});

final relatedPostsProvider = FutureProvider.family((ref, Post post) {
  return ref.watch(contentRepositoryProvider).getRelatedPosts(post);
});

final isBookmarkedProvider = FutureProvider.family((ref, String postId) {
  return ref.watch(bookmarkStoreProvider).isBookmarked(postId);
});

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postByIdProvider(postId));

    return Scaffold(
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Could not load this article.')),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Article not available offline.'));
          }
          return _PostBody(post: post);
        },
      ),
    );
  }
}

class _PostBody extends ConsumerWidget {
  const _PostBody({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarkedAsync = ref.watch(isBookmarkedProvider(post.id));
    final relatedAsync = ref.watch(relatedPostsProvider(post));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(imageUrl: post.imageUrl, fit: BoxFit.cover),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.share(
                '${post.title}\n\nRead more on the Laws And Legals app: https://github.com/Naveed786-king/laws-and-legals/releases/latest',
              ),
            ),
            bookmarkedAsync.when(
              data: (isBookmarked) => IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () async {
                  await ref.read(bookmarkStoreProvider).toggle(post);
                  ref.invalidate(isBookmarkedProvider(post.id));
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Chip(label: Text(post.categoryName)),
              const SizedBox(height: 12),
              Text(post.title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '${post.author} · ${DateFormat.yMMMd().add_jm().format(post.publishedAt)}',
                style: theme.textTheme.bodyMedium,
              ),
              const Divider(height: 32),
              HtmlLite(html: post.content),
              const SizedBox(height: 24),
              const _PostBannerSlot(position: 'post_bottom'),
              const SizedBox(height: 28),
              relatedAsync.when(
                data: (related) => related.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Related', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          ...related.map((r) => CompactPostCard(
                                post: r,
                                onTap: () => Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => PostDetailScreen(postId: r.id)),
                                ),
                              )),
                        ],
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PostBannerSlot extends ConsumerWidget {
  const _PostBannerSlot({required this.position});
  final String position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(contentRepositoryProvider);
    return FutureBuilder(
      future: repo.getBanners(position),
      builder: (context, snapshot) {
        final banners = snapshot.data ?? [];
        if (banners.isEmpty) return const SizedBox.shrink();
        return AdBannerWidget(banner: banners.first);
      },
    );
  }
}
