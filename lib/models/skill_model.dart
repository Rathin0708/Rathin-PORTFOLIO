import 'package:cloud_firestore/cloud_firestore.dart';

class SkillModel {
  final String? id;
  final String name;
  final String category;
  final int proficiency; // 1-100
  final String? description;
  final String? icon;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  SkillModel({
    this.id,
    required this.name,
    required this.category,
    required this.proficiency,
    this.description,
    this.icon,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      proficiency: json['proficiency'] ?? 0,
      description: json['description'],
      icon: json['icon'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] is Timestamp 
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory SkillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SkillModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      proficiency: data['proficiency'] ?? 0,
      description: data['description'],
      icon: data['icon'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'proficiency': proficiency,
      'description': description,
      'icon': icon,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SkillModel copyWith({
    String? id,
    String? name,
    String? category,
    int? proficiency,
    String? description,
    String? icon,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      proficiency: proficiency ?? this.proficiency,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Predefined skill categories
  static const List<String> categories = [
    'Programming Languages',
    'Frameworks & Libraries',
    'Mobile Development',
    'Web Development',
    'Database',
    'Cloud & DevOps',
    'Tools & Software',
    'Design',
    'Other',
  ];

  // Predefined icons for skills
  static const Map<String, String> skillIcons = {
    'Flutter': '🦋',
    'Dart': '🎯',
    'React': '⚛️',
    'JavaScript': '🟨',
    'TypeScript': '🔷',
    'Python': '🐍',
    'Java': '☕',
    'Kotlin': '🟣',
    'Swift': '🍎',
    'Firebase': '🔥',
    'Node.js': '🟢',
    'MongoDB': '🍃',
    'PostgreSQL': '🐘',
    'MySQL': '🐬',
    'Docker': '🐳',
    'AWS': '☁️',
    'Git': '📚',
    'Figma': '🎨',
    'Adobe XD': '🎭',
    'VS Code': '💻',
  };

  String get iconEmoji => skillIcons[name] ?? icon ?? '⚡';
}
