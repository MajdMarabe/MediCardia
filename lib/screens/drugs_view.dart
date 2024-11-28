import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

// Show the Add Drug Dialog with a more creative design
void _showAddDrugDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Title with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Color(0xff613089),
                    size: 40,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Add a New Drug',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Drug Name Text Field with Custom Styling
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter drug name',
                  prefixIcon: Icon(  FontAwesomeIcons.capsules, color: Color(0xff613089)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xff613089), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xff613089),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Add Button
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        _addDrug(nameController.text);
                        nameController.clear();
                        Navigator.pop(context);
                      } else {
                        _showMessage('Please enter a drug name');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff613089),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    child: Text(
                      'Add Drug',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  // Function to build search section (full width)
  Widget buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 30, color: Color(0xff613089)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search drugs...',
                hintStyle: TextStyle(color: Colors.grey[400]),
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
        ],
      ),
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
          // Search Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildSearchSection(),
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
