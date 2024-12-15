class Message {
  String sender;      // معرف المرسل
  String receiver;    // معرف المستقبل
  String text;        // نص الرسالة
  int timestamp;      // توقيت الإرسال (بالمللي ثانية)
  String status;      // حالة الرسالة (مرسلة، مقروءة)
  String chatId;      // معرف المحادثة (جديد)

  Message({
    required this.sender,
    required this.receiver,
    required this.text,
    required this.timestamp,
    required this.status,
    required this.chatId,
  });

  // تحويل الكائن إلى خريطة (Map) لكتابة البيانات في Firebase
  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'text': text,
      'timestamp': timestamp,
      'status': status,
      'chatId': chatId,
    };
  }

  // إنشاء كائن `Message` من خريطة (Map) عند قراءة البيانات من Firebase
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'],
      receiver: map['receiver'],
      text: map['text'],
      timestamp: map['timestamp'] as int,
      status: map['status'],
      chatId: map['chatId'],
    );
  }
}
