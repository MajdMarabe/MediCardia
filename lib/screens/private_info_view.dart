import 'constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class PrivateDataPage extends StatefulWidget {
  @override
  _PrivateDataPageState createState() => _PrivateDataPageState();
}

class _PrivateDataPageState extends State<PrivateDataPage> {
  Map<String, dynamic>? privateData;

  @override
  void initState() {
    super.initState();
    fetchPrivateData();
  }

  Future<void> fetchPrivateData() async {
    try {
      final userId = await storage.read(key: 'userid');
      if (userId != null) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/users/$userId'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            privateData = data['medicalCard']['privateData'];
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

  Future<void> addItem(String section, Map<String, dynamic> newItem) async {
    final endpointMap = {
      'Medical History': 'medicalhistory',
      'Lab Tests': 'labtests',
      'Medical Notes': 'medicalNotes',
      'Treatment Plans': 'treatmentPlans',
    };

    final apiEndpoint = endpointMap[section];
    if (apiEndpoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid section: $section")),
      );
      return;
    }

    Map<String, dynamic> requestPayload = {
      apiEndpoint: [newItem],
    };
    String? userId = await storage.read(key: 'userid');
    try {
      String apiUrl = '${ApiConstants.baseUrl}/users/$userId/$apiEndpoint';
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestPayload),
      );

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        setState(() {
          privateData![section.toLowerCase()] = updatedData[section.toLowerCase()];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$section information updated successfully')),
        );
      } else {
        print('Failed to update: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update $section: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error updating $section: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
void showAddDialog(String section, List<String> fields, List<String> labels) {
  final controllers = List.generate(fields.length, (_) => TextEditingController());
  final Map<String, DateTime?> dateFields = {}; // To store selected dates

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Add New $section"),
        content: SingleChildScrollView(
          child: Column(
            children: List.generate(fields.length, (index) {
              if (fields[index].toLowerCase().contains("date")) {
                // Handle date fields with a date picker
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          dateFields[fields[index]] = selectedDate;
                          controllers[index].text = 
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: controllers[index],
                        decoration: InputDecoration(
                          labelText: labels[index],
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(labelText: labels[index]),
                );
              }
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final newItem = {
                for (int i = 0; i < fields.length; i++)
                  fields[i]: fields[i].toLowerCase().contains("date")
                      ? dateFields[fields[i]]?.toIso8601String() // Convert date to ISO string
                      : controllers[i].text,
              };
              addItem(section, newItem);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      );
    },
  );
}


  Widget buildSectionWithAddButton(
    String title,
    List<dynamic> data,
    List<String> fields,
    List<String> labels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(title),
        ...data.map((item) {
          return buildEditableCard(item, fields, labels);
        }).toList(),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () => showAddDialog(title, fields, labels),
            child: Text("Add New $title"),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget buildEditableCard(Map<String, dynamic> item, List<String> keys, List<String> labels) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(keys.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                initialValue: item[keys[index]].toString(),
                decoration: InputDecoration(
                  labelText: labels[index],
                  icon: const Icon(Icons.edit),
                ),
                onChanged: (value) {
                  setState(() {
                    item[keys[index]] = value;
                  });
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your MediCard Private Information"),
        backgroundColor: Colors.purple,
      ),
      body: privateData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  buildSectionWithAddButton(
                    "Medical History",
                    privateData!["medicalHistory"] ?? [],
                    ["conditionName", "diagnosisDate", "conditionDetails"],
                    ["Condition Name", "Diagnosis Date", "Condition Details"],
                  ),
                  buildSectionWithAddButton(
                    "Lab Tests",
                    privateData!["labTests"] ?? [],
                    ["testName", "testResult", "testDate"],
                    ["Test Name", "Test Result", "Test Date"],
                  ),
                  buildSectionWithAddButton(
                    "Medical Notes",
                    privateData!["medicalNotes"] ?? [],
                    ["note"],
                    ["Note"],
                  ),
                  buildSectionWithAddButton(
                    "Treatment Plans",
                    privateData!["treatmentPlans"] ?? [],
                    [
                      "prescribedMedications",
                      "treatmentDuration",
                      "treatmentGoals",
                      "alternativeTherapies"
                    ],
                    [
                      "Prescribed Medications",
                      "Treatment Duration",
                      "Treatment Goals",
                      "Alternative Therapies"
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
