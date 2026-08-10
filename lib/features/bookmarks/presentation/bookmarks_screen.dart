import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../post/presentation/post_detail_screen.dart';
import '../../menu/presentation/app_drawer.dart';

final bookmarksListProvider = FutureProvider((ref) {
  return ref.watch(bookmarkStoreProvider).getAll();
});

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksListProvider);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        title: const Text('Bookmarks'),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Could not load bookmarks')),
        data: (posts) => posts.isEmpty
            ? const EmptyState(
                icon: Icons.bookmark_border,
                title: 'No bookmarks yet',
                subtitle: 'Articles you bookmark are saved here for offline reading.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = posts[i];
                  return CompactPostCard(
                    post: p,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PostDetailScreen(postId: p.id)),
                      );
                      ref.invalidate(bookmarksListProvider);
                    },
                  );
                },
              ),
      ),
    );
  }
}
