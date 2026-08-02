/// A custom WordPress page (About, Contact, Advertise, Privacy, Terms, ...)
class AppPage {
  final String slug;
  final String title;
  final String htmlContent;

  const AppPage({
    required this.slug,
    required this.title,
    required this.htmlContent,
  });
}
