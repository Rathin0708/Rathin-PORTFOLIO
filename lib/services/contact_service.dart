import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';

// Conditional Firebase import
import 'package:cloud_firestore/cloud_firestore.dart' if (dart.library.html) 'package:cloud_firestore/cloud_firestore.dart';

class ContactService {
  static const String _collection = 'contacts';

  static Future<bool> submitContactForm(ContactModel contact) async {
    try {
      if (kIsWeb) {
        // Use Firebase for web
        final firestore = FirebaseFirestore.instance;
        await firestore.collection(_collection).add(contact.toJson());
        return true;
      } else {
        // For mobile platforms, simulate success
        // In a real app, you could:
        // 1. Send email using url_launcher
        // 2. Use HTTP API to send to your backend
        // 3. Store locally and sync later
        print('Contact form submitted on mobile: ${contact.toJson()}');
        await Future.delayed(const Duration(seconds: 1));
        return true;
      }
    } catch (e) {
      print('Error submitting contact form: $e');
      return false;
    }
  }

  static Future<List<ContactModel>> getContacts() async {
    try {
      if (kIsWeb) {
        final firestore = FirebaseFirestore.instance;
        final querySnapshot = await firestore
            .collection(_collection)
            .orderBy('timestamp', descending: true)
            .get();

        return querySnapshot.docs
            .map((doc) => ContactModel.fromJson(doc.data()))
            .toList();
      } else {
        // For mobile platforms, return empty list
        return [];
      }
    } catch (e) {
      print('Error fetching contacts: $e');
      return [];
    }
  }

  static Stream<List<ContactModel>> getContactsStream() {
    if (kIsWeb) {
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ContactModel.fromJson(doc.data()))
              .toList());
    } else {
      // For mobile platforms, return empty stream
      return Stream.value([]);
    }
  }
}
