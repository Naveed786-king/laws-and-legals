import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../post/presentation/post_detail_screen.dart';

final postsByCategoryProvider =
    FutureProvider.family((ref, String categoryId) {
  return ref.watch(contentRepositoryProvider).getPostsByCategory(categoryId);
});

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.categoryId, required this.categoryName});
  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsByCategoryProvider(categoryId));
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
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
                itemCount: posts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = posts[index];
                  return CompactPostCard(
                    post: p,
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
