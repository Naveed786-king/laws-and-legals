import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/storage/search_history_store.dart';
import '../../post/presentation/post_detail_screen.dart';

final recentSearchesProvider = FutureProvider((ref) {
  return ref.watch(searchHistoryStoreProvider).getRecent();
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<dynamic>? _results;
  bool _loading = false;

  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }
    setState(() => _loading = true);
    final repo = ref.read(contentRepositoryProvider);
    final results = await repo.search(query);
    await ref.read(searchHistoryStoreProvider).add(query.trim());
    ref.invalidate(recentSearchesProvider);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          decoration: const InputDecoration(
            hintText: 'Search articles...',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: _runSearch,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results == null
              ? _SearchLanding(
                  recentAsync: recentAsync,
                  onTapTerm: (term) {
                    _controller.text = term;
                    _runSearch(term);
                  },
                  onClearHistory: () async {
                    await ref.read(searchHistoryStoreProvider).clear();
                    ref.invalidate(recentSearchesProvider);
                  },
                )
              : _results!.isEmpty
                  ? const EmptyState(icon: Icons.search_off, title: 'No results found')
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _results!.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final post = _results![i];
                        return CompactPostCard(
                          post: post,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _SearchLanding extends StatelessWidget {
  const _SearchLanding({
    required this.recentAsync,
    required this.onTapTerm,
    required this.onClearHistory,
  });
  final AsyncValue<List<String>> recentAsync;
  final void Function(String) onTapTerm;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        recentAsync.when(
          data: (recent) => recent.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium),
                        TextButton(onPressed: onClearHistory, child: const Text('Clear')),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recent
                          .map((t) => ActionChip(label: Text(t), onPressed: () => onTapTerm(t)))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Text('Trending Searches', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SearchHistoryStore.trending
              .map((t) => ActionChip(label: Text(t), onPressed: () => onTapTerm(t)))
              .toList(),
        ),
      ],
    );
  }
}
