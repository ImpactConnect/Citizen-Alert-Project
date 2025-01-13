class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime date;
  final String category;
  final bool isImportant;

  const NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.date,
    required this.category,
    this.isImportant = false,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imageUrl: map['image_url'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      isImportant: map['is_important'] ?? false,
    );
  }
}
