import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to manage local profile avatars without Firebase Storage
class LocalProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of available profile avatars in assets (only existing files)
  static const List<String> availableAvatars = [
    'assets/images/profile.jpg',
    'assets/images/me.jpg',
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

        // If the stored image doesn't exist, check if it's one of the old references
        if (profileImage.contains('profile1.jpg') ||
            profileImage.contains('profile2.jpg') ||
            profileImage.contains('profile3.jpg') ||
            profileImage.contains('profile4.jpg')) {
          // Immediately update Firestore with valid alternative
          print(
              '🔧 Found invalid reference: $profileImage - Fixing immediately...');
          await _firestore
              .collection('portfolio_settings')
              .doc('profile')
              .set({
            'profileImage': 'assets/images/profile.jpg',
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': 'auto_cleanup',
            'source': 'local_assets',
            'previousInvalidImage': profileImage,
            // Keep track of what was fixed
          }, SetOptions(merge: true));

          print('✅ Automatically fixed invalid profile image reference');
          return 'assets/images/profile.jpg';
        }

        // For any other invalid references, use default
        if (!availableAvatars.contains(profileImage)) {
          print(
              '🔧 Found unknown invalid reference: $profileImage - Setting to default...');
          await _firestore
              .collection('portfolio_settings')
              .doc('profile')
              .set({
            'profileImage': defaultAvatar,
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': 'auto_cleanup',
            'source': 'local_assets',
            'previousInvalidImage': profileImage,
          }, SetOptions(merge: true));

          print('✅ Set invalid reference to default avatar');
          return defaultAvatar;
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
      case 'assets/images/profile.jpg':
        return 'Professional';
      case 'assets/images/me.jpg':
        return 'Personal';
      case 'assets/images/profiles/default_avatar.png':
        return 'Default Avatar';
      default:
        return 'Custom';
    }
  }

  /// Reset to default avatar
  static Future<bool> resetToDefault() async {
    return await updateProfileImage(defaultAvatar);
  }

  /// Clean up any invalid profile image references in Firestore
  static Future<bool> cleanupInvalidReferences() async {
    try {
      final currentImage = await getCurrentProfileImage();

      // If current image is valid, no cleanup needed
      if (availableAvatars.contains(currentImage)) {
        return true;
      }

      // Set to default if current reference is invalid
      print('🧹 Cleaning up invalid profile image reference: $currentImage');
      return await resetToDefault();
    } catch (e) {
      print('❌ Error during cleanup: $e');
      return false;
    }
  }
}