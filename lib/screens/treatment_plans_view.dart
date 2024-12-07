import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class TreatmentPlansPage extends StatefulWidget {
  @override
  _TreatmentPlansPageState createState() => _TreatmentPlansPageState();
}

class _TreatmentPlansPageState extends State<TreatmentPlansPage> {
  List<dynamic> treatmentPlans = [];

  @override
  void initState() {
    super.initState();
    fetchTreatmentPlans();
  }

  Future<void> fetchTreatmentPlans() async {
    try {
      final userId = await storage.read(key: 'userid');
      if (userId != null) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/users/Gettreatmentplans/$userId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            treatmentPlans = data['treatmentPlans'] ?? [];
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
Future<void> addTreatmentPlan(List<Map<String, dynamic>> newTreatmentPlans) async {
  final userId = await storage.read(key: 'userid');

  if (userId != null) {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/addTreatmentPlan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userid': userId,
          'treatmentPlans': newTreatmentPlans, // Send the new treatment plans
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          treatmentPlans = data['treatmentPlans']; // Update the treatmentPlans list with the new data
        });
        print('Treatment plan added successfully');
      } else {
        print("Failed to add treatment plan: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding treatment plan: $e");
    }
  }
}

Future<void> deleteTreatmentPlan(int index) async {
  // Retrieve the treatment plan item to delete
  final item = treatmentPlans[index]; 

  // Update the UI by removing the item locally
  setState(() {
    treatmentPlans.removeAt(index); 
  });

  // Retrieve the user ID from secure storage
  final userId = await storage.read(key: 'userid'); 
  final itemId = {
    'entryId': item['_id'], // Payload containing the treatment plan ID
  };

  // Ensure the user ID is not null
  if (userId != null) {
    try {
      // Make the DELETE request
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/treatmentplans'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(itemId), // Send the item ID as JSON-encoded body
      );

      if (response.statusCode == 200) {
        print('Treatment plan deleted successfully');
      } else {
        print("Failed to delete treatment plan: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting treatment plan: $e");
    }
  }
}

  void showAddDialog({Map<String, dynamic>? treatmentPlan, int? index}) {
    final medicationsController = TextEditingController(text: treatmentPlan?['prescribedMedications'] ?? '');
    final durationController = TextEditingController(text: treatmentPlan?['treatmentDuration'] ?? '');
    final goalsController = TextEditingController(text: treatmentPlan?['treatmentGoals'] ?? '');
    final therapiesController = TextEditingController(text: treatmentPlan?['alternativeTherapies'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            treatmentPlan == null ? "Add New Treatment Plan" : "Edit Treatment Plan",
            style: TextStyle(color: Color(0xff613089)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Prescribed Medications", medicationsController, Icons.medication),
                _buildTextField("Treatment Duration", durationController, Icons.timelapse),
                _buildTextField("Treatment Goals", goalsController, Icons.flag),
                _buildTextField("Additional Notes", therapiesController, Icons.alternate_email),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
          ElevatedButton(
  onPressed: () async {
    final updatedPlan = {
      'prescribedMedications': medicationsController.text,
      'treatmentDuration': durationController.text,
      'treatmentGoals': goalsController.text,
      'alternativeTherapies': therapiesController.text,
    };

    if (treatmentPlan == null) {
      // Add new treatment plan
      setState(() {
        treatmentPlans.add(updatedPlan);
      });

      // Call the API to add the treatment plan
      await addTreatmentPlan([updatedPlan]);
    } else {
      // Edit existing treatment plan
      setState(() {
        treatmentPlans[index!] = updatedPlan;
      });

      // Optionally call an update API if required
      // await updateTreatmentPlan(updatedPlan, index!);
    }

    Navigator.pop(context);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xff613089),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  ),
  child: Text(treatmentPlan == null ? "Add" : "Save"),
),

          ],
        );
      },
    );
  }
  
  void showEditDialog({Map<String, dynamic>? treatmentPlan, int? index}) {
    final medicationsController = TextEditingController(text: treatmentPlan?['prescribedMedications'] ?? '');
    final durationController = TextEditingController(text: treatmentPlan?['treatmentDuration'] ?? '');
    final goalsController = TextEditingController(text: treatmentPlan?['treatmentGoals'] ?? '');
    final therapiesController = TextEditingController(text: treatmentPlan?['alternativeTherapies'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
           "Edit Treatment Plan",
            style: TextStyle(color: Color(0xff613089)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Prescribed Medications", medicationsController, Icons.medication),
                _buildTextField("Treatment Duration", durationController, Icons.timelapse),
                _buildTextField("Treatment Goals", goalsController, Icons.flag),
                _buildTextField("Additional Notes", therapiesController, Icons.alternate_email),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
          ElevatedButton(
  onPressed: () async {
  final updatedPlan = {
    'prescribedMedications': medicationsController.text,
    'treatmentDuration': durationController.text,
    'treatmentGoals': goalsController.text,
    'alternativeTherapies': therapiesController.text,
  };

  if (treatmentPlan != null) {
    // If editing an existing treatment plan
    await editTreatmentPlan(updatedPlan, index!);
  } else {
    // Handle adding a new treatment plan (if applicable)
    await addTreatmentPlan([updatedPlan]);
  }

  Navigator.pop(context); // Close the dialog after saving
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
Future<void> editTreatmentPlan(Map<String, dynamic> updatedPlan, int index) async {
  final userId = await storage.read(key: 'userid'); // Get the user ID from secure storage
  final planId = treatmentPlans[index]['_id']; // Assuming each plan has a unique '_id'

  if (userId != null && planId != null) {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/treatmentPlans/$planId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'updatedPlan': updatedPlan,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          treatmentPlans[index] = data['updatedPlan']; // Update the local treatmentPlans list
        });
        print('Treatment plan updated successfully');
      } else {
        print('Failed to update treatment plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating treatment plan: $e');
    }
  }
}

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xff613089)),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xff613089)),
        ),
        labelStyle: TextStyle(color: Color(0xff613089)),
      ),
    );
  }

Widget buildTreatmentPlanCard(Map<String, dynamic> item, int index) {
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
        // Leading Icon: Treatment Plan Icon
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

        // Treatment Plan Details Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prescribed Medications
              Text(
                "Medications: ${item['prescribedMedications']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff4A148C),
                ),
              ),
              SizedBox(height: 8),
              
              // Treatment Duration
              Text(
                "Duration: ${item['treatmentDuration']}",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),

              // Treatment Goals
              Text(
                "Goals: ${item['treatmentGoals']}",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),

              // Additional Notes
              Text(
                "Additional Notes: ${item['alternativeTherapies']}",
                style: TextStyle(fontSize: 14),
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
              onPressed: () => showEditDialog(treatmentPlan: item, index: index),
              tooltip: 'Edit Treatment Plan',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteTreatmentPlan(index),
              tooltip: 'Delete Treatment Plan',
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
          icon: const Icon(Icons.arrow_back, color: Color(0xff613089)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Treatment Plans",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
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
                itemCount: treatmentPlans.length + 1, // +1 for the Add button
                itemBuilder: (context, index) {
                  if (index < treatmentPlans.length) {
                    return buildTreatmentPlanCard(treatmentPlans[index], index);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: TextButton(
                        onPressed: () => showAddDialog(),
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xff613089),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        ),
                        child: Text(
                          "Add New Treatment Plan",
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
