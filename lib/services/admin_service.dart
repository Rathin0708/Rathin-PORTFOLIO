import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/skill_model.dart';
import '../models/certificate_model.dart';
import '../models/user_analytics_model.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Admin email
  static const String adminEmail = 'rathin007008@gmail.com';
  
  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if current user is admin
  static bool isAdmin() {
    final user = _auth.currentUser;
    return user?.email?.toLowerCase() == adminEmail.toLowerCase();
  }
  
  // Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      // Check if user is admin first
      if (!isAdmin()) {
        print('❌ Access denied: User is not admin');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('lastSignIn', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('❌ Error getting users: $e');
      return [];
    }
  }
  
  // Get user analytics
  static Future<UserAnalytics> getUserAnalytics() async {
    try {
      // Check if user is admin first
      if (!isAdmin()) {
        print('❌ Access denied: User is not admin');
        return UserAnalytics(
          totalUsers: 0,
          totalContacts: 0,
          emailUsers: 0,
          googleUsers: 0,
          recentUsers: 0,
          recentContacts: 0,
        );
      }

      final usersSnapshot = await _firestore.collection('users').get();
      final contactsSnapshot = await _firestore.collection('contacts').get();
      
      final totalUsers = usersSnapshot.docs.length;
      final totalContacts = contactsSnapshot.docs.length;
      
      // Count users by provider
      int emailUsers = 0;
      int googleUsers = 0;
      
      for (var doc in usersSnapshot.docs) {
        final provider = doc.data()['provider'] as String?;
        if (provider == 'google.com') {
          googleUsers++;
        } else {
          emailUsers++;
        }
      }
      
      // Get recent activity (last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();
      
      final recentContactsSnapshot = await _firestore
          .collection('contacts')
          .where('timestamp', isGreaterThan: weekAgo.toIso8601String())
          .get();
      
      return UserAnalytics(
        totalUsers: totalUsers,
        totalContacts: totalContacts,
        emailUsers: emailUsers,
        googleUsers: googleUsers,
        recentUsers: recentUsersSnapshot.docs.length,
        recentContacts: recentContactsSnapshot.docs.length,
      );
    } catch (e) {
      print('Error getting analytics: $e');
      return UserAnalytics(
        totalUsers: 0,
        totalContacts: 0,
        emailUsers: 0,
        googleUsers: 0,
        recentUsers: 0,
        recentContacts: 0,
      );
    }
  }
  
  // Skills Management
  static Future<List<SkillModel>> getSkills() async {
    try {
      final querySnapshot = await _firestore
          .collection('skills')
          .orderBy('category')
          .orderBy('name')
          .get();
      
      return querySnapshot.docs
          .map((doc) => SkillModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting skills: $e');
      return [];
    }
  }
  
  static Future<bool> addSkill(SkillModel skill) async {
    try {
      await _firestore.collection('skills').add(skill.toJson());
      return true;
    } catch (e) {
      print('Error adding skill: $e');
      return false;
    }
  }
  
  static Future<bool> updateSkill(String skillId, SkillModel skill) async {
    try {
      await _firestore.collection('skills').doc(skillId).update(skill.toJson());
      return true;
    } catch (e) {
      print('Error updating skill: $e');
      return false;
    }
  }
  
  static Future<bool> deleteSkill(String skillId) async {
    try {
      await _firestore.collection('skills').doc(skillId).delete();
      return true;
    } catch (e) {
      print('Error deleting skill: $e');
      return false;
    }
  }
  
  // Certificates Management
  static Future<List<CertificateModel>> getCertificates() async {
    try {
      final querySnapshot = await _firestore
          .collection('certificates')
          .orderBy('issueDate', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CertificateModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting certificates: $e');
      return [];
    }
  }
  
  static Future<bool> addCertificate(CertificateModel certificate) async {
    try {
      await _firestore.collection('certificates').add(certificate.toJson());
      return true;
    } catch (e) {
      print('Error adding certificate: $e');
      return false;
    }
  }
  
  static Future<bool> updateCertificate(String certificateId, CertificateModel certificate) async {
    try {
      await _firestore.collection('certificates').doc(certificateId).update(certificate.toJson());
      return true;
    } catch (e) {
      print('Error updating certificate: $e');
      return false;
    }
  }
  
  static Future<bool> deleteCertificate(String certificateId) async {
    try {
      await _firestore.collection('certificates').doc(certificateId).delete();
      return true;
    } catch (e) {
      print('Error deleting certificate: $e');
      return false;
    }
  }
  
  // Contact Messages Management
  static Future<List<Map<String, dynamic>>> getContactMessages() async {
    try {
      final querySnapshot = await _firestore
          .collection('contacts')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
      
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting contact messages: $e');
      return [];
    }
  }
  
  // Delete user
  static Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
  
  // Update user role
  static Future<bool> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }
  
  // Get app settings
  static Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('app').get();
      return doc.data() ?? {};
    } catch (e) {
      print('Error getting app settings: $e');
      return {};
    }
  }
  
  // Update app settings
  static Future<bool> updateAppSettings(Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('settings').doc('app').set(settings, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating app settings: $e');
      return false;
    }
  }
  
  // Log admin action
  static Future<void> logAdminAction(String action, Map<String, dynamic> details) async {
    try {
      await _firestore.collection('admin_logs').add({
        'action': action,
        'details': details,
        'adminEmail': _auth.currentUser?.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging admin action: $e');
    }
  }
}
