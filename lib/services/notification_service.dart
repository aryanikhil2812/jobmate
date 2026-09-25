import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>?
  get _notificationCollection {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final collection = _notificationCollection;

    if (collection == null) {
      return;
    }

    await collection.add({
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<NotificationModel>> getNotifications() {
    final collection = _notificationCollection;

    if (collection == null) {
      return Stream.value([]);
    }

    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  Future<void> markAsRead(
      String notificationId,
      ) async {
    final collection = _notificationCollection;

    if (collection == null) {
      return;
    }

    await collection.doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead() async {
    final collection = _notificationCollection;

    if (collection == null) {
      return;
    }

    final snapshot = await collection.get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      if (doc.data()['isRead'] != true) {
        batch.update(doc.reference, {
          'isRead': true,
        });
      }
    }

    await batch.commit();
  }

  Future<void> deleteNotification(
      String notificationId,
      ) async {
    final collection = _notificationCollection;

    if (collection == null) {
      return;
    }

    await collection.doc(notificationId).delete();
  }
}