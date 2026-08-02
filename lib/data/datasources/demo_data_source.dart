import '../../domain/entities/post.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/home_section.dart';
import '../../domain/entities/banner_ad.dart';
import '../../domain/entities/app_page.dart';
import '../../domain/entities/youtube_video.dart';

/// Bundled offline demo content. This is entirely original placeholder
/// copy written for development/testing - it is NOT scraped or copied from
/// any live website, per project rules. Category names mirror a typical
/// Hindi legal-news information architecture (a factual structural choice,
/// not expressive content) but every headline, author name, and snippet
/// below is invented for demo purposes only.
class DemoDataSource {
  DemoDataSource._();

  static final List<Category> categories = [
    const Category(id: 'top-stories', name: 'टॉप स्टोरीज'),
    const Category(id: 'national', name: 'राष्ट्रीय'),
    const Category(id: 'law', name: 'कानून'),
    const Category(id: 'bar-bench', name: 'बार व बेंच'),
    const Category(id: 'art-justice', name: 'आर्ट एंड जस्टिस'),
    const Category(id: 'legal-service', name: 'लीगल सर्विस'),
    const Category(id: 'legal-education', name: 'लीगल एज्यूकेशन'),
    const Category(id: 'discussion', name: 'परिचर्चा'),
  ];

  static final List<Post> _allPosts = List.generate(28, (i) {
    final cat = categories[i % categories.length];
    return Post(
      id: 'demo-post-$i',
      title: _demoTitles[i % _demoTitles.length],
      excerpt: _demoExcerpts[i % _demoExcerpts.length],
      content: _demoContent,
      imageUrl: 'https://picsum.photos/seed/lawsdemo$i/800/500',
      author: _demoAuthors[i % _demoAuthors.length],
      publishedAt: DateTime.now().subtract(Duration(hours: i * 7)),
      categoryId: cat.id,
      categoryName: cat.name,
      tags: const ['डेमो', 'कानून'],
    );
  });

  static List<Post> get allPosts => _allPosts;

  static List<HomeSection> get homeSections {
    final sections = <HomeSection>[];
    for (var i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final posts = _allPosts.where((p) => p.categoryId == cat.id).toList();
      if (posts.isEmpty) continue;
      sections.add(
        HomeSection(
          id: 'section-${cat.id}',
          title: cat.name,
          categoryId: cat.id,
          posts: posts,
          bannerPosition:
              i.isEven ? BannerPosition.below : BannerPosition.above,
          order: i,
        ),
      );
    }
    return sections;
  }

  static List<BannerAd> get banners => const [
        BannerAd(
          id: 'demo-banner-1',
          imageUrl: 'https://picsum.photos/seed/bannerdemo1/900/250',
          destinationUrl: 'https://example.com',
          position: 'home_top',
          priority: 1,
        ),
        BannerAd(
          id: 'demo-banner-2',
          imageUrl: 'https://picsum.photos/seed/bannerdemo2/900/250',
          destinationUrl: 'https://example.com',
          position: 'home_middle',
          priority: 2,
        ),
      ];

  static List<AppPage> get pages => const [
        AppPage(
          slug: 'about',
          title: 'About Us',
          htmlContent:
              '<p>This is placeholder About page content shown in Demo Mode. '
              'Once connected in Settings, this will be replaced with your '
              'WordPress "About" page content automatically.</p>',
        ),
        AppPage(
          slug: 'contact',
          title: 'Contact Us',
          htmlContent:
              '<p>Placeholder contact information. Configure the Pages API '
              'in Settings to pull this from your live site.</p>',
        ),
        AppPage(
          slug: 'advertise',
          title: 'Advertise With Us',
          htmlContent: '<p>Placeholder advertising information page.</p>',
        ),
        AppPage(
          slug: 'privacy',
          title: 'Privacy Policy',
          htmlContent: '<p>Placeholder privacy policy content.</p>',
        ),
        AppPage(
          slug: 'terms',
          title: 'Terms & Conditions',
          htmlContent: '<p>Placeholder terms and conditions content.</p>',
        ),
      ];

  static List<YoutubeVideo> get demoVideos => const [
        YoutubeVideo(
          id: 'demo-video-1',
          videoId: 'dQw4w9WgXcQ',
          title: 'Demo Video 1 (placeholder - connect YouTube API in Settings)',
          thumbnailUrl: 'https://picsum.photos/seed/ytdemo1/480/270',
        ),
        YoutubeVideo(
          id: 'demo-video-2',
          videoId: 'dQw4w9WgXcQ',
          title: 'Demo Video 2 (placeholder - connect YouTube API in Settings)',
          thumbnailUrl: 'https://picsum.photos/seed/ytdemo2/480/270',
        ),
      ];

  static const _demoTitles = [
    'हाईकोर्ट का बड़ा फैसला: नई गाइडलाइन जारी (डेमो हेडलाइन)',
    'सुप्रीम कोर्ट में सुनवाई पूरी, फैसला सुरक्षित (डेमो हेडलाइन)',
    'बार एसोसिएशन की नई पहल, वकीलों के लिए राहत (डेमो हेडलाइन)',
    'कानूनी शिक्षा में सुधार को लेकर सेमिनार आयोजित (डेमो हेडलाइन)',
    'नई मध्यस्थता नीति पर विशेषज्ञों की राय (डेमो हेडलाइन)',
    'जिला अदालत में तकनीकी सुधार, ई-फाइलिंग सुविधा शुरू (डेमो हेडलाइन)',
  ];

  static const _demoExcerpts = [
    'यह एक डेमो सारांश है जो ऐप के डिज़ाइन का परीक्षण करने के लिए उपयोग किया जा रहा है। असली सामग्री कॉन्फ़िगरेशन के बाद वर्डप्रेस से आएगी।',
    'डेमो मोड में दिखाया गया प्लेसहोल्डर टेक्स्ट, ताकि लेआउट और एनिमेशन का परीक्षण किया जा सके।',
    'यह सामग्री केवल विकास और परीक्षण के उद्देश्य से बनाई गई है।',
  ];

  static const _demoContent =
      '<p>यह एक डेमो लेख है। इसका उद्देश्य केवल यह दिखाना है कि पोस्ट पेज '
      'कैसा दिखेगा - फीचर्ड इमेज, शीर्षक, लेखक, दिनांक, और पूरा लेख। '
      'जब आप Settings > Configure Everything से अपनी वेबसाइट जोड़ेंगे, '
      'तो यह डेमो सामग्री अपने आप असली लेखों से बदल जाएगी।</p>'
      '<p>Placeholder paragraph two, for demonstrating scroll behaviour and '
      'typography in the reader view.</p>';

  static const _demoAuthors = [
    'डेमो लेखक',
    'Demo Reporter',
    'Demo Correspondent',
  ];
}
