import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import 'page_detail_screen.dart';

final pagesListProvider = FutureProvider((ref) {
  return ref.watch(contentRepositoryProvider).getPages();
});

class PagesListScreen extends ConsumerWidget {
  const PagesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(pagesListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pages')),
      body: pagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Could not load pages')),
        data: (pages) => ListView.separated(
          itemCount: pages.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final p = pages[i];
            return ListTile(
              title: Text(p.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PageDetailScreen(slug: p.slug)),
              ),
            );
          },
        ),
      ),
    );
  }
}
