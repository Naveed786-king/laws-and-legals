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
  final List<String> categoryIds;
  final List<String> categoryNames;
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
    this.categoryIds = const [],
    this.categoryNames = const [],
    this.tags = const [],
    this.isBookmarked = false,
  });

  /// All categories this post belongs to. Falls back to the single
  /// primary category for posts saved before multi-category support.
  List<String> get allCategoryIds => categoryIds.isNotEmpty ? categoryIds : [categoryId];
  List<String> get allCategoryNames => categoryNames.isNotEmpty ? categoryNames : [categoryName];

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
        categoryIds: categoryIds,
        categoryNames: categoryNames,
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
        'categoryIds': categoryIds,
        'categoryNames': categoryNames,
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
        categoryIds: (map['categoryIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
        categoryNames: (map['categoryNames'] as List?)?.map((e) => e.toString()).toList() ?? [],
        tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}
