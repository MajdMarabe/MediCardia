import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

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



/////////////////////////////////////


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



////////////////////////////



 void showAddDialog({Map<String, dynamic>? treatmentPlan, int? index}) {
  final medicationsController = TextEditingController(text: treatmentPlan?['prescribedMedications'] ?? '');
  final durationController = TextEditingController(text: treatmentPlan?['treatmentDuration'] ?? '');
  final goalsController = TextEditingController(text: treatmentPlan?['treatmentGoals'] ?? '');
  final therapiesController = TextEditingController(text: treatmentPlan?['alternativeTherapies'] ?? '');

  showDialog(
    context: context,
    builder: (context) {
      double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9;

      double dialogHeight = MediaQuery.of(context).size.height > 900
          ? 350
          : MediaQuery.of(context).size.height * 0.5;

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
                Text(
                  treatmentPlan == null
                      ? "Add New Treatment Plan"
                      : "Edit Treatment Plan",
                  style: const TextStyle(color: Color(0xff613089), fontSize: 20),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: medicationsController,
                          decoration: const InputDecoration(
                            labelText: "Prescribed Medications",
                            labelStyle: TextStyle(color: Color(0xff613089)),
                            prefixIcon: Icon(Icons.medication, color: Color(0xff613089)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff613089)),
                            ),
                          ),
                        ),
                        TextField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: "Treatment Duration",
                            labelStyle: TextStyle(color: Color(0xff613089)),
                            prefixIcon: Icon(Icons.timelapse, color: Color(0xff613089)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff613089)),
                            ),
                          ),
                        ),
                        TextField(
                          controller: goalsController,
                          decoration: const InputDecoration(
                            labelText: "Treatment Goals",
                            labelStyle: TextStyle(color: Color(0xff613089)),
                            prefixIcon: Icon(Icons.flag, color: Color(0xff613089)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff613089)),
                            ),
                          ),
                        ),
                        TextField(
                          controller: therapiesController,
                          decoration: const InputDecoration(
                            labelText: "Additional Notes",
                            labelStyle: TextStyle(color: Color(0xff613089)),
                            prefixIcon: Icon(Icons.alternate_email, color: Color(0xff613089)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff613089)),
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
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
                          setState(() {
                            treatmentPlans.add(updatedPlan);
                          });
                          await addTreatmentPlan([updatedPlan]);
                        } else {
                          setState(() {
                            treatmentPlans[index!] = updatedPlan;
                          });
                          // Uncomment if API call for update is needed
                          // await updateTreatmentPlan(updatedPlan, index!);
                        }

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff613089),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(treatmentPlan == null ? "Add" : "Save"),
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


 void showEditDialog(int index) {
  final treatmentPlan = treatmentPlans[index];
  final medicationsController = TextEditingController(text: treatmentPlan['prescribedMedications'] ?? '');
  final durationController = TextEditingController(text: treatmentPlan['treatmentDuration'] ?? '');
  final goalsController = TextEditingController(text: treatmentPlan['treatmentGoals'] ?? '');
  final therapiesController = TextEditingController(text: treatmentPlan['alternativeTherapies'] ?? '');

  showDialog(
    context: context,
    builder: (context) {
      double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9;

      double dialogHeight = MediaQuery.of(context).size.height > 900
          ? 350
          : MediaQuery.of(context).size.height * 0.5;

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
                  "Edit Treatment Plan",
                  style: TextStyle(color: Color(0xff613089), fontSize: 20),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: medicationsController,
                          decoration: const InputDecoration(
                            labelText: "Prescribed Medications",
                            labelStyle: TextStyle(color: Color(0xff613089)),
                            prefixIcon: Icon(Icons.medication, color: Color(0xff613089)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff613089)),
                            ),
                          ),
                        ),
                        TextField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: "Treatment Duration",
                            labelStyle: TextStyle(color: Color(0xff613089)),
                            prefixIcon: Icon(Icons.timelapse, color: Color(0xff613089)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff613089)),
                            ),
                          ),
                        ),
                        TextField(
                          controller: goalsController,
                          decoration: const InputDecoration(
                            labelText: "Treatment Goals",
                            labelStyle: TextStyle(color: Color(0xff613089)),
                            prefixIcon: Icon(Icons.flag, color: Color(0xff613089)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff613089)),
                            ),
                          ),
                        ),
                        TextField(
                          controller: therapiesController,
                          decoration: const InputDecoration(
                            labelText: "Additional Notes",
                            labelStyle: TextStyle(color: Color(0xff613089)),
                            prefixIcon: Icon(Icons.alternate_email, color: Color(0xff613089)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff613089)),
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedPlan = {
                          'prescribedMedications': medicationsController.text,
                          'treatmentDuration': durationController.text,
                          'treatmentGoals': goalsController.text,
                          'alternativeTherapies': therapiesController.text,
                        };

                        await editTreatmentPlan(updatedPlan, index);

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






  //////////////////



Widget buildTreatmentPlanCard(Map<String, dynamic> item, int index) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Adjust the card width based on screen size
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xffD1C4E9),
                child: Icon(
                  Icons.medication,
                  color: Color(0xff4A148C),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    Text(
                      "Medications: ${item['prescribedMedications']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff4A148C),
                      ),
                    ),
                    const SizedBox(height: 8),
                 
                    Text(
                      "Duration: ${item['treatmentDuration']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "Goals: ${item['treatmentGoals']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                   
                    Text(
                      "Additional Notes: ${item['alternativeTherapies']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Action Buttons (Edit, Delete)
          Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xff613089)),
      onSelected: (value) {
        if (value == 'edit') {
          showEditDialog(index);
        } else if (value == 'delete') {
          deleteTreatmentPlan(index);
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
)
            ],
          ),
        ),
      );
    },
  );
}



/////////////////////////////////


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
                'Treatments Plans',
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
                'Treatment Plans',
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
                itemCount: treatmentPlans.length + 1,
                itemBuilder: (context, index) {
                  if (index < treatmentPlans.length) {
                    return buildTreatmentPlanCard(treatmentPlans[index], index);
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
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            minimumSize: Size(buttonWidth, 50), 
          ),
          child: const Text(
            "Add New Treatment Plan",
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
