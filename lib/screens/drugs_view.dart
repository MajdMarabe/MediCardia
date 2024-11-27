import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class MedicineListPage extends StatefulWidget {
  @override
  _MedicineListPageState createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  String? userId;
  List<Map<String, dynamic>> drugs = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  // Fetch User ID from Secure Storage
  Future<void> _getUserId() async {
    userId = await storage.read(key: 'userid');
    if (userId != null) {
      _fetchDrugs(); // Fetch drugs once User ID is available
    }
  }

  // Fetch Drugs for the User
  Future<void> _fetchDrugs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/getUserDrugs'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fetchedDrugs = data['drugs'];

        setState(() {
          drugs = fetchedDrugs.map((drug) {
            final details = drug['details'] as List<dynamic>;
            final detail = details.isNotEmpty ? details[0] : null;

            return {
              'name': drug['Drugname'] ?? '',
              'barcode': drug['Barcode'] ?? '',
              'use': detail?['Use'] ?? 'No use information',
              'dose': detail?['Dose'] ?? 'No dose information',
              'time': detail?['Time'] ?? 'No timing information',
              'notes': detail?['Notes'] ?? 'No additional notes',
            };
          }).toList();
        });
      } else {
        _showMessage('Failed to fetch drugs: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  // Add Drug for the User
  Future<void> _addDrug(String drugName) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/adddrugs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'drugName': drugName}),
      );
      if (response.statusCode == 200) {
        _showMessage('Drug added successfully');
        _fetchDrugs(); // Refresh the drug list
      } else {
        _showMessage('Failed to add drug: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  // Delete Drug for the User
  Future<void> _deleteDrug(String drugName) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/deletedrugs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'drugName': drugName}),
      );
      if (response.statusCode == 200) {
        _showMessage('Drug deleted successfully');
        _fetchDrugs(); // Refresh the drug list
      } else {
        _showMessage('Failed to delete drug: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  // Show a message (Snackbar)
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Show the Add Drug Dialog
  void _showAddDrugDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a New Drug'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Drug Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addDrug(nameController.text);
                  nameController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Show Drug Details in a Dialog
  void _showDrugDetailsDialog(Map<String, dynamic> drug) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(drug['name'] ?? 'Unknown Drug'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Use: ${drug['use']}"),
              Text("Dose: ${drug['dose']}"),
              Text("Time: ${drug['time']}"),
              Text("Notes: ${drug['notes']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines'),
        backgroundColor: const Color(0xff613089),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search drugs...',
                prefixIcon: const Icon(Icons.search, color: Color(0xff613089)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xff613089), width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  drugs = drugs
                      .where((drug) => drug['name']!
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: drugs.isNotEmpty
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: drugs.length,
                    itemBuilder: (context, index) {
                      final drug = drugs[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Column(
                          children: [
                            // Placeholder Image or Icon
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(
                                Icons.medical_services, // You can add custom icons here
                                size: 40,
                                color: Color(0xff613089),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Drug Name
                                  Text(
                                    drug['name'] ?? 'Unknown Drug',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Drug Dose and Count
                                  Text(
                                    '${drug['dose']} / ${drug['time']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  // Delete Button
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteDrug(drug['name'] ?? '');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Open the details dialog when a card is clicked
                                _showDrugDetailsDialog(drug);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Color(0xff613089),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No drugs available')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDrugDialog,
        backgroundColor: const Color(0xff613089),
        child: const Icon(Icons.add),
      ),
    );
  }
}
