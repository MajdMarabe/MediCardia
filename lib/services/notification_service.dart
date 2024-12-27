import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dio/dio.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final storage = FlutterSecureStorage();
String? DeviceToken;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
  await showLocalNotification(
    message.notification?.title ?? 'MediCardia',
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


Future<void> initNotifications() async {
 /* NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );*/
 // print('Notification permission status: ${settings.authorizationStatus}');
  if (!kIsWeb) {
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    DeviceToken = deviceToken; 
    print("Device Token: $deviceToken");
  } else {
    try {
      await FirebaseMessaging.instance.requestPermission();
      print("Notifications permission granted on web.");
    } catch (e) {
      print("Error requesting permissions: $e");
    }
  }

}

Future<void> sendNotifications({
  required String fcmToken,
  required String title,
  required String body,
  required String userId,
  String? type,
}) async {
  try {

    final userPreferences = await fetchUserPreferences(userId);
    if (userPreferences == null) {
      print('Error fetching user preferences');
      return;
    }

    if (type == 'message' && !userPreferences['messages']) {
      print('User has disabled message notifications');
      return;  
    }

    if (type == 'reminder' && !userPreferences['reminders']) {
      print('User has disabled reminder notifications');
      return;  
    }

    if (type == 'request' && !userPreferences['requests']) {
      print('User has disabled request notifications');
      return;  
    }
 if (type == 'donation' && !userPreferences['donation']) {
      print('User has disabled donation notifications');
      return;  
    }






    var serverKeyAuthorization = await getAccessToken();

    const String urlEndPoint = "https://fcm.googleapis.com/v1/projects/majd-726c9/messages:send";

    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = 'Bearer $serverKeyAuthorization';

    var response = await dio.post(
      urlEndPoint,
      data: getBody(
        userId: userId,
        fcmToken: fcmToken,
        title: title,
        body: body,
        type: type ?? "message",
      ),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
  } catch (e) {
    print("Error sending notification: $e");
  }
}
Future<Map<String, dynamic>?> fetchUserPreferences(String userId) async {
  try {
    final userResponse = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/$userId/setting'),
    );
    print('User response: ${userResponse.body}');

    if (userResponse.statusCode == 200) {
      final Map<String, dynamic> userData = json.decode(userResponse.body);
      print('User data: $userData');
      return userData; 
    }

    final doctorResponse = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/doctors/$userId/setting'),
    );
    print('Doctor response: ${doctorResponse.body}');

    if (doctorResponse.statusCode == 200) {
      final Map<String, dynamic> doctorData = json.decode(doctorResponse.body);
      print('Doctor data: $doctorData');
      return doctorData;
    }

    print('No matching user or doctor found.');
    return null;
  } catch (e) {
    print('Error fetching user preferences: $e');
    return null;
  }
}

Map<String, dynamic> getBody({
  required String fcmToken,
  required String title,
  required String body,
  required String userId,
  String? type,
}) {
  return {
    "message": {
      "token": fcmToken,
      "notification": {"title": title, "body": body},
      "android": {
        "notification": {
          "notification_priority": "PRIORITY_MAX",
          "sound": "default"
        }
      },
      "apns": {
        "payload": {
          "aps": {"content_available": true}
        }
      },
      "data": {
        "type": type,
        "id": userId,
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    }
  };
}

Future<String?> getAccessToken() async {
  final serviceAccountJson = {
  "type": "service_account",
  "project_id": "majd-726c9",
  "private_key_id": "21b45bfc88015b1ca1484b9ec1f9b920b168c779",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDuUVOJULFAq4Zs\nfacJiSb2jKkc7yV72zcLFxev0BQzo7T2JStVKzarfDut3SQ7/xVCEFyKIFxf1Lvn\n5nTzk3vSidkGMH+ayfveluVSsbQVH11gWdhOaTsy/PLlNM+OccJMKJb/lye/GtBd\nld04027SIJqOL8u6GuRtSfCX4kTRZQaFd0Ooc66pFzleBKaoy9t7XfvkljSPEDke\nPomGkiYlDoV4e3lnba2FLqSdY/1W1A8ZwuwY97ss9DHU5HdbUfw43qvESuGQpqow\nuIF9zqUJNbrWOeAUtEw8HmOY/KX2yzaBV9xtBSe3yWQePZE2pj6iyelP5fU6naX0\nmSTS5HpvAgMBAAECggEAAKYDVoNRXX4EqUo/kxy8GL2nPtHpGzOB1yuNP/LkAIP4\nhmxGzZOG3DlD/E7ME3G36sHFTrGUhBo9wf10N1l2Y8tGO5MUNc/zjyvVRz/+inQs\nZTUOtp/orlSBNgh1FsvOczXvu0BRC7Rp+Wc3/o3su5ulGq/x8PlebRcKFY+4ZOLN\nJRBKw9cquuicpTd/uab2pAlpuFTVDGOP3tCe0CFeKWY8rEKZpiaqmNKKDeqKp8y+\njNfUkq7SeYro1hoTancocGvQeNjEnsAhghVdXg/dKudshffFcdpPDI758SOC5LUY\nIizTMWHlPIfWpF2SVieW4VbH+ipPNnvPrU4SekgyYQKBgQD/6LOmAO7+9dnpgm0b\n2RcVuYkS95opnp6gNHZ8kysG18GsBNgnpklcqTUKA/Ruhw/bCZHOVjqV88B5/UsV\n9h8797zSI9r055XNoApVDaTVB4hEaZ1vILlSdp5W9sSWlr0k99VnDgu/nRidzpqW\neSluC++JDdcZOOrWUSMCsvwDfwKBgQDuZwXlPWNUMoJg2fMFF3NGeYAVyyzIlpDO\ncXNpLnpSW4+8gZnhLzlA2G4Os2Bh0hBDArnZjgO83UGHfzOsONSfXQAHkjdE6vp6\npHtIiTEjmXixMkoGTsWGKfMhC1Ff7bXGBnV9NTeuT7Jw2C6m6pLGpLy7urVQlJCb\nUI/OWztBEQKBgDU08rUfGJHWF/qe7YSOvGf97WwOIvVoT17LyZ7ZEmcX0OKtFywX\nPMWRQL/WVqnsVvWZpcEa2I944Jn8efIU/CWBuraOUeX9iH36Omu4rH7GVCS1ONB0\nI1Pr6bv3DqSorqbTCIGmv/aU+RtGa4nBo0WIIcODJyfNV7Y7pGXZROCNAoGBAIv2\nmBN58vLfpIPP8Ukv91GMy5H/8o7hNqq9GJDL5KytbLmzLPBzlR1o81RWI2PKvBlb\nZFlBcxhSncI6/89AnjPhmb7YLPKdMekG4Ao54UuRMrZ1W9hQLs8RmdfwmRnEqU9V\nQ2z67XG9AHoXsWv1k65j0Ro2B3UDg9JrfcIc9bDBAoGANaXr9Pytd8aZO4zJhaAN\nEehDhjYm3Hzm+I292lbiVan4sErqtiEcS/cHSQjTnMoNmuXe4GQlQwQWmau6naDW\nxKU8ji5japVpbEX8vH8uk+5YcsGz+pbagOzY4braoBCiR0xwp/Gm0Jir9wLlOxkC\nUO3ZCnlhHfJBJpnddzQmfoM=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-vnuwr@majd-726c9.iam.gserviceaccount.com",
  "client_id": "102119221824262090082",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-vnuwr%40majd-726c9.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
  };

  List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging"
  ];

  try {
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();
    print("Access Token: ${credentials.accessToken.data}"); // طباعة التوكن
    return credentials.accessToken.data;
  } catch (e) {
    print("Error getting access token: $e");
    return null;
  }
}

Future<void> addNotificationToDB(String userId, String title, String body) async {
  try {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('notifications').push();

    await ref.set({
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Notification added to Firebase Realtime Database successfully.');
  } catch (error) {
    print('Error adding notification to Firebase: $error');
  }
}
Future<void> scheduleReminder(TimeOfDay time, String userId) async {
  final userPreferences = await fetchUserPreferences(userId);
  
  if (userPreferences != null && userPreferences['reminders'] == true) {
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
    
    await addNotificationToDB(
      userId,
      'Reminder: Time to measure your glucose level!',
      'You set a reminder to measure your glucose level at ${scheduledTime.toLocal()}',
    );

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
  } else {
    print('Notifications are disabled for this user.');
  }
}

Future<void> _addReminderToDB(String userId, String title, String body, TimeOfDay time) async {
  try {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('reminders').push();

    await ref.set({
      'userId': userId,
      'title': title,
      'body': body,
      'time': time.format(DateTime.now() as BuildContext),  
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Reminder added to Firebase Realtime Database successfully.');
  } catch (error) {
    print('Error adding reminder to Firebase: $error');
  }
}

Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel', 'Default Notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'app_logo',
    color: Color(0xff613089),
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

























// مفاتيح وأدوات عامة
/*

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('app_logo');
  const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
final storage = FlutterSecureStorage();
String? DeviceToken;
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
  await _showLocalNotification(
    message.notification?.title ?? 'MediCardia',
    message.notification?.body ?? 'You have a new message',
  );
}
// تهيئة FirebaseMessaging والحصول على التوكن
Future<void> initNotifications() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('Notification permission status: ${settings.authorizationStatus}');

  String? deviceToken = await FirebaseMessaging.instance.getToken();
  DeviceToken = deviceToken;
  print("Device Token: $deviceToken");
}

// طلب أذونات الإشعارات
Future<void> requestNotificationPermissions() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('Notification permission status: ${settings.authorizationStatus}');
}

// معالج رسائل FCM في الخلفية


// عرض إشعار محلي
Future<void> _showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel', 'Default Notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'app_logo',
    color: Color(0xff613089),
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

// إضافة الإشعار إلى Firebase Realtime Database
Future<void> _addNotificationToDB(String userId, String title, String body) async {
  try {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('notifications').push();

    await ref.set({
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Notification added to Firebase Realtime Database successfully.');
  } catch (error) {
    print('Error adding notification to Firebase: $error');
  }
}

// إرسال الإشعار باستخدام FCM و Dio
Future<void> sendNotifications({
  required String fcmToken,
  required String title,
  required String body,
  required String userId,
  String? type,
}) async {
  try {
    var serverKeyAuthorization = await getAccessToken();

    const String urlEndPoint = "https://fcm.googleapis.com/v1/projects/majd-726c9/messages:send";

    Dio dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = 'Bearer $serverKeyAuthorization';

    await dio.post(
      urlEndPoint,
      data: getBody(
        userId: userId,
        fcmToken: fcmToken,
        title: title,
        body: body,
        type: type ?? "message",
      ),
    );
  } catch (e) {
    print("Error sending notification: $e");
  }
}

// جدولة إشعار (Reminder)
Future<void> scheduleReminder(TimeOfDay time, String userId) async {
  final now = DateTime.now();
  final scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

  final tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'reminder_channel', 'Reminder Notifications',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'app_logo',
    color: Color(0xff613089),
  );

  const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

  await _addNotificationToDB(
    userId,
    'Reminder: Time to measure your glucose level!',
    'You set a reminder to measure your glucose level at ${scheduledTime.toLocal()}',
  );

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

Future<void> initializeTimeZone() async {
  tz.initializeTimeZones();
}

// الحصول على body لاستخدامه في إرسال الإشعار
Map<String, dynamic> getBody({
  required String fcmToken,
  required String title,
  required String body,
  required String userId,
  String? type,
}) {
  return {
    "message": {
      "token": fcmToken,
      "notification": {"title": title, "body": body},
      "android": {
        "notification": {
          "notification_priority": "PRIORITY_MAX",
          "sound": "default"
        }
      },
      "apns": {
        "payload": {
          "aps": {"content_available": true}
        }
      },
      "data": {
        "type": type,
        "id": userId,
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    }
  };
}

// الحصول على Access Token من حساب Firebase
Future<String?> getAccessToken() async {
  final serviceAccountJson = {
  "type": "service_account",
  "project_id": "majd-726c9",
  "private_key_id": "21b45bfc88015b1ca1484b9ec1f9b920b168c779",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDuUVOJULFAq4Zs\nfacJiSb2jKkc7yV72zcLFxev0BQzo7T2JStVKzarfDut3SQ7/xVCEFyKIFxf1Lvn\n5nTzk3vSidkGMH+ayfveluVSsbQVH11gWdhOaTsy/PLlNM+OccJMKJb/lye/GtBd\nld04027SIJqOL8u6GuRtSfCX4kTRZQaFd0Ooc66pFzleBKaoy9t7XfvkljSPEDke\nPomGkiYlDoV4e3lnba2FLqSdY/1W1A8ZwuwY97ss9DHU5HdbUfw43qvESuGQpqow\nuIF9zqUJNbrWOeAUtEw8HmOY/KX2yzaBV9xtBSe3yWQePZE2pj6iyelP5fU6naX0\nmSTS5HpvAgMBAAECggEAAKYDVoNRXX4EqUo/kxy8GL2nPtHpGzOB1yuNP/LkAIP4\nhmxGzZOG3DlD/E7ME3G36sHFTrGUhBo9wf10N1l2Y8tGO5MUNc/zjyvVRz/+inQs\nZTUOtp/orlSBNgh1FsvOczXvu0BRC7Rp+Wc3/o3su5ulGq/x8PlebRcKFY+4ZOLN\nJRBKw9cquuicpTd/uab2pAlpuFTVDGOP3tCe0CFeKWY8rEKZpiaqmNKKDeqKp8y+\njNfUkq7SeYro1hoTancocGvQeNjEnsAhghVdXg/dKudshffFcdpPDI758SOC5LUY\nIizTMWHlPIfWpF2SVieW4VbH+ipPNnvPrU4SekgyYQKBgQD/6LOmAO7+9dnpgm0b\n2RcVuYkS95opnp6gNHZ8kysG18GsBNgnpklcqTUKA/Ruhw/bCZHOVjqV88B5/UsV\n9h8797zSI9r055XNoApVDaTVB4hEaZ1vILlSdp5W9sSWlr0k99VnDgu/nRidzpqW\neSluC++JDdcZOOrWUSMCsvwDfwKBgQDuZwXlPWNUMoJg2fMFF3NGeYAVyyzIlpDO\ncXNpLnpSW4+8gZnhLzlA2G4Os2Bh0hBDArnZjgO83UGHfzOsONSfXQAHkjdE6vp6\npHtIiTEjmXixMkoGTsWGKfMhC1Ff7bXGBnV9NTeuT7Jw2C6m6pLGpLy7urVQlJCb\nUI/OWztBEQKBgDU08rUfGJHWF/qe7YSOvGf97WwOIvVoT17LyZ7ZEmcX0OKtFywX\nPMWRQL/WVqnsVvWZpcEa2I944Jn8efIU/CWBuraOUeX9iH36Omu4rH7GVCS1ONB0\nI1Pr6bv3DqSorqbTCIGmv/aU+RtGa4nBo0WIIcODJyfNV7Y7pGXZROCNAoGBAIv2\nmBN58vLfpIPP8Ukv91GMy5H/8o7hNqq9GJDL5KytbLmzLPBzlR1o81RWI2PKvBlb\nZFlBcxhSncI6/89AnjPhmb7YLPKdMekG4Ao54UuRMrZ1W9hQLs8RmdfwmRnEqU9V\nQ2z67XG9AHoXsWv1k65j0Ro2B3UDg9JrfcIc9bDBAoGANaXr9Pytd8aZO4zJhaAN\nEehDhjYm3Hzm+I292lbiVan4sErqtiEcS/cHSQjTnMoNmuXe4GQlQwQWmau6naDW\nxKU8ji5japVpbEX8vH8uk+5YcsGz+pbagOzY4braoBCiR0xwp/Gm0Jir9wLlOxkC\nUO3ZCnlhHfJBJpnddzQmfoM=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-vnuwr@majd-726c9.iam.gserviceaccount.com",
  "client_id": "102119221824262090082",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-vnuwr%40majd-726c9.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
  };

  List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging"
  ];

  try {
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();
    print("Access Token: ${credentials.accessToken.data}"); // طباعة التوكن
    return credentials.accessToken.data;
  } catch (e) {
    print("Error getting access token: $e");
    return null;
  }
}

*/