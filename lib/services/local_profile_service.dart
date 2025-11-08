import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to manage local profile avatars without Firebase Storage
class LocalProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of available profile avatars in assets
  static const List<String> availableAvatars = [
    'assets/images/profiles/profile1.jpg',
    'assets/images/profiles/profile2.jpg',
    'assets/images/profiles/profile3.jpg',
    'assets/images/profiles/profile4.jpg',
    'assets/images/profiles/default_avatar.png',
  ];

  // Default profile image
  static const String defaultAvatar = 'assets/images/profiles/default_avatar.png';

  /// Get current selected profile image from Firestore
  static Future<String> getCurrentProfileImage() async {
    try {
      final doc = await _firestore
          .collection('portfolio_settings')
          .doc('profile')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        String profileImage = data['profileImage'] ?? defaultAvatar;

        // Validate if the avatar exists in our available list
        if (availableAvatars.contains(profileImage)) {
          return profileImage;
        }
      }

      return defaultAvatar;
    } catch (e) {
      print('❌ Error getting current profile image: $e');
      return defaultAvatar;
    }
  }

  /// Update profile image selection in Firestore
  static Future<bool> updateProfileImage(String selectedAvatar) async {
    try {
      // Validate avatar selection
      if (!availableAvatars.contains(selectedAvatar)) {
        throw Exception('Invalid avatar selection: $selectedAvatar');
      }

      await _firestore
          .collection('portfolio_settings')
          .doc('profile')
          .set({
        'profileImage': selectedAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': 'admin',
        'source': 'local_assets',
      }, SetOptions(merge: true));

      print('✅ Profile image updated to: $selectedAvatar');
      return true;
    } catch (e) {
      print('❌ Error updating profile image: $e');
      return false;
    }
  }

  /// Get all available avatars for selection
  static List<String> getAvailableAvatars() {
    return List.from(availableAvatars);
  }

  /// Get avatar display name for UI
  static String getAvatarDisplayName(String avatarPath) {
    switch (avatarPath) {
      case 'assets/images/profiles/profile1.jpg':
        return 'Professional';
      case 'assets/images/profiles/profile2.jpg':
        return 'Casual';
      case 'assets/images/profiles/profile3.jpg':
        return 'Modern';
      case 'assets/images/profiles/profile4.jpg':
        return 'Creative';
      case 'assets/images/profiles/default_avatar.png':
        return 'Default';
      default:
        return 'Custom';
    }
  }

  /// Reset to default avatar
  static Future<bool> resetToDefault() async {
    return await updateProfileImage(defaultAvatar);
  }
}