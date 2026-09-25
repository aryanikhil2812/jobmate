import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

final FlutterLocalNotificationsPlugin
flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel notificationChannel =
AndroidNotificationChannel(
  'jobmate_high_importance',
  'JobMate Notifications',
  description:
  'Notifications for JobMate applications and updates.',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    'Background notification: '
        '${message.notification?.title}',
  );
}

Future<void> setupLocalNotifications() async {
  const AndroidInitializationSettings
  androidInitializationSettings =
  AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
    notificationChannel,
  );
}

Future<void> showForegroundNotification(
    RemoteMessage message,
    ) async {
  final notification = message.notification;

  if (notification == null) {
    return;
  }

  const AndroidNotificationDetails
  androidNotificationDetails =
  AndroidNotificationDetails(
    'jobmate_high_importance',
    'JobMate Notifications',
    channelDescription:
    'Notifications for JobMate applications and updates.',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(
    android: androidNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id: notification.hashCode,
    title: notification.title ?? 'JobMate',
    body: notification.body ?? '',
    notificationDetails: notificationDetails,
  );
}

Future<void> setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final token = await messaging.getToken();

  debugPrint('FCM TOKEN: $token');

  FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) async {
      debugPrint(
        'Foreground notification: '
            '${message.notification?.title}',
      );

      await showForegroundNotification(message);
    },
  );

  FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) {
      debugPrint(
        'Notification opened: '
            '${message.notification?.title}',
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupLocalNotifications();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await setupFirebaseMessaging();

  runApp(const JobMateApp());
}

class JobMateApp extends StatelessWidget {
  const JobMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JobMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
      home: SplashScreen(),
    );
  }
}