import 'package:cloud_firestore/cloud_firestore.dart';

class YoutubeVideoData {
  final String videoId;
  final String title;
  final String thumbnailUrl;

  const YoutubeVideoData({required this.videoId, required this.title, required this.thumbnailUrl});

  factory YoutubeVideoData.fromMap(Map<String, dynamic> map) => YoutubeVideoData(
        videoId: map['videoId'] ?? '',
        title: map['title'] ?? '',
        thumbnailUrl: map['thumbnailUrl'] ?? '',
      );
}

/// Reads the Admin Panel's YouTube configuration (channel ID + a manually
/// curated list of videos, since a full YouTube Data API integration needs
/// an API key the admin can add later without an app rebuild).
class YoutubeService {
  static Future<List<YoutubeVideoData>> getVideos() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('youtube').doc('config').get();
      if (!doc.exists) return [];
      final videos = (doc.data()?['videos'] as List?) ?? [];
      return videos.map((e) => YoutubeVideoData.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }
}
