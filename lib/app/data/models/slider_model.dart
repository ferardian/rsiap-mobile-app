class SliderModel {
  final int id;
  final String image;
  final String? title;
  final String? link;
  final String status;
  final int order;

  SliderModel({
    required this.id,
    required this.image,
    this.title,
    this.link,
    required this.status,
    required this.order,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      link: json['link'],
      status: json['status'],
      order: json['order'],
    );
  }
}
