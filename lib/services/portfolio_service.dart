import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Profile Data
  static Stream<Map<String, dynamic>?> getProfileStream() {
    return _firestore
        .collection('portfolio_settings')
        .doc('profile')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final doc = await _firestore
        .collection('portfolio_settings')
        .doc('profile')
        .get();
    return doc.exists ? doc.data() : null;
  }

  // Get About Data
  static Stream<Map<String, dynamic>?> getAboutStream() {
    return _firestore
        .collection('portfolio_settings')
        .doc('about')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  static Future<Map<String, dynamic>?> getAbout() async {
    final doc = await _firestore
        .collection('portfolio_settings')
        .doc('about')
        .get();
    return doc.exists ? doc.data() : null;
  }

  // Get Projects
  static Stream<List<Map<String, dynamic>>> getProjectsStream() {
    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }

  static Future<List<Map<String, dynamic>>> getProjects() async {
    final snapshot = await _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Get Featured Projects
  static Stream<List<Map<String, dynamic>>> getFeaturedProjectsStream() {
    return _firestore
        .collection('projects')
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }

  // Get Certificates
  static Stream<List<Map<String, dynamic>>> getCertificatesStream() {
    return _firestore
        .collection('certificates')
        .orderBy('completionDate', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }

  static Future<List<Map<String, dynamic>>> getCertificates() async {
    final snapshot = await _firestore
        .collection('certificates')
        .orderBy('completionDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Submit Contact Form
  static Future<bool> submitContact(Map<String, dynamic> contactData) async {
    try {
      await _firestore.collection('contacts').add({
        ...contactData,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      return true;
    } catch (e) {
      print('Error submitting contact: $e');
      return false;
    }
  }

  // Get Skills from About
  static Future<List<String>> getSkills() async {
    final aboutData = await getAbout();
    if (aboutData != null && aboutData['skills'] != null) {
      return List<String>.from(aboutData['skills']);
    }
    return [];
  }

  // Get Skills Stream
  static Stream<List<String>> getSkillsStream() {
    return getAboutStream().map((aboutData) {
      if (aboutData != null && aboutData['skills'] != null) {
        return List<String>.from(aboutData['skills']);
      }
      return <String>[];
    });
  }

  // Update Profile (Admin only)
  static Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      await _firestore
          .collection('portfolio_settings')
          .doc('profile')
          .set(profileData, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Update About (Admin only)
  static Future<bool> updateAbout(Map<String, dynamic> aboutData) async {
    try {
      await _firestore
          .collection('portfolio_settings')
          .doc('about')
          .set(aboutData, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating about: $e');
      return false;
    }
  }

  // Add Project (Admin only)
  static Future<String?> addProject(Map<String, dynamic> projectData) async {
    try {
      final docRef = await _firestore.collection('projects').add({
        ...projectData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding project: $e');
      return null;
    }
  }

  // Update Project (Admin only)
  static Future<bool> updateProject(String projectId,
      Map<String, dynamic> projectData) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .update({
        ...projectData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating project: $e');
      return false;
    }
  }

  // Delete Project (Admin only)
  static Future<bool> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
      return true;
    } catch (e) {
      print('Error deleting project: $e');
      return false;
    }
  }

  // Add Certificate (Admin only)
  static Future<String?> addCertificate(
      Map<String, dynamic> certificateData) async {
    try {
      final docRef = await _firestore.collection('certificates').add({
        ...certificateData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding certificate: $e');
      return null;
    }
  }

  // Update Certificate (Admin only)
  static Future<bool> updateCertificate(String certificateId,
      Map<String, dynamic> certificateData) async {
    try {
      await _firestore
          .collection('certificates')
          .doc(certificateId)
          .update({
        ...certificateData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating certificate: $e');
      return false;
    }
  }

  // Delete Certificate (Admin only)
  static Future<bool> deleteCertificate(String certificateId) async {
    try {
      await _firestore.collection('certificates').doc(certificateId).delete();
      return true;
    } catch (e) {
      print('Error deleting certificate: $e');
      return false;
    }
  }
}