class BannerAd {
  final String id;
  final String imageUrl;
  final String destinationUrl;
  final String position;
  final int priority;
  final bool isEnabled;
  final bool isVisible;

  const BannerAd({
    required this.id,
    required this.imageUrl,
    required this.destinationUrl,
    required this.position,
    this.priority = 0,
    this.isEnabled = true,
    this.isVisible = true,
  });
}
