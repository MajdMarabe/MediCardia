import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'package:table_calendar/table_calendar.dart';

const storage = FlutterSecureStorage();

class MedicalHistoryPage extends StatefulWidget {
  
  @override
  _MedicalHistoryPageState createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  List<dynamic> medicalHistory = [];
  DateTime? _selectedDate;
  final TextEditingController _diagnosisDateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMedicalHistory();
  }

  Future<void> fetchMedicalHistory() async {
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
            medicalHistory =
                data['medicalCard']['privateData']['medicalHistory'] ?? [];
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

  Future<void> updateMedicalHistory(
      int index, Map<String, dynamic> updatedItem) async {
    final userId = await storage.read(key: 'userid');
    if (userId != null) {
      try {
        final response = await http.put(
          Uri.parse('${ApiConstants.baseUrl}/users/updateMedicalHistory'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userid': userId,
            'index': index,
            'updatedItem': updatedItem,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            medicalHistory =
                data['medicalHistory']; // Update the local medicalHistory list
          });
          print('Medical history updated successfully');
        } else {
          print("Failed to update medical history: ${response.statusCode}");
        }
      } catch (e) {
        print("Error updating medical history: $e");
      }
    }
  }

  Future<void> deleteMedicalHistory(int index) async {
    final item = medicalHistory[index]; // Retrieve the medical history item
    setState(() {
      medicalHistory
          .removeAt(index); // Update the UI by removing the item locally
    });

    final userId =
        await storage.read(key: 'userid'); // Read user ID from storage
    final itemId = {
      'entryId': item['_id'], // Create a payload with the item ID
    };

    if (userId != null) {
      try {
        final response = await http.delete(
          Uri.parse('${ApiConstants.baseUrl}/users/$userId/medicalhistory'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(itemId), // Send the item ID as a JSON-encoded body
        );

        if (response.statusCode == 200) {
          print('Medical history deleted successfully');
        } else {
          print("Failed to delete: ${response.statusCode}");
        }
      } catch (e) {
        print("Error deleting medical history: $e");
      }
    }
  }

  Future<void> addMedicalHistory(
      List<Map<String, dynamic>> newMedicalHistory) async {
    final userId = await storage.read(key: 'userid');

    if (userId != null) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/users/addMedicalHistory'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userid': userId,
            'medicalHistory': newMedicalHistory,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            medicalHistory = data['medicalHistory'];
          });
          print('Medical history added successfully');
        } else {
          print("Failed to add medical history: ${response.statusCode}");
        }
      } catch (e) {
        print("Error adding medical history: $e");
      }
    }
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

  String formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      print("Error parsing date: $e");
      return isoDate;
    }
  }

///////////////////////////////////

  void showEditDialog(int index) {
    final item = medicalHistory[index];
    final conditionController =
        TextEditingController(text: item['conditionName']);
    final detailsController =
        TextEditingController(text: item['conditionDetails']);
    final FocusNode conditionFocusNode = FocusNode();
    final FocusNode detailsFocusNode = FocusNode();

    _diagnosisDateController.text =
        item['diagnosisDate'] != null ? formatDate(item['diagnosisDate']) : '';

    showDialog(
      context: context,
      builder: (context) {
        double dialogWidth = MediaQuery.of(context).size.width > 600
            ? 500
            : MediaQuery.of(context).size.width * 0.9;

        double dialogHeight =
            MediaQuery.of(context).size.height >= 729.5999755859375
                ? 340
                : MediaQuery.of(context).size.height * 0.4;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Medical History",
                    style: TextStyle(color: Color(0xff613089), fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: conditionController,
                            focusNode: conditionFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Condition Name",
                              labelStyle: TextStyle(color: Color(0xff613089)),
                              prefixIcon: Icon(Icons.medical_services,
                                  color: Color(0xff613089)),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff613089)),
                              ),
                            ),
                          ),
                          TextField(
                            controller: detailsController,
                            focusNode: detailsFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Condition Details",
                              labelStyle: TextStyle(color: Color(0xff613089)),
                              prefixIcon:
                                  Icon(Icons.notes, color: Color(0xff613089)),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff613089)),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _selectDate(context), // Show date picker
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _diagnosisDateController,
                                decoration: const InputDecoration(
                                  labelText: "Diagnosis Date",
                                  labelStyle:
                                      TextStyle(color: Color(0xff613089)),
                                  prefixIcon: Icon(Icons.calendar_today,
                                      color: Color(0xff613089)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff613089)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final updatedItem = {
                            '_id': item['_id'],
                            'conditionName': conditionController.text,
                            'diagnosisDate': _diagnosisDateController.text,
                            'conditionDetails': detailsController.text,
                          };
                          updateMedicalHistory(index, updatedItem);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff613089),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showAddDialog() {
    final conditionController = TextEditingController();
    final detailsController = TextEditingController();
    final FocusNode conditionFocusNode = FocusNode();
    final FocusNode detailsFocusNode = FocusNode();
    _diagnosisDateController.text = '';

    showDialog(
      context: context,
      builder: (context) {
        double dialogWidth = MediaQuery.of(context).size.width > 600
            ? 600
            : MediaQuery.of(context).size.width * 0.9;

        double dialogHeight =
            MediaQuery.of(context).size.height >= 729.5999755859375
                ? 340
                : MediaQuery.of(context).size.height * 0.4;

        // print(MediaQuery.of(context).size.height);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add New Medical History",
                    style: TextStyle(color: Color(0xff613089), fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: conditionController,
                            focusNode: conditionFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Condition Name",
                              labelStyle: TextStyle(color: Color(0xff613089)),
                              prefixIcon: Icon(Icons.medical_services,
                                  color: Color(0xff613089)),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff613089)),
                              ),
                            ),
                          ),
                          TextField(
                            controller: detailsController,
                            focusNode: detailsFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Condition Details",
                              labelStyle: TextStyle(color: Color(0xff613089)),
                              prefixIcon:
                                  Icon(Icons.notes, color: Color(0xff613089)),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff613089)),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _diagnosisDateController,
                                decoration: const InputDecoration(
                                  labelText: "Diagnosis Date",
                                  labelStyle:
                                      TextStyle(color: Color(0xff613089)),
                                  prefixIcon: Icon(Icons.calendar_today,
                                      color: Color(0xff613089)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xff613089)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final newEntry = {
                            'conditionName': conditionController.text,
                            'diagnosisDate': _diagnosisDateController.text,
                            'conditionDetails': detailsController.text,
                          };

                          setState(() {
                            medicalHistory.add(newEntry);
                          });

                         await addMedicalHistory([newEntry]);
                         Navigator.pop(context); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff613089),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

Widget buildMedicalHistoryCard(Map<String, dynamic> item, int index) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double cardWidth = constraints.maxWidth > 600
          ? constraints.maxWidth * 0.6
          : constraints.maxWidth * 1;

      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(15),
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xff613089).withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['conditionName'] ?? "Unknown Condition",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                    ),
                  ),
                  Row(
                    children: [
                      PopupMenuButton<String>(
                        
                        icon: const Icon(Icons.more_vert, color: Color(0xff613089)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            showEditDialog(index);
                          } else if (value == 'delete') {
                            deleteMedicalHistory(index);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Color(0xff613089)),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Color(0xff613089)),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ];
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                      ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xff613089)),
                  const SizedBox(width: 5),
                  Text(
                    "Diagnosis Date: ${formatDate(item['diagnosisDate'])}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 16, color: Color(0xff613089)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      "Condition Details: " +
                          (item['conditionDetails'] ?? "No additional details provided."),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


/////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: kIsWeb
          ? AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Medical History',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                  letterSpacing: 1.5,
                ),
              ),
              automaticallyImplyLeading: false,
            )
          : AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Medical History',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                  letterSpacing: 1.5,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: medicalHistory.length + 1,
                itemBuilder: (context, index) {
                  if (index < medicalHistory.length) {
                    return buildMedicalHistoryCard(
                        medicalHistory[index], index);
                  } else {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        double buttonWidth = constraints.maxWidth > 600
                            ? constraints.maxWidth * 0.6
                            : constraints.maxWidth * 1;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: TextButton(
                              onPressed: showAddDialog,
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xff613089),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                minimumSize: Size(buttonWidth, 50),
                              ),
                              child: const Text(
                                "Add New Medical History",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
