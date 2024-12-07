import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

import 'package:table_calendar/table_calendar.dart';

final storage = FlutterSecureStorage();

class MedicalHistoryPage extends StatefulWidget {
  @override
  _MedicalHistoryPageState createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
   List<Map<String, String>> medicalHistory = [
    {
      'conditionName': 'Diabetes',
      'conditionDetails': 'Diagnosed with Type 2 Diabetes.',
      'diagnosisDate': '2023-05-12',
    },
    {
      'conditionName': 'Hypertension',
      'conditionDetails': 'Diagnosed with high blood pressure.',
      'diagnosisDate': '2022-11-05',
    },
  ];
  DateTime? _selectedDate;
  final TextEditingController _diagnosisDateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  
 

 void showEditDialog(int index) {
  final item = medicalHistory[index];
  final conditionController = TextEditingController(text: item['conditionName']);
  final detailsController = TextEditingController(text: item['conditionDetails']);
  final FocusNode conditionFocusNode = FocusNode();
  final FocusNode detailsFocusNode = FocusNode();

  // Set the diagnosis date in the controller if it exists
  _diagnosisDateController.text = item['diagnosisDate'] ?? '';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Medical History", style: TextStyle(color: Color(0xff613089))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: conditionController,
                focusNode: conditionFocusNode,
                decoration: InputDecoration(
                  labelText: "Condition Name",
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  prefixIcon: Icon(Icons.medical_services, color: Color(0xff613089)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089)),
                  ),
                ),
              ),
              TextField(
                controller: detailsController,
                focusNode: detailsFocusNode,
                decoration: InputDecoration(
                  labelText: "Condition Details",
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  prefixIcon: Icon(Icons.notes, color: Color(0xff613089)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context), // Show date picker
                child: AbsorbPointer(
                  child: TextField(
                    controller: _diagnosisDateController,
                    decoration: InputDecoration(
                      labelText: "Diagnosis Date",
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
                'conditionName': conditionController.text,
                'diagnosisDate': _diagnosisDateController.text,
                'conditionDetails': detailsController.text,
              };
              
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
          title: const Text('Select Diagnosis Date',
              style: TextStyle(color: Color(0xff613089))),
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
                        _diagnosisDateController.text =
                            "${selectedDay.toLocal()}".split(' ')[0];
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
                      markerDecoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                      defaultDecoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleTextStyle:
                          TextStyle(color: Color(0xff613089), fontSize: 20),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Color(0xff613089)),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Color(0xff613089)),
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


void deleteMedicalHistory(int index) async {
  setState(() {
    medicalHistory.removeAt(index); 
  });

  final userId = await storage.read(key: 'userid');
  if (userId != null) {
    final itemId = medicalHistory[index]['_id'];
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/users/$userId/medicalhistory/$itemId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
    
      print("Failed to delete: ${response.statusCode}");
    }
  }
}



  void showAddDialog() {
    final conditionController = TextEditingController();
    final detailsController = TextEditingController();
    final FocusNode conditionFocusNode = FocusNode();
    final FocusNode detailsFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add New Medical History",
              style: TextStyle(color: Color(0xff613089))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: conditionController,
                  focusNode: conditionFocusNode,
                  decoration: InputDecoration(
                    labelText: "Condition Name",
                    labelStyle: const TextStyle(color: Color(0xff613089)),
                    prefixIcon:
                        Icon(Icons.medical_services, color: Color(0xff613089)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff613089)),
                    ),
                  ),
                ),
                TextField(
                  controller: detailsController,
                  focusNode: detailsFocusNode,
                  decoration: InputDecoration(
                    labelText: "Condition Details",
                    labelStyle: const TextStyle(color: Color(0xff613089)),
                    prefixIcon: Icon(Icons.notes, color: Color(0xff613089)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff613089)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context), // Show date picker
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _diagnosisDateController,
                      decoration: InputDecoration(
                        labelText: "Diagnosis Date",
                        labelStyle: const TextStyle(color: Color(0xff613089)),
                        prefixIcon: Icon(Icons.calendar_today,
                            color: Color(0xff613089)),
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
                  'conditionName': conditionController.text,
                  'diagnosisDate': _diagnosisDateController.text,
                  'conditionDetails': detailsController.text,
                };
                setState(() {
                  medicalHistory.add(newItem);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff613089),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Widget buildMedicalHistoryCard(Map<String, dynamic> item, int index) {
  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: EdgeInsets.symmetric(vertical: 10),
    elevation: 8,
    shadowColor: Color(0xff613089).withOpacity(0.5),
    child: ListTile(
      title: Text(
        "Condition: ${item['conditionName']}",
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff613089)),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Diagnosis Date: ${item['diagnosisDate']}",
              style: TextStyle(fontSize: 14)),
          Text("Details: ${item['conditionDetails']}",
              style: TextStyle(fontSize: 14)),
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
            onPressed: () => deleteMedicalHistory(index),
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
        "Medical History",
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
              itemCount: medicalHistory.length + 1, // +1 for the Add button
              itemBuilder: (context, index) {
                if (index < medicalHistory.length) {
                  // Return each medical history card
                  return buildMedicalHistoryCard(medicalHistory[index], index);
                } else {
                  // Return the Add New Medical History button at the end
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
                        "Add New Medical History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
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
