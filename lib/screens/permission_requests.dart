import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:flutter_application_3/screens/doctor_home.dart';
import 'package:flutter_application_3/services/notification_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

class PermissionRequestsPage extends StatefulWidget {

  const PermissionRequestsPage({Key? key}) : super(key: key);

  @override
  _PermissionRequestsPageState createState() => _PermissionRequestsPageState();
}

class _PermissionRequestsPageState extends State<PermissionRequestsPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('Permission'); // المسار إلى قاعدة البيانات
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> permissions= [];

  @override
  void initState() {
    super.initState();
    _fetchPermissionRequests();
  }
// Fetch notifications from Firebase Realtime Database
  Future<void> _fetchPermissionRequests() async {
   try {
    // قراءة الـ userId من الـ FlutterSecureStorage
    final String? userId = await storage.read(key: 'userid');
    print(userId);
    if (userId == null) {
      print('User ID not found');
      return;
    }

    // الحصول على مرجع قاعدة بيانات Firebase
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('Permission');

    // جلب جميع الإشعارات
    final snapshot = await databaseRef.orderByChild('userId').equalTo(userId).get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      // تحويل البيانات إلى قائمة من الخرائط
      List<Map<String, dynamic>> fetchedpermission = [];
      data.forEach((key, value) {
        fetchedpermission.add({
          'id': key,
                    'body': value['body']?? 'No Title',
                    'deadline': value['deadline']?? 'No Title',
                    'doctorId': value['doctorid']?? 'No Title',
                    'selectedPriority': value['selectedPriority']?? 'No Title',
                    'name' : value['name']?? 'No Title',
        });
      });

      setState(() {
        permissions = fetchedpermission;
      });
    } else {
      print('No notifications found for user $userId');
      setState(() {
        permissions = [];
      });
    }
  } catch (e) {
    print('Error fetching notifications from Firebase: $e');
  }

  }
  

  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Permission Requests'),
      backgroundColor: const Color(0xff613089),
    ),
    body: permissions.isEmpty
        ? const Center(
            child: Text(
              'No permission requests found.',
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: permissions.length,
            itemBuilder: (context, index) {
              final request = permissions[index];
final String nnnn = request['doctorId'];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30.0,
                            backgroundColor: const Color.fromARGB(255, 185, 160, 205),
                            child: const Icon(
                              Icons.person,
                              size: 35.0,
                              color: Color(0xff613089),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Doctor name: ${request['name']}',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Priority: ${request['selectedPriority']}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Deadline: ${request['deadline']}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Reason:',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff613089),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        request['body'] ?? 'No reason provided',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              final String docid = request['doctorId']??'';
_setAsMyDoctor(context, docid);
final String requestId = request['id'];
    _handlePermissionAction(requestId, true); // true for accepted

                            },
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 30.0,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                             final String requestId = request['id'];
                              final String username = storage.read(key: 'username') as String;
    _handlePermissionAction(requestId, true); // true for accepted
_sendNotification( request['doctorId'],"Meidicardia",  "$username accepted your request , you can see the data now ");
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 30.0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
  );
}
Future<void> _handlePermissionAction(String requestId, bool isAccepted) async {
  try {
    // Deleting the permission request from Firebase
    await _dbRef.child(requestId).remove(); // Remove request by ID

    // Show confirmation based on action
    String action = isAccepted ? 'accepted' : 'rejected';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request has been $action.'),
      ),
    );

    // After deletion, update the local state (UI)
    setState(() {
      permissions.removeWhere((permission) => permission['id'] == requestId);
    });

  } catch (e) {
    print('Error handling permission action: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred while processing the request.'),
      ),
    );
  }
}

  Future<void> _setAsMyDoctor(BuildContext context, String doctorid ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/doctorsusers/relations');
    final patientId = await storage.read(key: 'userid');
//print(doctorname);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your_auth_token',
        },
        body: json.encode({
          'doctorId':doctorid,
          'patientId': patientId,
          'relationType': 'Primary',
          'notes': 'Patient added doctor as primary care provider',
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "has been set as your doctor.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(" is already your doctor.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }


void _sendNotification(String receiverId, String title, String message) async {
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref('users/$receiverId');
  final DataSnapshot snapshot = await usersRef.get();

  if (snapshot.exists) {
    final String? fcmToken = snapshot.child('fcmToken').value as String?;

    if (fcmToken != null) {
      try {
        await sendNotifications(
          fcmToken: fcmToken,
          title: title,
          body: message,
          userId: receiverId,
        );
        print('Notification sent successfully');
      } catch (error) {
        print('Error sending notification: $error');
      }
    } else {
      print('FCM token not found for the user.');
    }
  } else {
    print('User not found in the database.');
  }
}
}
