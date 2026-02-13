class ArticleModel {
  final int id;
  final String image;
  final String title;
  final String? content;
  final String status;
  final int order;
  final String? category;

  ArticleModel({
    required this.id,
    required this.image,
    required this.title,
    this.content,
    required this.status,
    required this.order,
    this.category,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      content: json['content'],
      status: json['status'],
      order: json['order'],
      category: json['category'],
    );
  }
}
