class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> technologies;
  final String? liveUrl;
  final String? githubUrl;
  final bool isFeatured;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.technologies,
    this.liveUrl,
    this.githubUrl,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      technologies: List<String>.from(json['technologies'] ?? []),
      liveUrl: json['liveUrl'],
      githubUrl: json['githubUrl'],
      isFeatured: json['isFeatured'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'technologies': technologies,
      'liveUrl': liveUrl,
      'githubUrl': githubUrl,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
