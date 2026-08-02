import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/core_providers.dart';

final youtubeVideosProvider = FutureProvider((ref) {
  return ref.watch(contentRepositoryProvider).getYoutubeVideos();
});

/// Demo YouTube module. Thumbnails are tappable and open the video in the
/// YouTube app/browser. Once a real Channel ID / Playlist ID / WordPress
/// API is entered in Settings > Configure Everything, this list becomes
/// the live channel feed with no rebuild required.
class YoutubeScreen extends ConsumerWidget {
  const YoutubeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(youtubeVideosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Channel')),
      body: videosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Could not load videos')),
        data: (videos) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, i) {
            final v = videos[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () async {
                  final uri = Uri.parse('https://www.youtube.com/watch?v=${v.videoId}');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(imageUrl: v.thumbnailUrl, fit: BoxFit.cover),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
