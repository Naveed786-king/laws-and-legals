import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/post_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/banner_widget.dart';
import '../../../../core/widgets/shimmer_loaders.dart';
import '../../../../domain/entities/home_section.dart';
import '../../application/home_providers.dart';
import '../../../post/presentation/post_detail_screen.dart';
import '../../../categories/presentation/category_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(homeSectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laws And Legals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(homeSectionsProvider),
        child: sectionsAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              HomeSectionShimmer(),
              HomeSectionShimmer(),
            ],
          ),
          error: (e, st) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.wifi_off, size: 48),
              const SizedBox(height: 12),
              const Text('Could not load content. Showing cached data if available.',
                  textAlign: TextAlign.center),
            ],
          ),
          data: (sections) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: sections.length,
            itemBuilder: (context, index) =>
                _SectionBlock(section: sections[index]),
          ),
        ),
      ),
    );
  }
}

class _SectionBlock extends ConsumerWidget {
  const _SectionBlock({required this.section});
  final HomeSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lead = section.posts.first;
    final rest = section.posts.skip(1).take(4).toList();
    final position = section.bannerPosition;

    void openPost(String id) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PostDetailScreen(postId: id)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: section.title,
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CategoryScreen(
                  categoryId: section.categoryId,
                  categoryName: section.title,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (position == BannerPosition.above) ...[
            _SectionBanner(position: 'home_top'),
            const SizedBox(height: 12),
          ],
          FeaturedPostCard(post: lead, onTap: () => openPost(lead.id)),
          const SizedBox(height: 8),
          for (final p in rest) CompactPostCard(post: p, onTap: () => openPost(p.id)),
          if (position == BannerPosition.below) ...[
            const SizedBox(height: 8),
            _SectionBanner(position: 'home_middle'),
          ],
        ],
      ),
    );
  }
}

class _SectionBanner extends ConsumerWidget {
  const _SectionBanner({required this.position});
  final String position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(homeBannersProvider(position));
    return bannersAsync.when(
      data: (banners) =>
          banners.isEmpty ? const SizedBox.shrink() : AdBannerWidget(banner: banners.first),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
