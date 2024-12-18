class Permission {
  String doctorid;      
  String userId;    
  String selectedPriority;       
  String body;     
  int deadline;     
  String name;     

  Permission({
    required this.doctorid,
    required this.userId,
    required this.selectedPriority,
    required this.body,
        required this.deadline,
        required this.name,

  });

  Map<String, dynamic> toMap() {
    return {
      'doctorid': doctorid,
      'userId': userId,
      'selectedPriority': selectedPriority,
      'body': body,
            'deadline': deadline,
      'name':name,

    };
  }
    

  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      doctorid: map['doctorid'],
      userId: map['userId'],
      selectedPriority: map['selectedPriority'],
      body: map['body'],
      deadline: map['deadline'] as int,
name: map['name'],
    );
  }
}
