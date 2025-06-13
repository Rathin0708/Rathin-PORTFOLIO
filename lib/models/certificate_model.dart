import 'package:cloud_firestore/cloud_firestore.dart';

class CertificateModel {
  final String? id;
  final String title;
  final String organization; // Changed from issuer to organization
  final String description; // Made non-nullable
  final String category; // Added category
  final DateTime completionDate; // Changed from issueDate to completionDate
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? imageUrl;
  final List<String> skills;
  final DateTime createdAt;
  final DateTime updatedAt;

  CertificateModel({
    this.id,
    required this.title,
    required this.organization,
    required this.description,
    required this.category,
    required this.completionDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.imageUrl,
    this.skills = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'],
      title: json['title'] ?? '',
      organization: json['organization'] ?? json['issuer'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Professional Certification',
      completionDate: json['completionDate'] is Timestamp
          ? (json['completionDate'] as Timestamp).toDate()
          : (json['issueDate'] is Timestamp
              ? (json['issueDate'] as Timestamp).toDate()
              : DateTime.parse(json['completionDate'] ?? json['issueDate'] ?? DateTime.now().toIso8601String())),
      expiryDate: json['expiryDate'] != null
          ? (json['expiryDate'] is Timestamp
              ? (json['expiryDate'] as Timestamp).toDate()
              : DateTime.parse(json['expiryDate']))
          : null,
      credentialId: json['credentialId'],
      credentialUrl: json['credentialUrl'],
      imageUrl: json['imageUrl'],
      skills: List<String>.from(json['skills'] ?? []),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory CertificateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CertificateModel(
      id: doc.id,
      title: data['title'] ?? '',
      organization: data['organization'] ?? data['issuer'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Professional Certification',
      completionDate: data['completionDate'] is Timestamp
          ? (data['completionDate'] as Timestamp).toDate()
          : (data['issueDate'] is Timestamp
              ? (data['issueDate'] as Timestamp).toDate()
              : DateTime.now()),
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] is Timestamp
              ? (data['expiryDate'] as Timestamp).toDate()
              : DateTime.parse(data['expiryDate']))
          : null,
      credentialId: data['credentialId'],
      credentialUrl: data['credentialUrl'],
      imageUrl: data['imageUrl'],
      skills: List<String>.from(data['skills'] ?? []),
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
      'title': title,
      'organization': organization,
      'description': description,
      'category': category,
      'completionDate': Timestamp.fromDate(completionDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
      'imageUrl': imageUrl,
      'skills': skills,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CertificateModel copyWith({
    String? id,
    String? title,
    String? organization,
    String? description,
    String? category,
    DateTime? completionDate,
    DateTime? expiryDate,
    String? credentialId,
    String? credentialUrl,
    String? imageUrl,
    List<String>? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      description: description ?? this.description,
      category: category ?? this.category,
      completionDate: completionDate ?? this.completionDate,
      expiryDate: expiryDate ?? this.expiryDate,
      credentialId: credentialId ?? this.credentialId,
      credentialUrl: credentialUrl ?? this.credentialUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isExpiringSoon => expiryDate != null && 
      expiryDate!.isAfter(DateTime.now()) && 
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
}
