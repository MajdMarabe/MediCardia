import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_application_3/screens/welcome_screen.dart';
import 'package:flutter_application_3/screens/notification_page.dart';
import 'package:flutter_application_3/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'firebase_options.dart'; 
import 'package:firebase_database/firebase_database.dart';
import 'package:dio/dio.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_application_3/services/notification_service.dart';




void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
    await requestNotificationPermissions();

  await initNotifications(); 
/*
  FirebaseDatabase.instance.databaseURL = 'https://majd-726c9-default-rtdb.europe-west1.firebasedatabase.app';
  FirebaseDatabase.instance.setPersistenceEnabled(true); 
*/
if (kIsWeb) {
  FirebaseDatabase.instance.databaseURL =
      'https://majd-726c9-default-rtdb.europe-west1.firebasedatabase.app';
} else {
  FirebaseDatabase.instance.databaseURL =
      'https://majd-726c9-default-rtdb.europe-west1.firebasedatabase.app';
  FirebaseDatabase.instance.setPersistenceEnabled(true); 
}

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
await flutterLocalNotificationsPlugin.initialize(
  initializationSettings,
  onDidReceiveNotificationResponse: (NotificationResponse response) async {
    if (response.payload != null) {
      final payloadData = jsonDecode(response.payload!);
      final String userId = payloadData['userId'];
      final String title = payloadData['title'];
      final String body = payloadData['body'];

      await addNotificationToDB(userId, title, body);
    }
  },
);


  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => const NotificationPage(),
    ));
  });
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Message received while app is in foreground: ${message.notification?.title}');
  
  showLocalNotification(
    message.notification?.title ?? 'MediCardia',
    message.notification?.body ?? 'You have a new message',
  );

  addNotificationToDB(
    message.data['id'] ?? 'unknown_user',
    message.notification?.title ?? 'No Title',
    message.notification?.body ?? 'No Body',
  );
});


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      navigatorKey: navigatorKey,
      home: WelcomeScreen(),
    );
  }
}
