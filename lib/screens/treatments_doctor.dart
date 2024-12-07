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
  //List<dynamic> treatmentPlans = [];
  List<dynamic> treatmentPlans = [
    {
      'prescribedMedications': 'Aspirin, Ibuprofen',
      'treatmentDuration': '2 weeks',
      'treatmentGoals': 'Pain relief, Reduce inflammation',
      'alternativeTherapies': 'Massage therapy',
    },
    {
      'prescribedMedications': 'Paracetamol, Antibiotics',
      'treatmentDuration': '1 week',
      'treatmentGoals': 'Infection control, Fever reduction',
      'alternativeTherapies': 'Hydration, Bed rest',
    },
  ];

  @override
  void initState() {
    super.initState();
    
  }

 
  Future<void> deleteTreatmentPlan(int index) async {
    try {
      setState(() {
            treatmentPlans.removeAt(index);
          });
      final userId = await storage.read(key: 'userid');
      if (userId != null) {
        final treatmentPlanId = treatmentPlans[index]['_id'];
        final response = await http.delete(
          Uri.parse('${ApiConstants.baseUrl}/users/$userId/treatmentplans/$treatmentPlanId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          
        } else {
          print("Failed to delete: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error deleting treatment plan: $e");
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
              onPressed: () {
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
                } else {
                  // Edit existing treatment plan
                  setState(() {
                    treatmentPlans[index!] = updatedPlan;
                  });
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
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shadowColor: Color(0xff613089).withOpacity(0.5),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Medications: ${item['prescribedMedications']}", style:TextStyle(
              color: Color(0xff613089),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
            Text("Duration: ${item['treatmentDuration']}", ),
            Text("Goals: ${item['treatmentGoals']}", ),
            Text("Additional Notes: ${item['alternativeTherapies']}", ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xff613089)),
              onPressed: () {
                showAddDialog(treatmentPlan: item, index: index);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Color(0xff613089)),
              onPressed: () {
                deleteTreatmentPlan(index); // Delete treatment plan
              },
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
