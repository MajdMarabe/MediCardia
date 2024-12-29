import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_3/services/notification_service.dart';

const storage = FlutterSecureStorage();

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String name;
  const ChatPage({Key? key, required this.receiverId, required this.name})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('messages');
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String? senderid = '';
  String recname = '';
  String? base64Image;

  @override
  void initState() {
    super.initState();
    _initializeSenderId();
  }

  Future<void> _initializeSenderId() async {
    recname = widget.name;
    senderid = await storage.read(key: 'userid');
    if (senderid == null) {
      print('User ID not found');
      return;
    }
    
    _loadReceiverProfileImage();

    print('Sender ID: $senderid');
    _listenForMessages();
  }

  Future<void> _loadReceiverProfileImage() async {
    final usersRef = FirebaseDatabase.instance.ref('users/${widget.receiverId}');
    final snapshot = await usersRef.get();

    if (snapshot.exists) {
      final medicalCard = snapshot.child('medicalCard/publicData');
      setState(() {
        base64Image = medicalCard.child('image').value as String?;
        print("Base64 image: $base64Image");

      });
    }
  }


  Image buildImageFromBase64(String? base64Image) {
    try {
      if (base64Image == null || base64Image.isEmpty) {
        return Image.asset('assets/images/default_person.jpg');
      }

      final bytes = base64Decode(base64Image);
      print("Decoded bytes length: ${bytes.length}");

      return Image.memory(bytes);
    } catch (e) {
      print("Error decoding image: $e");
      return Image.asset('assets/images/default_person.jpg');
    }
  }


  Widget _buildUserAvatar() {
    ImageProvider backgroundImage;
    try {
      backgroundImage = buildImageFromBase64(base64Image).image;
    } catch (e) {
      backgroundImage = const AssetImage('assets/images/default_person.jpg');
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      backgroundImage: backgroundImage,
    );
  }

  void _listenForMessages() {
    final chatId = getChatId();

    _messagesRef.child(chatId).onChildAdded.listen((event) {
      final messageData = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _messages.add({
          'text': messageData['text'],
          'isMe': messageData['sender'] == senderid,
          'timestamp':
              messageData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
        });
      });
    });
  }

  String getChatId() {
    final ids = [senderid, widget.receiverId];
    ids.sort();
    return ids.join('_');
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final chatId = getChatId();
    _messagesRef.child(chatId).push().set({
      'sender': senderid,
      'receiver': widget.receiverId,
      'text': _controller.text.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }).then((_) async {
      final String? nameR = await storage.read(key: 'username');
      _sendNotification(widget.receiverId, "MediCardia",
          '$nameR' + ":" + _controller.text.trim());

      _controller.clear();
      _showMessage("Message sent successfully!");
    }).catchError((error) {
      _showMessage("Failed to send message: $error");
      print("Error: $error");
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff613089),
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            // عرض صورة المستخدم الـ receiver
            _buildUserAvatar(),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recname,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Text(
                  'Online',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: kIsWeb ? _buildWebChatUI() : _buildMobileChatUI(),
    );
  }

  Widget _buildMobileChatUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ChatBubble(
                text: _messages[index]['text'],
                isMe: _messages[index]['isMe'],
                timestamp: _messages[index]['timestamp'],
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildWebChatUI() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Container(
          width: 600,
          height: MediaQuery.of(context).size.height * 0.8,
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(
                      text: _messages[index]['text'],
                      isMe: _messages[index]['isMe'],
                      timestamp: _messages[index]['timestamp'],
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color.fromARGB(255, 118, 6, 137)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final int timestamp;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isMe,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final timeString =
        "${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}";
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color.fromARGB(255, 67, 4, 79)
                  : Colors.purple.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 12.0 : 0),
                topRight: Radius.circular(isMe ? 0 : 12.0),
                bottomLeft: const Radius.circular(12.0),
                bottomRight: const Radius.circular(12.0),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.purple.shade800),
            ),
          ),
          Text(
            timeString,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

void _sendNotification(String receiverId, String title, String message) async {
  final DatabaseReference usersRef =
      FirebaseDatabase.instance.ref('users/$receiverId');
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
          type: 'message',
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
