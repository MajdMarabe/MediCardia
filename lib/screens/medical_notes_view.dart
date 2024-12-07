import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

final storage = FlutterSecureStorage();

class MedicalNotesPage extends StatefulWidget {
  @override
  _MedicalNotesPageState createState() => _MedicalNotesPageState();
}

class _MedicalNotesPageState extends State<MedicalNotesPage> {
  List<dynamic> medicalNotes = [];

  @override
  void initState() {
    super.initState();
    fetchMedicalNotes();
  }

  Future<void> fetchMedicalNotes() async {
    try {
      final userId = await storage.read(key: 'userid');
      if (userId != null) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/users/$userId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            medicalNotes = data['medicalCard']['privateData']['medicalNotes'] ?? [];
          });
        } else {
          print("Error: ${response.statusCode}");
        }
      } else {
        print("User ID not found in secure storage.");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

Future<void> deleteMedicalNote(int index) async {
  final item = medicalNotes[index];
  setState(() {
    medicalNotes.removeAt(index);
  });

  final userId = await storage.read(key: 'userid');
  final itemId = {
    'entryId': item['_id'],
  };

  if (userId != null) {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/users/$userId/medicalnotes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(itemId),  // Ensure the body is a valid JSON string
    );

    if (response.statusCode == 200) {
      print('Deleted successfully');
    } else {
      print("Failed to delete: ${response.statusCode}");
    }
  }
}

void showEditDialog(int index) {
  final item = medicalNotes[index];
  final noteController = TextEditingController(text: item['note']);
    final userid =  storage.read(key: 'userid');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Medical Note", style: TextStyle(color: Color(0xff613089))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: "Note",
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  prefixIcon: Icon(Icons.note, color: Color(0xff613089)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedItem = {
                'userid': userid,  // Replace with the logged-in user's ID
                'noteId': item['_id'],     // Replace with the note ID to update
                'updatedNote': noteController.text,
              };

              updateMedicalNote(updatedItem);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff613089),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("Save"),
          ),
        ],
      );
    },
  );
}

Future<void> updateMedicalNote(Map<String, dynamic> updatedItem) async {
    final userid = await storage.read(key: 'userid');

 // final url =   Uri.parse('${ApiConstants.baseUrl}/users/$userid/medicalNotes');  // Replace with your API URL
      

  try {
    final response = await http.put(
       Uri.parse('${ApiConstants.baseUrl}/users/$userid/medicalNotes'),
             headers: {'Content-Type': 'application/json'},

      body: json.encode(updatedItem),
    );

    if (response.statusCode == 200) {
      // Handle success
      final responseData = json.decode(response.body);
      print('Medical note updated: ${responseData['updatedNote']}');
    } else {
      // Handle error
      print('Failed to update medical note: ${response.body}');
    }
  } catch (error) {
    print('Error updating medical note: $error');
  }
}

Future<void> addMedicalNotes(String note) async {
  final userid = await storage.read(key: 'userid');
  if (userid == null) {
    throw Exception('no userid');
  }

  final headers = {
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
          'userid' : userid,

    'notes': [
      {'note': note}
    ],
  });

  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/users/addMedicalNotes'),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    // Successfully added note
    final responseData = jsonDecode(response.body);
    print('Medical notes updated: ${responseData['medicalNotes']}');
  } else {
    // Handle errors
    final errorData = jsonDecode(response.body);
    throw Exception('Failed to add medical notes: ${errorData['message']}');
  }
}
void showAddDialog() {
  final noteController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Add New Medical Note",
          style: TextStyle(color: Color(0xff613089)),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: "Note",
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  prefixIcon: Icon(Icons.note, color: Color(0xff613089)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNote = noteController.text.trim();

              if (newNote.isEmpty) {
                // Show an error message if the note is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Note cannot be empty")),
                );
                return;
              }

              try {
                // Send the note to the backend
                await addMedicalNotes(newNote);

                // Optionally update local UI state if successful
                setState(() {
                  medicalNotes.add({'note': newNote});
                });

                // Close the dialog
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Medical note added successfully")),
                );
              } catch (error) {
                // Show error message if the API call fails
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add note: $error")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff613089),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text("Add"),
          ),
        ],
      );
    },
  );
}
Widget buildMedicalNoteCard(Map<String, dynamic> item, int index) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
      border: Border.all(color: Color(0xff4A148C).withOpacity(0.1)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leading Icon: Medical Note Icon
        CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xffD1C4E9),
          child: Icon(
            Icons.medical_services,
            color: Color(0xff4A148C),
            size: 32,
          ),
        ),
        SizedBox(width: 16),

        // Note Details Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Note Text with Better Scroll Handling for Long Notes
              Container(
                constraints: BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(
                  child: Text(
                    item['note'] ?? "No note content available.",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xff4A148C),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                  ),
                ),
              ),
              SizedBox(height: 8),

              // Additional Details (Date Added, for example)
              Text(
                'Added on: ${item['date'] ?? DateTime.now().toString().split(' ')[0]}', // Example date or provided date
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Action Buttons (Edit, Delete)
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => showEditDialog(index),
              tooltip: 'Edit Note',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteMedicalNote(index),
              tooltip: 'Delete Note',
            ),
          ],
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Medical Notes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF613089),
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: medicalNotes.length + 1, // +1 for the Add button
                itemBuilder: (context, index) {
                  if (index < medicalNotes.length) {
                    return buildMedicalNoteCard(medicalNotes[index], index);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: TextButton(
                        onPressed: showAddDialog,
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xff613089),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        ),
                        child: Text(
                          "Add New Medical Note",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
