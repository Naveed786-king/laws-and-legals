import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/section_header.dart';
import '../application/youtube_service.dart';

/// YouTube section embedded directly on the Home page (not a separate tab),
/// positioned second-to-last among the home sections. Reads channel videos
/// from the Admin Panel's YouTube config in Firestore.
class HomeYoutubeSection extends StatelessWidget {
  const HomeYoutubeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<YoutubeVideoData>>(
      future: YoutubeService.getVideos(),
      builder: (context, snapshot) {
        final videos = snapshot.data ?? [];
        if (videos.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'चैनल'),
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final v = videos[i];
                    return GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse('https://www.youtube.com/watch?v=${v.videoId}');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 220,
                              height: 160,
                              child: CachedNetworkImage(imageUrl: v.thumbnailUrl, fit: BoxFit.cover),
                            ),
                            Container(
                              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
