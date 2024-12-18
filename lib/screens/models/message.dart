class Message {
  String sender;      
  String receiver;    
  String text;       
  int timestamp;     
  String status;     
  String chatId;    

  Message({
    required this.sender,
    required this.receiver,
    required this.text,
    required this.timestamp,
    required this.status,
    required this.chatId,
  });

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
