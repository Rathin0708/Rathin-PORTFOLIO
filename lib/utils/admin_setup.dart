import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class AdminSetup {
  static const String adminEmail = 'rathin007008@gmail.com';
  static const String adminPassword = 'r@THIN007008';
  
  /// Create admin account if it doesn't exist
  static Future<bool> createAdminAccount() async {
    try {
      print('🔧 Setting up admin account...');

      // Check if admin account already exists
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(adminEmail);

      if (methods.isNotEmpty) {
        print('✅ Admin account already exists');
        // Try to login to verify credentials
        try {
          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );

          if (credential.user != null) {
            print('✅ Admin login verified successfully');
            await FirebaseAuth.instance.signOut(); // Sign out after verification
            return true;
          }
        } catch (e) {
          print('⚠️ Admin account exists but password verification failed: $e');
          print('🔄 You may need to reset the password');
          return true; // Still return true as account exists
        }
        return true;
      }

      // Create admin account
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName('Rathin (Admin)');

        // Save admin data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'email': adminEmail,
          'name': 'Rathin (Admin)',
          'role': 'admin',
          'isAdmin': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
          'provider': 'email',
        });

        // Sign out after creation
        await FirebaseAuth.instance.signOut();

        print('✅ Admin account created successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error creating admin account: $e');
      if (e.toString().contains('email-already-in-use')) {
        print('✅ Admin account already exists (confirmed)');
        return true;
      }
      return false;
    }
  }
  
  /// Test admin login
  static Future<bool> testAdminLogin() async {
    try {
      print('🔐 Testing admin login...');
      
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      
      if (credential.user != null) {
        print('✅ Admin login successful');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Admin login failed: $e');
      return false;
    }
  }
  
  /// Reset admin password
  static Future<bool> resetAdminPassword() async {
    try {
      print('🔄 Resetting admin password...');
      
      await FirebaseAuth.instance.sendPasswordResetEmail(email: adminEmail);
      
      print('✅ Password reset email sent to $adminEmail');
      return true;
    } catch (e) {
      print('❌ Error resetting password: $e');
      return false;
    }
  }
  
  /// Initialize admin setup
  static Future<void> initialize() async {
    try {
      // Wait a bit for Firebase to initialize
      await Future.delayed(const Duration(seconds: 2));
      
      // Try to create admin account
      await createAdminAccount();

      // Perform automatic cleanup of invalid profile images
      print('🧹 Running automatic cleanup of profile images...');
      try {
        await AdminService.forceCleanupProfileImages();
        print('✅ Profile image cleanup completed during initialization');
      } catch (e) {
        print('⚠️ Minor issue during profile image cleanup: $e');
      }
    } catch (e) {
      print('❌ Error initializing admin setup: $e');
    }
  }
}
