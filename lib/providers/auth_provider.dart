import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication
  void _initializeAuth() {
    AuthService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_user != null) {
      _userData = await AuthService.getUserData(_user!.uid);
      notifyListeners();
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.signInWithGoogle();

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.resetPassword(email);

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await AuthService.signOut();
      _user = null;
      _userData = null;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out');
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
    String? photoURL,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.updateProfile(
        name: name,
        photoURL: photoURL,
      );

      if (result.isSuccess) {
        await _loadUserData();
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.deleteAccount();

      if (result.isSuccess) {
        _user = null;
        _userData = null;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_user != null) {
      await _loadUserData();
    }
  }
}
