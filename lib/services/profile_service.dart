import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveProfile({
    required String name,
    required String skills,
    required String education,
    required String linkedin,
    required String github,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({
      'name': name,
      'email': user.email ?? '',
      'skills': skills,
      'education': education,
      'linkedin': linkedin,
      'github': github,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await user.updateDisplayName(name);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }
}