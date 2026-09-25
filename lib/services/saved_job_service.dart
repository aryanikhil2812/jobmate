import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/job_model.dart';

class SavedJobService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveJob(Job job) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedJobs')
        .doc(job.id)
        .set({
      'jobId': job.id,
      'title': job.title,
      'company': job.company,
      'location': job.location,
      'type': job.type,
      'description': job.description,
      'applyUrl': job.applyUrl,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeSavedJob(String jobId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedJobs')
        .doc(jobId)
        .delete();
  }

  Future<bool> isJobSaved(String jobId) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedJobs')
        .doc(jobId)
        .get();

    return doc.exists;
  }

  Stream<List<Job>> getSavedJobs() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedJobs')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return Job(
          id: data['jobId'] ?? doc.id,
          title: data['title'] ?? '',
          company: data['company'] ?? '',
          location: data['location'] ?? '',
          type: data['type'] ?? '',
          description: data['description'] ?? '',
          applyUrl: data['applyUrl'] ?? '',
        );
      }).toList();
    });
  }
}