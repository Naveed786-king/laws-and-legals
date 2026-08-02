/// Every configurable WordPress integration point. Each renders as one row
/// in Settings > Configure Everything, showing "Not Configured" until the
/// user supplies a value and it passes validation.
class ConfigKeys {
  ConfigKeys._();

  static const websiteUrl = 'website_url';
  static const restApiUrl = 'rest_api_url';
  static const firebaseConfig = 'firebase_config';
  static const notificationConfig = 'notification_config';
  static const bannerApi = 'banner_api';
  static const splashApi = 'splash_api';
  static const wooCommerceApi = 'woocommerce_api';
  static const youtubeApi = 'youtube_api';
  static const logoApi = 'logo_api';
  static const themeApi = 'theme_api';
  static const pagesApi = 'pages_api';
  static const menuApi = 'menu_api';
  static const categoryApi = 'category_api';
  static const postApi = 'post_api';
  static const imageApi = 'image_api';

  static const List<String> all = [
    websiteUrl,
    restApiUrl,
    firebaseConfig,
    notificationConfig,
    bannerApi,
    splashApi,
    wooCommerceApi,
    youtubeApi,
    logoApi,
    themeApi,
    pagesApi,
    menuApi,
    categoryApi,
    postApi,
    imageApi,
  ];

  static const Map<String, String> labels = {
    websiteUrl: 'Website URL',
    restApiUrl: 'REST API URL',
    firebaseConfig: 'Firebase Config',
    notificationConfig: 'Notification Config',
    bannerApi: 'Banner API',
    splashApi: 'Splash API',
    wooCommerceApi: 'WooCommerce API',
    youtubeApi: 'YouTube API',
    logoApi: 'Logo API',
    themeApi: 'Theme API',
    pagesApi: 'Pages API',
    menuApi: 'Menu API',
    categoryApi: 'Category API',
    postApi: 'Post API',
    imageApi: 'Image API',
  };

  static const Map<String, String> helpText = {
    websiteUrl: 'Your WordPress site\'s public URL, e.g. https://example.com',
    restApiUrl: 'Usually your Website URL + /wp-json/wp/v2',
    firebaseConfig: 'Paste your google-services.json values or Firebase project ID',
    notificationConfig: 'Firebase Cloud Messaging server key for push notifications',
    bannerApi: 'Endpoint returning banner ad positions and images',
    splashApi: 'Endpoint returning splash screen logo, duration and text',
    wooCommerceApi: 'Consumer key/secret for WooCommerce REST API (future membership features)',
    youtubeApi: 'YouTube Channel ID or Playlist ID for the Channel tab',
    logoApi: 'Endpoint or URL returning the current app logo',
    themeApi: 'Endpoint returning brand colors to override the built-in theme',
    pagesApi: 'Usually REST API URL + /pages',
    menuApi: 'Endpoint returning the site\'s navigation menu structure',
    categoryApi: 'Usually REST API URL + /categories',
    postApi: 'Usually REST API URL + /posts',
    imageApi: 'Usually REST API URL + /media',
  };
}
