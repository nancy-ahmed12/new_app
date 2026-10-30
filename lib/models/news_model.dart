class NewsModel {
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final String author;
  final String content;

  NewsModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.author,
    required this.content,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      imageUrl: json['urlToImage'] ?? '',
      date: json['publishedAt'] ?? '',
      author: json['author'] ?? 'Unknown Author',
      content: json['content'] ?? 'No Content',
    );
  }
}
