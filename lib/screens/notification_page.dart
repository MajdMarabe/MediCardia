import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final storage = FlutterSecureStorage();
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final storage = FlutterSecureStorage();
  List<Map<String, dynamic>> notifications = [];
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('notifications');

  @override
  void initState() {
    super.initState();
   // _fetchNotifications();
    _fetchFirebaseNotifications();
  }

  // Fetch notifications from the backend
  Future<void> _fetchNotifications() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        throw Exception('User not authenticated');
      }
      final headers = {
        'Content-Type': 'application/json',
        'token': token,
      };
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications/allnotifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notifications.addAll(data.map((item) => item as Map<String, dynamic>).toList());
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  // Fetch notifications from Firebase Realtime Database
  Future<void> _fetchFirebaseNotifications() async {
   try {
    // قراءة الـ userId من الـ FlutterSecureStorage
    final String? userId = await storage.read(key: 'userid');
    if (userId == null) {
      print('User ID not found');
      return;
    }

    // الحصول على مرجع قاعدة بيانات Firebase
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('notifications');

    // جلب جميع الإشعارات
    final snapshot = await databaseRef.orderByChild('userId').equalTo(userId).get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      // تحويل البيانات إلى قائمة من الخرائط
      List<Map<String, dynamic>> fetchedNotifications = [];
      data.forEach((key, value) {
        fetchedNotifications.add({
          'id': key,
          'title': value['title'] ?? 'No Title',
          'body': value['body'] ?? 'No Body',
          'timestamp': value['timestamp'] ?? '',
          'userId': value['userId'] ?? '',
        });
      });

      setState(() {
        notifications = fetchedNotifications;
      });
    } else {
      print('No notifications found for user $userId');
      setState(() {
        notifications = [];
      });
    }
  } catch (e) {
    print('Error fetching notifications from Firebase: $e');
  }

  }

  // Delete notification from the backend and local list
  Future<void> _deleteNotification(String notificationId) async {
 try {
    final String? userId = await storage.read(key: 'userid');
    if (userId == null) {
      print('User ID not found');
      return;
    }

    // الحصول على مرجع قاعدة بيانات Firebase
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('notifications');

    // حذف الإشعار من Firebase باستخدام notificationId
    await databaseRef.child(notificationId).remove();

    // بعد حذف الإشعار من Firebase، تحديث القائمة محلياً
    setState(() {
      notifications.removeWhere((notification) => notification['id'] == notificationId);
    });

    // إظهار رسالة تأكيد بعد الحذف
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted successfully')),
    );
  } catch (e) {
    print('Error deleting notification from Firebase: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error deleting notification')),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xff613089),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(notification['title'] ?? 'No Title'),
                    subtitle: Text(notification['body'] ?? 'No Body'),
                    leading: const Icon(Icons.notification_important, color: Color(0xff613089)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
    _deleteNotification(notification['id']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
