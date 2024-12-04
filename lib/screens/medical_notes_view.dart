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

  Future<void> updateMedicalNote(int index, Map<String, dynamic> updatedItem) async {
    final userId = await storage.read(key: 'userid');
    if (userId != null) {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/medicalnotes/${updatedItem['_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedItem),
      );
      if (response.statusCode == 200) {
        setState(() {
          medicalNotes[index] = updatedItem;
        });
      } else {
        print("Failed to update: ${response.statusCode}");
      }
    }
  }

  Future<void> deleteMedicalNote(int index) async {
    final item = medicalNotes[index];
    setState(() {
          medicalNotes.removeAt(index);
        });
    final userId = await storage.read(key: 'userid');
    if (userId != null) {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/medicalnotes/${item['_id']}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        
      } else {
        print("Failed to delete: ${response.statusCode}");
      }
    }
  }

  void showEditDialog(int index) {
    final item = medicalNotes[index];
    final noteController = TextEditingController(text: item['note']);

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
                  '_id': item['_id'],
                  'note': noteController.text,
                };
                updateMedicalNote(index, updatedItem);
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

  void showAddDialog() {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add New Medical Note", style: TextStyle(color: Color(0xff613089))),
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
                final newItem = {
                  'note': noteController.text,
                };
                setState(() {
                  medicalNotes.add(newItem);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff613089),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Widget buildMedicalNoteCard(Map<String, dynamic> item, int index) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shadowColor: Color(0xff613089).withOpacity(0.5),
      child: ListTile(
        title: Text(item['note'], style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff613089))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xff613089)),
              onPressed: () => showEditDialog(index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Color(0xff613089)),
              onPressed: () => deleteMedicalNote(index),
            ),
          ],
        ),
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
