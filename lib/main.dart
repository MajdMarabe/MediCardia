import 'dart:convert';
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

final storage = FlutterSecureStorage();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
  await _showLocalNotification(
    message.notification?.title ?? 'New Notification',
    message.notification?.body ?? 'You have a new message',
  );
}

Future<void> requestNotificationPermissions() async {
  final messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('Notification permission status: ${settings.authorizationStatus}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await requestNotificationPermissions();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
        await _addNotificationToDB(userId, title, body);
      }
    },
  );

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => const NotificationPage(),
    ));
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

Future<void> scheduleReminder(TimeOfDay time, String userId) async {
  final now = DateTime.now();
  final scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

  final tz.TZDateTime scheduledTime = scheduledDate.isBefore(DateTime.now())
      ? tz.TZDateTime.from(scheduledDate.add(Duration(days: 1)), tz.local)
      : tz.TZDateTime.from(scheduledDate, tz.local);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'reminder_channel', 'Reminder Notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'app_logo',
    color: Color(0xff613089),
  );

  const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    time.hashCode,
    'MediCardia',
    'Time to measure your glucose level!',
    scheduledTime,
    notificationDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: jsonEncode({'userId': userId, 'title': 'MediCardia', 'body': 'Time to measure your glucose level!'}),
  );
}

Future<void> _showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel', 'Default Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
    payload: jsonEncode({'title': title, 'body': body}),
  );
}

Future<void> _addNotificationToDB(String userId, String title, String body) async {
  try {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Token not found');
    }
    final headers = {
      'Content-Type': 'application/json',
      'token': token,
    };
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/notifications/addnotifications'),
      headers: headers,
      body: jsonEncode({
        'userId': userId,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 201) {
      print('Notification added to DB successfully.');
    } else {
      print('Failed to add notification to DB: ${response.body}');
    }
  } catch (error) {
    print('Error adding notification to DB: $error');
  }
}