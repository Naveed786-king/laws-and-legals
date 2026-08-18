import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/widgets/post_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/banner_widget.dart';
import '../../../../core/widgets/shimmer_loaders.dart';
import '../../../../domain/entities/home_section.dart';
import '../../application/home_providers.dart';
import '../../../post/presentation/post_detail_screen.dart';
import '../../../categories/presentation/category_screen.dart';
import '../../../menu/presentation/app_drawer.dart';
import '../../../youtube/presentation/home_youtube_section.dart';

final appLogoUrlProvider = FutureProvider<String?>((ref) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('splash').doc('config').get();
    final url = doc.data()?['logoUrl'] as String?;
    return (url != null && url.isNotEmpty) ? url : null;
  } catch (_) {
    return null;
  }
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(homeSectionsProvider);
    final logoUrlAsync = ref.watch(appLogoUrlProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: logoUrlAsync.when(
          data: (url) => url == null
              ? const Text('Laws And Legals')
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    height: 36,
                    fit: BoxFit.contain,
                    errorWidget: (c, _, __) => const Text('Laws And Legals'),
                  ),
                ),
          loading: () => const Text('Laws And Legals'),
          error: (_, __) => const Text('Laws And Legals'),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
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
          data: (sections) {
            if (sections.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Icon(Icons.article_outlined, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'No content yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add categories, sections, and posts from the Admin Panel and they will appear here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }
            final blocks = <Widget>[
              for (final s in sections) _SectionBlock(section: s),
            ];
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: blocks.length,
              itemBuilder: (context, index) => blocks[index],
            );
          },
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
    if (section.isYoutube) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: HomeYoutubeSection(),
      );
    }
    if (section.isBanner) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: _SectionBanner(bannerId: section.bannerId),
      );
    }

    final lead = section.posts.first;
    final rest = section.posts.skip(1).take(4).toList();

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
          FeaturedPostCard(post: lead, onTap: () => openPost(lead.id)),
          const SizedBox(height: 8),
          for (final p in rest) CompactPostCard(post: p, onTap: () => openPost(p.id)),
        ],
      ),
    );
  }
}

class _SectionBanner extends ConsumerWidget {
  const _SectionBanner({this.bannerId});
  final String? bannerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bannerId == null || bannerId!.isEmpty) return const SizedBox.shrink();
    final bannerAsync = ref.watch(homeBannerByIdProvider(bannerId!));
    return bannerAsync.when(
      data: (banner) => banner == null ? const SizedBox.shrink() : AdBannerWidget(banner: banner),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
