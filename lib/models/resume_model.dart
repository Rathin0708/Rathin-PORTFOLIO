class ResumeModel {
  final PersonalInfo personalInfo;
  final String summary;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<String> skills;
  final List<Project> projects;
  final List<Certificate> certificates;
  final List<Language> languages;
  final List<String> interests;

  ResumeModel({
    required this.personalInfo,
    required this.summary,
    required this.experiences,
    required this.educations,
    required this.skills,
    required this.projects,
    required this.certificates,
    this.languages = const [],
    this.interests = const [],
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      summary: json['summary'] ?? '',
      experiences: (json['experiences'] as List<dynamic>?)
          ?.map((e) => Experience.fromJson(e))
          .toList() ?? [],
      educations: (json['educations'] as List<dynamic>?)
          ?.map((e) => Education.fromJson(e))
          .toList() ?? [],
      skills: List<String>.from(json['skills'] ?? []),
      projects: (json['projects'] as List<dynamic>?)
          ?.map((e) => Project.fromJson(e))
          .toList() ?? [],
      certificates: (json['certificates'] as List<dynamic>?)
          ?.map((e) => Certificate.fromJson(e))
          .toList() ?? [],
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => Language.fromJson(e))
          .toList() ?? [],
      interests: List<String>.from(json['interests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalInfo': personalInfo.toJson(),
      'summary': summary,
      'experiences': experiences.map((e) => e.toJson()).toList(),
      'educations': educations.map((e) => e.toJson()).toList(),
      'skills': skills,
      'projects': projects.map((e) => e.toJson()).toList(),
      'certificates': certificates.map((e) => e.toJson()).toList(),
      'languages': languages.map((e) => e.toJson()).toList(),
      'interests': interests,
    };
  }
}

class PersonalInfo {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? website;
  final String? linkedin;
  final String? github;
  final String? profileImage;

  PersonalInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.website,
    this.linkedin,
    this.github,
    this.profileImage,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      website: json['website'],
      linkedin: json['linkedin'],
      github: json['github'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'website': website,
      'linkedin': linkedin,
      'github': github,
      'profileImage': profileImage,
    };
  }
}

class Experience {
  final String id;
  final String company;
  final String position;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentRole;
  final String description;
  final List<String> achievements;

  Experience({
    required this.id,
    required this.company,
    required this.position,
    required this.location,
    required this.startDate,
    this.endDate,
    this.isCurrentRole = false,
    required this.description,
    this.achievements = const [],
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] ?? '',
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      location: json['location'] ?? '',
      startDate: DateTime.parse(
          json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCurrentRole: json['isCurrentRole'] ?? false,
      description: json['description'] ?? '',
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrentRole': isCurrentRole,
      'description': description,
      'achievements': achievements,
    };
  }
}

class Education {
  final String id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final String? gpa;
  final List<String> achievements;

  Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.location,
    required this.startDate,
    this.endDate,
    this.gpa,
    this.achievements = const [],
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] ?? '',
      institution: json['institution'] ?? '',
      degree: json['degree'] ?? '',
      fieldOfStudy: json['fieldOfStudy'] ?? '',
      location: json['location'] ?? '',
      startDate: DateTime.parse(
          json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      gpa: json['gpa'],
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution': institution,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'gpa': gpa,
      'achievements': achievements,
    };
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final List<String> technologies;
  final String? githubUrl;
  final String? liveUrl;
  final DateTime? completedDate;
  final List<String> features;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.technologies,
    this.githubUrl,
    this.liveUrl,
    this.completedDate,
    this.features = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      technologies: List<String>.from(json['technologies'] ?? []),
      githubUrl: json['githubUrl'],
      liveUrl: json['liveUrl'],
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'githubUrl': githubUrl,
      'liveUrl': liveUrl,
      'completedDate': completedDate?.toIso8601String(),
      'features': features,
    };
  }
}

class Certificate {
  final String id;
  final String name;
  final String organization;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String? credentialId;
  final String? credentialUrl;

  Certificate({
    required this.id,
    required this.name,
    required this.organization,
    required this.issueDate,
    this.expirationDate,
    this.credentialId,
    this.credentialUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      organization: json['organization'] ?? '',
      issueDate: DateTime.parse(
          json['issueDate'] ?? DateTime.now().toIso8601String()),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      credentialId: json['credentialId'],
      credentialUrl: json['credentialUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'issueDate': issueDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
    };
  }
}

class Language {
  final String name;
  final String proficiency; // Beginner, Intermediate, Advanced, Native

  Language({
    required this.name,
    required this.proficiency,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'] ?? '',
      proficiency: json['proficiency'] ?? 'Intermediate',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'proficiency': proficiency,
    };
  }
}