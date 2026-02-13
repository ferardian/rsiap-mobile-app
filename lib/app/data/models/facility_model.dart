class FacilityModel {
  final int id;
  final String icon;
  final String title;
  final String? description;
  final int order;
  final String status;

  FacilityModel({
    required this.id,
    required this.icon,
    required this.title,
    this.description,
    required this.order,
    required this.status,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'],
      icon: json['icon'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      order: json['order'] ?? 0,
      status: json['status'] ?? 'active',
    );
  }
}
