import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/contact_model.dart';

class AppConstants {
  // Personal Information
  static const String name = "Rathin";
  static const String fullName = "Rathin";
  static const String tagline = "Flutter Developer | UI/UX Enthusiast";
  static const String email = "rathin007008@gmail.com";
  static const String phone = "+91 7395837797";
  static const String location = "Chennai, Tamil Nadu, India";
  
  // Bio
  static const String bio = 
      "Passionate Flutter developer with expertise in creating beautiful, "
      "cross-platform applications. I specialize in Firebase integration, "
      "state management, and delivering exceptional user experiences across "
      "mobile, web, and desktop platforms.";

  // Resume URL (Firebase Storage or Google Drive)
  static const String resumeUrl = "https://drive.google.com/file/d/your-resume-id/view";

  // Social Media Links
  static final List<SocialLink> socialLinks = [
    SocialLink(
      platform: "GitHub",
      url: "https://github.com/Rathin0708",
      iconData: "github",
    ),
    SocialLink(
      platform: "LinkedIn",
      url: "https://www.linkedin.com/in/rathin007/",
      iconData: "linkedin",
    ),
    SocialLink(
      platform: "Twitter",
      url: "https://twitter.com/",
      iconData: "twitter",
    ),
    SocialLink(
      platform: "Instagram",
      url: "https://www.instagram.com/im__rath/",
      iconData: "instagram",
    ),
  ];

  // Skills
  static const List<String> skills = [
    "Flutter",
    "Dart",
    "Firebase",
    "Provider",
    "REST APIs",
    "Git",
    "UI/UX Design",
    "Responsive Design",
    "State Management",
    "Cloud Firestore",
    "Firebase Auth",
    "Push Notifications",
    "App Store Deployment",
    "Play Store Deployment",
    "Web Development",
  ];

  // Navigation Items
  static const List<String> navItems = [
    "Home",
    "About",
    "Projects",
    "Certificates",
    "Contact",
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Responsive Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Sample Projects Data (Replace with your actual projects)
  static const List<Map<String, dynamic>> sampleProjects = [
    {
      'id': '1',
      'title': 'E-Commerce Flutter App',
      'description': 'A complete e-commerce solution built with Flutter and Firebase, featuring user authentication, product catalog, shopping cart, and payment integration.',
      'imageUrl': 'assets/images/project1.png',
      'technologies': ['Flutter', 'Firebase', 'Provider', 'Stripe API'],
      'githubUrl': 'https://github.com/Rathin0708/delivary_app',
      'liveUrl': '#',
      'isFeatured': true,
      'createdAt': '2024-01-15T00:00:00.000Z',
    },
    {
      'id': '2',
      'title': 'Task Management App',
      'description': 'A productivity app with real-time synchronization, offline support, and beautiful animations. Built with Flutter and Firebase.',
      'imageUrl': 'assets/images/project2.png',
      'technologies': ['Flutter', 'Firebase', 'Bloc', 'Hive'],
      'githubUrl': 'https://github.com/rathin/task-manager',
      'liveUrl': null,
      'isFeatured': true,
      'createdAt': '2024-02-20T00:00:00.000Z',
    },
    {
      'id': '3',
      'title': 'Weather Forecast App',
      'description': 'Beautiful weather app with location-based forecasts, interactive maps, and detailed weather information.',
      'imageUrl': 'assets/images/project3.png',
      'technologies': ['Flutter', 'OpenWeather API', 'Geolocator', 'Provider'],
      'githubUrl': 'https://github.com/rathin/weather-app',
      'liveUrl': 'https://weather-app.web.app',
      'isFeatured': false,
      'createdAt': '2024-03-10T00:00:00.000Z',
    },
  ];

  // Sample Certificates Data (Replace with your actual certificates)
  static const List<Map<String, dynamic>> sampleCertificates = [
    {
      'id': '1',
      'title': 'Flutter Development Certification',
      'organization': 'Google Developers',
      'imageUrl': 'assets/certificates/flutter_cert.png',
      'completionDate': '2024-01-15T00:00:00.000Z',
      'credentialUrl': 'https://developers.google.com/certification',
      'category': 'Professional Certification',
      'description': 'Advanced Flutter development certification covering state management, performance optimization, and platform integration.',
    },
    {
      'id': '2',
      'title': 'Firebase Certified Developer',
      'organization': 'Google Cloud',
      'imageUrl': 'assets/certificates/firebase_cert.png',
      'completionDate': '2024-02-20T00:00:00.000Z',
      'credentialUrl': 'https://cloud.google.com/certification',
      'category': 'Professional Certification',
      'description': 'Comprehensive Firebase certification covering authentication, database, storage, and cloud functions.',
    },
    {
      'id': '3',
      'title': 'UI/UX Design Fundamentals',
      'organization': 'Coursera',
      'imageUrl': 'assets/certificates/ux_cert.png',
      'completionDate': '2023-12-10T00:00:00.000Z',
      'credentialUrl': 'https://coursera.org/verify/certificate',
      'category': 'Course Completion',
      'description': 'Fundamentals of user interface and user experience design principles and best practices.',
    },
  ];

  // Helper method to get social icon
  static IconData getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'github':
        return FontAwesomeIcons.github;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      default:
        return FontAwesomeIcons.link;
    }
  }
}
