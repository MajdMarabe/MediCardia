import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/admin_home.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:flutter_application_3/screens/statistics.dart';
import 'package:flutter_application_3/screens/welcome_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class ManageDrugsPage extends StatefulWidget {
  const ManageDrugsPage({Key? key}) : super(key: key);

  @override
  _ManageDrugsPageState createState() => _ManageDrugsPageState();
}

class _ManageDrugsPageState extends State<ManageDrugsPage> {
  List<Map<String, dynamic>> drugs = [];
int number =0;
  @override
  void initState() {
    super.initState();
    _fetchDrugs();
  }

  Future<void> _fetchDrugs() async {
    final url = '${ApiConstants.baseUrl}/drugs';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> drugList = json.decode(response.body)['drugs'];
        setState(() {
          number=json.decode(response.body)['drugnum'];
          drugs = drugList.map((drug) {
            final details = drug['details'][0];
            return {
              'id': drug['_id'],
              'name': drug['Drugname'],
              'barcode': drug['Barcode'],
              'use': details['Use'],
              'dose': details['Dose'],
              'time': details['Time'],
              'notes': details['Notes'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load drugs');
      }
    } catch (e) {
      print("Error fetching drugs: $e");
    }
  }

  Future<void> _deleteDrug(String id, int index) async {
    final url = '${ApiConstants.baseUrl}/drugs/$id';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          drugs.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drug deleted')),
        );
      } else {
        throw Exception('Failed to delete drug');
      }
    } catch (e) {
      print("Error deleting drug: $e");
    }
  }

  Future<void> _updateDrug(String id, Map<String, dynamic> updatedDrug, int index) async {
    final url = '${ApiConstants.baseUrl}/drugs/$id';
    try {
      final response = await http.put(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'Drugname': updatedDrug['name'],
            'Barcode': updatedDrug['barcode'],
            'details': [
              {
                'Use': updatedDrug['use'],
                'Dose': updatedDrug['dose'],
                'Time': updatedDrug['time'],
                'Notes': updatedDrug['notes'],
              }
            ]
          }));

      if (response.statusCode == 200) {
        setState(() {
          drugs[index] = updatedDrug;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Drug updated: ${updatedDrug['name']}')),
        );
      } else {
        throw Exception('Failed to update drug');
      }
    } catch (e) {
      print("Error updating drug: $e");
    }
  }

  // Function to handle log out
Future<void> _logOut() async {
  // Add your logout logic here (e.g., clearing user session, etc.)
  try {
    await storage.deleteAll(); // Clears all stored keys and values
    print('Storage cleared successfully.');
    await FirebaseMessaging.instance.deleteToken();

    // Navigate the user back to the welcome or login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  } catch (e) {
    print('Error clearing storage: $e');
  }
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully!")),
    );
  }
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Row(
      children: [
        Sidebar(onLogout: _logOut),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Manage Drugs",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      
                    ],
                  ),
                    const SizedBox(height: 20),
             Center(
              
  child: Row(
    
    mainAxisAlignment: MainAxisAlignment.center, 
    
    children: [
       const SizedBox(width: 500),
      InfoCard(
        title: "Drugs Number",
        value: number.toString(),
        icon: FontAwesomeIcons.capsules,
        iconColor: const Color(0xff613089),
      ),
      const Spacer(), 
      ElevatedButton(
        onPressed: () {
          _showAddDrugDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff6A1B9A),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline, 
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              "Add New Drug",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    ],
  ),
),

                  const SizedBox(height: 16),
                  drugs.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: drugs.length,
                          itemBuilder: (context, index) {
                            final drug = drugs[index];
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xff613089),
                                  child: Icon(FontAwesomeIcons.capsules, color: Colors.white),
                                ),
                                title: Text(
                                  drug['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  'Barcode: ${drug['barcode']}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                trailing: PopupMenuButton<String>(
                                
                                  icon: const Icon(Icons.more_vert, color: Color(0xff6A1B9A)),
                                  onSelected: (value) {
                                    if (value == 'Edit') {
                                      _showEditDrugDialog(context, drug, index);
                                    } else if (value == 'Delete') {
                                      _deleteDrug(drug['id'], index);
                                    }else if (value == 'Details') {
                                      _showDrugDetailsDialog(context, drug);
                                    }
                                  },

                                  itemBuilder: (context) => [
                                   const PopupMenuItem(
                                        value: 'Edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: Color(0xff6A1B9A)),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                     const PopupMenuItem(
                                        value: 'Delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Color(0xff6A1B9A)),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'Details',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info, color: Color(0xff6A1B9A)),
                                            SizedBox(width: 8),
                                            Text('Details'),
                                          ],
                                        ),
                                      ),
                                  ],
                                   color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
      ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
        //SidePanel(onDateRangeSelected: (startDate, endDate) {}),
      ],
    ),
  );
}


  void _showDrugDetailsDialog(BuildContext context, Map<String, dynamic> drug) {
    showDialog(
      context: context,
       builder: (context) {
           double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9; 
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 5,
          child: Container(
             width: dialogWidth, 
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${drug['name']} Details',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff6A1B9A)),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Use:', drug['use'] ?? 'N/A'),
                _buildDetailRow('Dose:', drug['dose'] ?? 'N/A'),
                _buildDetailRow('Time:', drug['time'] ?? 'N/A'),
                _buildDetailRow('Notes:', drug['notes'] ?? 'N/A'),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6A1B9A),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 16),
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
  Future<void> _addDrug(Map<String, dynamic> newDrug) async {
  final url = '${ApiConstants.baseUrl}/drugs/admin';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'Drugname': newDrug['name'],
        'Barcode': newDrug['barcode'],
        'Use': newDrug['use'],
        'Dose': newDrug['dose'],
        'Time': newDrug['time'],
        'Notes': newDrug['notes'],
      }),
    );

    if (response.statusCode == 201) {
      final addedDrug = json.decode(response.body)['drug'];
      setState(() {
        drugs.add({
          'id': addedDrug['_id'],
          'name': addedDrug['Drugname'],
          'barcode': addedDrug['Barcode'],
          'use': addedDrug['details'][0]['Use'],
          'dose': addedDrug['details'][0]['Dose'],
          'time': addedDrug['details'][0]['Time'],
          'notes': addedDrug['details'][0]['Notes'],
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drug added successfully')),
      );
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } else {
      throw Exception('Failed to add drug');
    }
  } catch (e) {
    print("Error adding drug: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error adding the drug')),
    );
  }
}


  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff6A1B9A), fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }



 void _showEditDrugDialog(BuildContext context, Map<String, dynamic> drug, int index) {
  final TextEditingController nameController = TextEditingController(text: drug['name']);
  final TextEditingController barcodeController = TextEditingController(text: drug['barcode']);
  final TextEditingController useController = TextEditingController(text: drug['use']);
  final TextEditingController doseController = TextEditingController(text: drug['dose']);
  final TextEditingController timeController = TextEditingController(text: drug['time']);
  final TextEditingController notesController = TextEditingController(text: drug['notes']);

  showDialog(
    context: context,
    builder: (context) {
  double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9; 
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Drug',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff6A1B9A),
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(controller: nameController, label: 'Drug Name', hint: 'Please enter drug name'),
                const SizedBox(height: 10),
            _buildTextField(controller: barcodeController, label: 'Barcode', hint: 'Please enter barcode'),
                const SizedBox(height: 10),
                _buildTextField(controller: useController, label: 'Use', hint: 'Please enter use'),
                const SizedBox(height: 10),
                _buildTextField(controller: doseController, label: 'Dose', hint: 'Please enter dose'),
                const SizedBox(height: 10),
                _buildTextField(controller: timeController, label: 'Time', hint: 'Please enter time'),
                const SizedBox(height: 10),
                _buildTextField(controller: notesController, label: 'Notes', hint: 'Please enter notes'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedDrug = {
                'id': drug['id'],
                'name': nameController.text,
                'barcode': barcodeController.text,
                'use': useController.text,
                'dose': doseController.text,
                'time': timeController.text,
                'notes': notesController.text,
              };
              _updateDrug(drug['id'], updatedDrug, index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6A1B9A),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      );
    },
  );
}




void _showAddDrugDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController useController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9;
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Add New Drug',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff6A1B9A),
          ),
        ),
        content: SizedBox(
          width: dialogWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(controller: nameController, label: 'Drug Name', hint: 'Please enter drug name'),
                const SizedBox(height: 10),
                _buildTextField(controller: barcodeController, label: 'Barcode', hint: 'Please enter barcode'),
                const SizedBox(height: 10),
                _buildTextField(controller: useController, label: 'Use', hint: 'Please enter use'),
                const SizedBox(height: 10),
                _buildTextField(controller: doseController, label: 'Dose', hint: 'Please enter dose'),
                const SizedBox(height: 10),
                _buildTextField(controller: timeController, label: 'Time', hint: 'Please enter time'),
                const SizedBox(height: 10),
                _buildTextField(controller: notesController, label: 'Notes', hint: 'Please enter notes'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
                      onPressed: () {
                        final newDrug = {
                          'name': nameController.text,
                          'barcode': barcodeController.text,
                          'use': useController.text,
                          'dose': doseController.text,
                          'time': timeController.text,
                          'notes': notesController.text,
                        };
                        _addDrug(newDrug);
                        Navigator.pop(context);
                      },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6A1B9A),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}




Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  String? hint,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
      labelStyle: const TextStyle(color: Color(0xff6A1B9A)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    ),
  );
}


}
