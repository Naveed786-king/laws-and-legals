import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/post_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/storage/search_history_store.dart';
import '../../post/presentation/post_detail_screen.dart';
import '../../menu/presentation/app_drawer.dart';

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

  void _clear() {
    _controller.clear();
    setState(() => _results = null);
  }

  @override
  Widget build(BuildContext context) {
    final recentAsync = ref.watch(recentSearchesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: _controller,
                autofocus: false,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'लेख खोजें... (Search articles)',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close), onPressed: _clear)
                      : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: _runSearch,
              ),
            ),
          ),
          Expanded(
            child: _loading
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
                        ? const EmptyState(
                            icon: Icons.search_off,
                            title: 'No results found',
                            subtitle: 'Try a different keyword or check the spelling.',
                          )
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
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recent
                          .map((t) => ActionChip(
                                avatar: const Icon(Icons.history, size: 16),
                                label: Text(t),
                                onPressed: () => onTapTerm(t),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
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
              .map((t) => ActionChip(
                    avatar: const Icon(Icons.trending_up, size: 16),
                    label: Text(t),
                    onPressed: () => onTapTerm(t),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
