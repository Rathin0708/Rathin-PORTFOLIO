import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔐 Starting email signup for: $email');
      
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);
        
        // Save user data to Firestore
        await _saveUserToFirestore(credential.user!, name);
        
        print('✅ Email signup successful');
        return AuthResult.success(credential.user!);
      } else {
        return AuthResult.failure('Failed to create user');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Email signup error: ${e.message}');
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      print('❌ Unexpected signup error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // Sign in with email and password
  static Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Starting email signin for: $email');
      
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('✅ Email signin successful');
        return AuthResult.success(credential.user!);
      } else {
        return AuthResult.failure('Failed to sign in');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Email signin error: ${e.message}');
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      print('❌ Unexpected signin error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // Sign in with Google
  static Future<AuthResult> signInWithGoogle() async {
    try {
      print('🔐 Starting Google signin');
      
      if (kIsWeb) {
        // Web Google Sign-In
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        final UserCredential credential = await _auth.signInWithPopup(googleProvider);
        
        if (credential.user != null) {
          await _saveUserToFirestore(credential.user!, credential.user!.displayName ?? 'User');
          print('✅ Google signin successful (Web)');
          return AuthResult.success(credential.user!);
        }
      } else {
        // Mobile Google Sign-In
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          return AuthResult.failure('Google sign-in was cancelled');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          await _saveUserToFirestore(userCredential.user!, userCredential.user!.displayName ?? 'User');
          print('✅ Google signin successful (Mobile)');
          return AuthResult.success(userCredential.user!);
        }
      }
      
      return AuthResult.failure('Failed to sign in with Google');
    } catch (e) {
      print('❌ Google signin error: $e');
      return AuthResult.failure('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // Reset password
  static Future<AuthResult> resetPassword(String email) async {
    try {
      print('🔐 Sending password reset email to: $email');
      
      await _auth.sendPasswordResetEmail(email: email);
      
      print('✅ Password reset email sent');
      return AuthResult.success(null, message: 'Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ Password reset error: ${e.message}');
      return AuthResult.failure(_getErrorMessage(e));
    } catch (e) {
      print('❌ Unexpected password reset error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      print('🔐 Signing out user');
      
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  // Save user data to Firestore
  static Future<void> _saveUserToFirestore(User user, String name) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'provider': user.providerData.isNotEmpty ? user.providerData.first.providerId : 'email',
      }, SetOptions(merge: true));
      
      print('✅ User data saved to Firestore');
    } catch (e) {
      print('❌ Error saving user to Firestore: $e');
    }
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  static Future<AuthResult> updateProfile({
    required String name,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      await user.updateDisplayName(name);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await _saveUserToFirestore(user, name);
      
      return AuthResult.success(user, message: 'Profile updated successfully');
    } catch (e) {
      print('❌ Error updating profile: $e');
      return AuthResult.failure('Failed to update profile');
    }
  }

  // Delete account
  static Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('No user signed in');
      }

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete user account
      await user.delete();
      
      return AuthResult.success(null, message: 'Account deleted successfully');
    } catch (e) {
      print('❌ Error deleting account: $e');
      return AuthResult.failure('Failed to delete account');
    }
  }

  // Get error message from FirebaseAuthException
  static String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  final String? message;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}
