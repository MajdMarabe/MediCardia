import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'constants.dart';

const storage = FlutterSecureStorage();

class LabTestsPage extends StatefulWidget {
  final String patientId;
  const LabTestsPage({Key? key, required this.patientId}) : super(key: key);
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
    fetchLabTests();
  }

  Future<void> fetchLabTests() async {
    try {
      final userId =widget.patientId;
      if (userId != null) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/users/$userId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            labTests = data['medicalCard']['privateData']['labTests'] ?? [];
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

  Future<void> updateLabTest(
      int index, Map<String, dynamic> updatedItem) async {
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

  Future<void> addLabTests(List<Map<String, dynamic>> newLabTests) async {
    final userId = await storage.read(key: 'userid');

    if (userId != null) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/users/labtests'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userid': userId,
            'labTests': newLabTests,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            labTests = data['labTests'];
          });
          print('Lab tests added successfully');
        } else {
          print("Failed to add lab tests: ${response.statusCode}");
        }
      } catch (e) {
        print("Error adding lab tests: $e");
      }
    }
  }

  Future<void> deleteLabTest(int index) async {
    final item = labTests[index];
    final itemId = item['_id'];
    setState(() {
      labTests.removeAt(index);
    });

    final userId = await storage.read(key: 'userid');

    if (userId != null) {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/labtests'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'entryId': itemId}),
      );

      if (response.statusCode == 200) {
        print('Lab test deleted successfully');
      } else {
        print("Failed to delete lab test: ${response.statusCode}");
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Test Date',
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
                        _testDateController.text =
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
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleTextStyle:
                          TextStyle(color: Color(0xff613089), fontSize: 20),
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

/////////////////////////////////////

  void showEditDialog(int index) {
    final item = labTests[index];
    final nameController = TextEditingController(text: item['testName']);
    final resultController = TextEditingController(text: item['testResult']);
    final FocusNode nameFocusNode = FocusNode();
    final FocusNode resultFocusNode = FocusNode();

    _testDateController.text =
        item['testDate'] != null ? formatDate(item['testDate']) : '';

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
                    "Edit Lab Test",
                    style: TextStyle(color: Color(0xff613089), fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            focusNode: nameFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Test Name",
                              labelStyle: TextStyle(color: Color(0xff613089)),
                              prefixIcon:
                                  Icon(Icons.science, color: Color(0xff613089)),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff613089)),
                              ),
                            ),
                          ),
                          TextField(
                            controller: resultController,
                            focusNode: resultFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Test Result",
                              labelStyle: TextStyle(color: Color(0xff613089)),
                              prefixIcon: Icon(Icons.check_circle,
                                  color: Color(0xff613089)),
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
                                controller: _testDateController,
                                decoration: const InputDecoration(
                                  labelText: "Test Date",
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
                            'testName': nameController.text,
                            'testDate': _testDateController.text,
                            'testResult': resultController.text,
                          };
                          updateLabTest(index, updatedItem);
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
    final nameController = TextEditingController();
    final resultController = TextEditingController();
    final FocusNode nameFocusNode = FocusNode();
    final FocusNode resultFocusNode = FocusNode();
    _testDateController.text = '';

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
                    "Add New Lab Test",
                    style: TextStyle(color: Color(0xff613089), fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            focusNode: nameFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Test Name",
                              labelStyle: TextStyle(color: Color(0xff613089)),
                              prefixIcon:
                                  Icon(Icons.science, color: Color(0xff613089)),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff613089)),
                              ),
                            ),
                          ),
                          TextField(
                            controller: resultController,
                            focusNode: resultFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Test Result",
                              labelStyle: TextStyle(color: Color(0xff613089)),
                              prefixIcon: Icon(Icons.check_circle,
                                  color: Color(0xff613089)),
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
                                controller: _testDateController,
                                decoration: const InputDecoration(
                                  labelText: "Test Date",
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
                          final newItem = {
                            'testName': nameController.text,
                            'testDate': _testDateController.text,
                            'testResult': resultController.text,
                          };

                          setState(() {
                            labTests.add(newItem);
                          });

                          addLabTests([newItem]);
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

////////////////////////

  Widget buildLabTestCard(Map<String, dynamic> item, int index) {
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
              border:
                  Border.all(color: const Color(0xff613089).withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['testName'] ?? "Unknown Test",
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
                            deleteLabTest(index);
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
                    const Icon(Icons.calendar_today,
                        size: 16, color: Color(0xff613089)),
                    const SizedBox(width: 5),
                    Text(
                      "Date: ${formatDate(item['testDate'])}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: Color(0xff613089)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "Result: " +
                            (item['testResult'] ?? "No result provided."),
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

//////////////////////////////////////////////

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
                'Lab Tests',
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
                'Lab Tests',
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
                itemCount: labTests.length + 1,
                itemBuilder: (context, index) {
                  if (index < labTests.length) {
                    return buildLabTestCard(labTests[index], index);
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
                                "Add New Lab Test",
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
