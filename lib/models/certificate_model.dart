class CertificateModel {
  final String id;
  final String title;
  final String organization;
  final String imageUrl;
  final DateTime completionDate;
  final String? credentialUrl;
  final String category;
  final String description;

  CertificateModel({
    required this.id,
    required this.title,
    required this.organization,
    required this.imageUrl,
    required this.completionDate,
    this.credentialUrl,
    required this.category,
    required this.description,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      completionDate: DateTime.parse(json['completionDate'] ?? DateTime.now().toIso8601String()),
      credentialUrl: json['credentialUrl'],
      category: json['category'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'imageUrl': imageUrl,
      'completionDate': completionDate.toIso8601String(),
      'credentialUrl': credentialUrl,
      'category': category,
      'description': description,
    };
  }
}
