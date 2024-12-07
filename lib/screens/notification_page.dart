import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final storage = FlutterSecureStorage();
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
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
        'token': token ?? '',
      };
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications/allnotifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notifications = data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  // Delete notification from the backend and local list
  Future<void> _deleteNotification(String notificationId) async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final headers = {
        'Content-Type': 'application/json',
        'token': token ?? '',
      };

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications.removeWhere((notification) => notification['_id'] == notificationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print('Error deleting notification: $e');
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
                        _deleteNotification(notification['_id']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
