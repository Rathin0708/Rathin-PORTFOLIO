import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> technologies;
  final String? liveUrl;
  final String? githubUrl;
  final bool isFeatured;
  final DateTime? createdAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.technologies,
    this.liveUrl,
    this.githubUrl,
    this.isFeatured = false,
    this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;

    // Handle both Timestamp and String types for createdAt
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedCreatedAt = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        try {
          parsedCreatedAt = DateTime.parse(json['createdAt']);
        } catch (e) {
          print('Error parsing createdAt string: $e');
          parsedCreatedAt = null;
        }
      }
    }

    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      technologies: List<String>.from(json['technologies'] ?? []),
      liveUrl: json['liveUrl'],
      githubUrl: json['githubUrl'],
      isFeatured: json['isFeatured'] ?? false,
      createdAt: parsedCreatedAt,
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
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
