import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'constants.dart';

final storage = FlutterSecureStorage();

class LabTestsPage extends StatefulWidget {
  @override
  _LabTestsPageState createState() => _LabTestsPageState();
}

class _LabTestsPageState extends State<LabTestsPage> {
  List<dynamic> labTests = [];
  DateTime? _selectedDate;
  final TextEditingController _testDateController = TextEditingController();

    @override
  void initState() {
    super.initState();
    // Sample lab tests for testing purposes
    labTests = [
      {
        'testName': 'Blood Test',
        'testDate': '2024-11-01',
        'testResult': 'Normal',
      },
      {
        'testName': 'X-Ray',
        'testDate': '2024-11-15',
        'testResult': 'Abnormal',
      },
    ];
  }

 
  Future<void> updateLabTest(int index, Map<String, dynamic> updatedItem) async {
    final userId = await storage.read(key: 'userid');
    if (userId != null) {
      final response = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/users/$userId/labtests/${updatedItem['_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedItem),
      );
      if (response.statusCode == 200) {
        setState(() {
          labTests[index] = updatedItem;
        });
      } else {
        print("Failed to update: ${response.statusCode}");
      }
    }
  }

void showEditDialog(int index) {
  final item = labTests[index];
  final nameController = TextEditingController(text: item['testName']);
  final resultController = TextEditingController(text: item['testResult']);
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode resultFocusNode = FocusNode();

  // Set the test date in the controller if it exists
  _testDateController.text = item['testDate'] ?? '';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Lab Test", style: TextStyle(color: Color(0xff613089))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                focusNode: nameFocusNode,
                decoration: InputDecoration(
                  labelText: "Test Name",
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  prefixIcon: Icon(Icons.science, color: Color(0xff613089)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089)),
                  ),
                ),
              ),
              TextField(
                controller: resultController,
                focusNode: resultFocusNode,
                decoration: InputDecoration(
                  labelText: "Test Result",
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  prefixIcon: Icon(Icons.check_circle, color: Color(0xff613089)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _testDateController,
                    decoration: InputDecoration(
                      labelText: "Test Date",
                      labelStyle: const TextStyle(color: Color(0xff613089)),
                      prefixIcon: Icon(Icons.calendar_today, color: Color(0xff613089)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff613089)),
                      ),
                    ),
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
                'testName': nameController.text,
                'testDate': _testDateController.text,
                'testResult': resultController.text,
              };
              updateLabTest(index, updatedItem);
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


  Future<void> _selectDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Test Date', style: TextStyle(color: Color(0xff613089))),
          content: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _selectedDate ?? DateTime.now(),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _testDateController.text = "${selectedDay.toLocal()}".split(' ')[0];
                      });
                      Navigator.of(context).pop();
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xffb41391),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color(0xff613089),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(color: Color(0xff613089), fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteLabTest(int index) async {
  setState(() {
    labTests.removeAt(index); 
  });

  final userId = await storage.read(key: 'userid');
  if (userId != null) {
    final itemId = labTests[index]['_id'];
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/users/$userId/labtests/$itemId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      print("Failed to delete lab test: ${response.statusCode}");
    }
  }
}


  void showAddDialog() {
    final nameController = TextEditingController();
    final resultController = TextEditingController();
    final FocusNode nameFocusNode = FocusNode();
    final FocusNode resultFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add New Lab Test", style: TextStyle(color: Color(0xff613089))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  decoration: InputDecoration(
                    labelText: "Test Name",
                    labelStyle: const TextStyle(color: Color(0xff613089)),
                    prefixIcon: Icon(Icons.science, color: Color(0xff613089)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff613089)),
                    ),
                  ),
                ),
                TextField(
                  controller: resultController,
                  focusNode: resultFocusNode,
                  decoration: InputDecoration(
                    labelText: "Test Result",
                    labelStyle: const TextStyle(color: Color(0xff613089)),
                    prefixIcon: Icon(Icons.check_circle, color: Color(0xff613089)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff613089)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _testDateController,
                      decoration: InputDecoration(
                        labelText: "Test Date",
                        labelStyle: const TextStyle(color: Color(0xff613089)),
                        prefixIcon: Icon(Icons.calendar_today, color: Color(0xff613089)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff613089)),
                        ),
                      ),
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
                  'testName': nameController.text,
                  'testDate': _testDateController.text,
                  'testResult': resultController.text,
                };
                setState(() {
                  labTests.add(newItem);
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

Widget buildLabTestCard(Map<String, dynamic> item, int index) {
  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: EdgeInsets.symmetric(vertical: 10),
    elevation: 8,
    shadowColor: Color(0xff613089).withOpacity(0.5),
    child: ListTile(
      title: Text(
        "Test Name: ${item['testName']}",
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff613089)),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Test Date: ${item['testDate']}", style: TextStyle(fontSize: 14)),
          Text("Result: ${item['testResult']}", style: TextStyle(fontSize: 14)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xff613089)),
            onPressed: () => showEditDialog(index),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Color(0xff613089)),
            onPressed: () => deleteLabTest(index),
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
          "Lab Tests",
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
                itemCount: labTests.length + 1, // +1 for the Add button
                itemBuilder: (context, index) {
                  if (index < labTests.length) {
                    return buildLabTestCard(labTests[index], index);
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
                          "Add New Lab Test",
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
