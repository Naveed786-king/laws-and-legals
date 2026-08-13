import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/html_lite.dart';

final pageBySlugProvider = FutureProvider.family((ref, String slug) {
  return ref.watch(contentRepositoryProvider).getPageBySlug(slug);
});

class PageDetailScreen extends ConsumerWidget {
  const PageDetailScreen({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(pageBySlugProvider(slug));
    return Scaffold(
      appBar: AppBar(title: Text(pageAsync.value?.title ?? '')),
      body: pageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Could not load page')),
        data: (page) {
          if (page == null) return const Center(child: Text('Page not found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: HtmlLite(html: page.htmlContent),
          );
        },
      ),
    );
  }
}
