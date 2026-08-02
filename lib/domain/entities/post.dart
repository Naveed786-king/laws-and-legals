class Post {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String imageUrl;
  final String author;
  final DateTime publishedAt;
  final String categoryId;
  final String categoryName;
  final List<String> tags;
  final bool isBookmarked;

  const Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.publishedAt,
    required this.categoryId,
    required this.categoryName,
    this.tags = const [],
    this.isBookmarked = false,
  });

  Post copyWith({bool? isBookmarked}) => Post(
        id: id,
        title: title,
        excerpt: excerpt,
        content: content,
        imageUrl: imageUrl,
        author: author,
        publishedAt: publishedAt,
        categoryId: categoryId,
        categoryName: categoryName,
        tags: tags,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'excerpt': excerpt,
        'content': content,
        'imageUrl': imageUrl,
        'author': author,
        'publishedAt': publishedAt.toIso8601String(),
        'categoryId': categoryId,
        'categoryName': categoryName,
        'tags': tags,
      };

  factory Post.fromMap(Map<dynamic, dynamic> map) => Post(
        id: map['id'] as String,
        title: map['title'] as String,
        excerpt: map['excerpt'] as String,
        content: map['content'] as String,
        imageUrl: map['imageUrl'] as String,
        author: map['author'] as String,
        publishedAt: DateTime.parse(map['publishedAt'] as String),
        categoryId: map['categoryId'] as String,
        categoryName: map['categoryName'] as String,
        tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}
