import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/job_model.dart';
import 'notification_service.dart';

class ApplicationService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final NotificationService _notificationService =
  NotificationService();

  final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  bool _localNotificationsInitialized = false;

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) {
      return;
    }

    const AndroidInitializationSettings
    androidInitializationSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
    );

    const AndroidNotificationChannel channel =
    AndroidNotificationChannel(
      'jobmate_application_updates',
      'JobMate Application Updates',
      description:
      'Notifications about job applications and status updates.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _localNotificationsInitialized = true;
  }

  Future<void> _showLocalNotification({
    required String title,
    required String message,
  }) async {
    await _initializeLocalNotifications();

    const AndroidNotificationDetails
    androidNotificationDetails =
    AndroidNotificationDetails(
      'jobmate_application_updates',
      'JobMate Application Updates',
      channelDescription:
      'Notifications about job applications and status updates.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidNotificationDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(
        2147483647,
      ),
      title: title,
      body: message,
      notificationDetails: notificationDetails,
    );
  }

  // Apply for a job
  Future<void> applyForJob(Job job) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .doc(job.id)
        .set({
      'jobId': job.id,
      'title': job.title,
      'company': job.company,
      'location': job.location,
      'type': job.type,
      'description': job.description,
      'applyUrl': job.applyUrl,
      'status': 'Applied',
      'appliedAt': FieldValue.serverTimestamp(),
    });

    const title = 'Application Submitted';

    final message =
        'Your application for ${job.title} has been added to your tracker.';

    // Save notification in Firestore.
    await _notificationService.createNotification(
      title: title,
      message: message,
      type: 'application',
    );

    // Show notification on the phone.
    await _showLocalNotification(
      title: title,
      message: message,
    );
  }

  // Check whether the user already applied
  Future<bool> isJobApplied(String jobId) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .doc(jobId)
        .get();

    return doc.exists;
  }

  // Update application status
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final applicationReference = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .doc(applicationId);

    // Get current application.
    final applicationSnapshot =
    await applicationReference.get();

    if (!applicationSnapshot.exists) {
      throw Exception('Application not found');
    }

    final applicationData =
    applicationSnapshot.data();

    final oldStatus =
        applicationData?['status']?.toString() ?? '';

    final jobTitle =
        applicationData?['title']?.toString() ??
            'your application';

    // Update application status.
    await applicationReference.update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Don't create duplicate notification
    // if status has not actually changed.
    if (oldStatus == status) {
      return;
    }

    String title;
    String message;
    String type;

    switch (status) {
      case 'Shortlisted':
        title = 'Application Shortlisted';
        message =
        'Your application for $jobTitle has been shortlisted.';
        type = 'shortlisted';
        break;

      case 'Interview':
        title = 'Interview Update';
        message =
        'Your application for $jobTitle has moved to the interview stage.';
        type = 'interview';
        break;

      case 'Selected':
        title = 'Application Selected 🎉';
        message =
        'Congratulations! Your application for $jobTitle has been selected.';
        type = 'selected';
        break;

      case 'Rejected':
        title = 'Application Update';
        message =
        'Your application for $jobTitle has been marked as rejected.';
        type = 'rejected';
        break;

      case 'Applied':
        title = 'Application Status Updated';
        message =
        'Your application for $jobTitle is now marked as applied.';
        type = 'application';
        break;

      default:
        title = 'Application Status Updated';
        message =
        'The status of your application for $jobTitle was updated to $status.';
        type = 'general';
    }

    // Save notification in Firestore.
    await _notificationService.createNotification(
      title: title,
      message: message,
      type: type,
    );

    // Show notification on the phone.
    await _showLocalNotification(
      title: title,
      message: message,
    );
  }

  // Get all applications
  Stream<List<Map<String, dynamic>>> getApplications() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .orderBy(
      'appliedAt',
      descending: true,
    )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }
}