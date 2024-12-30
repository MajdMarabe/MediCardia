import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'constants.dart';


const storage = FlutterSecureStorage();

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref('notifications');

  @override
  void initState() {
    super.initState();
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


  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);

    //final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    //String formattedDate = formatter.format(dateTime);

    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

///////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
   appBar: AppBar(
  elevation: 0,
  centerTitle: true,
  backgroundColor: const Color(0xFFF2F5FF),
  title: const Text(
    'Notifications',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xff613089),
      letterSpacing: 1.5,
    ),
  ),
  leading: Visibility(
    visible: !kIsWeb, 
    child: IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),
),

      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No notifications yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return Dismissible(
                  key: Key(notification['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteNotification(notification['id']);
                  },
                  background: Container(
                    color: const Color(0xFF613089),
                    child:
                        const Icon(Icons.delete, color: Colors.white, size: 40),
                  ),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        notification['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(notification['body'] ?? 'No Body'),
                          const SizedBox(height: 10),
                          Text(
                            formatTimestamp(notification['timestamp'] ?? ''),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xff613089),
                        child: Icon(Icons.notifications, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
