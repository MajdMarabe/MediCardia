import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class PrivateInfo extends StatefulWidget {
   final String userId; // Accepting userId from the constructor

  const PrivateInfo({super.key, required this.userId});
  @override
  _PrivateInfoState createState() => _PrivateInfoState();
}

class _PrivateInfoState extends State<PrivateInfo> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Medical History section
  final TextEditingController _medicalConditionNameController = TextEditingController();
  final TextEditingController _diagnosisDateController = TextEditingController();
  final TextEditingController _medicalConditionDetailsController = TextEditingController();
  final TextEditingController _medicalNotesController = TextEditingController();

  // New controllers for treatment plans
  final TextEditingController _prescribedMedicationsController = TextEditingController();
  final TextEditingController _treatmentDurationController = TextEditingController();
  final TextEditingController _treatmentGoalsController = TextEditingController();
  final TextEditingController _alternativeTherapiesController = TextEditingController();

  // Controllers for lab tests
  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testResultController = TextEditingController();
  
  DateTime? _testDate;

  DateTime? _selectedDate;


Future<void> _addNewMedicalCondition() async {
  // Create a list of medical history objects
  List<Map<String, dynamic>> medicalHistory = [
    {
      "conditionName": _medicalConditionNameController.text.isNotEmpty
          ? _medicalConditionNameController.text
          : null,
      "diagnosisDate": _diagnosisDateController.text.isNotEmpty
          ? _diagnosisDateController.text
          : null,
      "conditionDetails": _medicalConditionDetailsController.text.isNotEmpty
          ? _medicalConditionDetailsController.text
          : null,
    }
  ];

  // Clear the controllers after creating the request
  _medicalConditionNameController.clear();
  _diagnosisDateController.clear();
  _medicalConditionDetailsController.clear();

  // Prepare the payload in the correct format
  Map<String, dynamic> requestPayload = {
    "medicalHistory": medicalHistory,
  };

  print('Request Payload: ${json.encode(requestPayload)}');

  String userId = widget.userId; // Get user ID
  try {
    String apiUrl = '${ApiConstants.baseUrl}/users/$userId/medicalhistory';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestPayload),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical information updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medical information: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  




   Future<void> _addNewLabTests() async {


List<Map<String, dynamic>> labTests = [
    {
      "testName": _testNameController.text.isNotEmpty
          ? _testNameController.text
          : null,
      "testResult": _testResultController.text.isNotEmpty
          ? _testResultController.text
          : null,
      "testDate": _diagnosisDateController.text.isNotEmpty
          ? _diagnosisDateController.text
          : null,
    }
  ];
  

  // Clear the controllers after creating the request
   _testNameController.clear();
    _testResultController.clear();
       _testDate = null;
    _diagnosisDateController.clear();
    _diagnosisDateController.text = '';
  // Prepare the payload in the correct format
  Map<String, dynamic> requestPayload = {
    "labTests": labTests,
  };

  print('Request Payload: ${json.encode(requestPayload)}');

  String userId = widget.userId; // Get user ID
  try {
    String apiUrl = '${ApiConstants.baseUrl}/users/$userId/labtests';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestPayload),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('labtests information updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update labtests information: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }





  }
    Future<void> _addNewMedicalNotes() async {
        
  
   List<Map<String, dynamic>> medicalNotes = [
    {
      "note": _medicalNotesController.text.isNotEmpty
          ? _medicalNotesController.text
          : null
      
    }
  ];
  

         _medicalNotesController.clear();

  Map<String, dynamic> requestPayload = {
    "medicalNotes": medicalNotes
  };

  print('Request Payload: ${json.encode(requestPayload)}');

  String userId = widget.userId; // Get user ID
  try {
    String apiUrl = '${ApiConstants.baseUrl}/users/$userId/medicalNotes';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestPayload),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('medicalNotes information updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medicalNotes information: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }



  }

 Future<void> _addNewTreatmentPlans() async {
        
List<Map<String, dynamic>> treatmentPlans = [
    {
      "prescribedMedications": _prescribedMedicationsController.text.isNotEmpty
          ? _prescribedMedicationsController.text
          : null,
      "treatmentDuration": _treatmentDurationController.text.isNotEmpty
          ? _treatmentDurationController.text
          : null,
      "treatmentGoals": _treatmentGoalsController.text.isNotEmpty
          ? _treatmentGoalsController.text
          : null,
      "alternativeTherapies": _alternativeTherapiesController.text.isNotEmpty
          ? _alternativeTherapiesController.text
          : null,
    }
  ];
  

  // Clear the controllers after creating the request
        _treatmentGoalsController.clear();
        _treatmentDurationController.clear();
        _prescribedMedicationsController.clear();
        _alternativeTherapiesController.clear();

  // Prepare the payload in the correct format
  Map<String, dynamic> requestPayload = {
    "treatmentPlans": treatmentPlans,
  };

  print('Request Payload: ${json.encode(requestPayload)}');

  String userId = widget.userId; // Get user ID
  try {
    String apiUrl = '${ApiConstants.baseUrl}/users/$userId/treatmentPlans';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestPayload),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('treatmentPlans information updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update treatmentPlans information: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }




    
  
  }
  Future<void> _selectDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Diagnosis Date', style: TextStyle(color: Color(0xff613089))),
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
                        _diagnosisDateController.text = "${selectedDay.toLocal()}".split(' ')[0];
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
                      titleTextStyle: TextStyle(color: Color(0xff613089), fontSize: 20),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xff613089)),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xff613089)),
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


 Future<void> _selectTestDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Test Date', style: TextStyle(color: Color(0xff613089))),
          content: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _testDate ?? DateTime.now(),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _testDate = selectedDay;
                        _diagnosisDateController.text = "${selectedDay.toLocal()}".split(' ')[0];
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
                      titleTextStyle: TextStyle(color: Color(0xff613089), fontSize: 20),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xff613089)),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xff613089)),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Private Medical Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff613089), Color(0xffb41391)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // New Container at the top of the page
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                 child: const Column(
   mainAxisAlignment: MainAxisAlignment.center, // Aligns the content vertically in the center
   children: [
    Icon(
      Icons.favorite, // Favorite icon
      color: Color(0xffb41391), // Set icon color
      size: 30, // You can adjust the size if needed
    ),
    SizedBox(height: 8), // Space between the icon and the text
    Text(
      'Your MediCarde Private Info',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xff613089),
      ),
      textAlign: TextAlign.center,
    ),
    SizedBox(height: 10),
    Text(
      'Please provide your private medical information securely.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black54),
    ),
    SizedBox(height: 10),
    Text(
      'No one can access this data without your permission.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
    ),
  ],
),


                ),
                const SizedBox(height: 20), // Space between the new container and the form
                
                _buildSectionTitle('Medical History'),
                _buildTextFormField(
                  controller: _medicalConditionNameController,
                  label: 'Medical Condition Name',
                  hint: 'Enter the name of the medical condition',
                  icon: Icons.sick,
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextFormField(
                      controller: _diagnosisDateController,
                      label: 'Diagnosis Date',
                      hint: 'Select diagnosis date',
                      icon: Icons.calendar_today,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _medicalConditionDetailsController,
                  label: 'Condition Details',
                  hint: 'Enter additional details about the condition',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                  ElevatedButton.icon(
                  onPressed: _addNewMedicalCondition,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add New Medical Condition"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff613089),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Lab Tests'),
                // Test Name
                _buildTextFormField(
                  controller: _testNameController,
                  label: 'Test Name',
                  hint: 'Enter the name of the test',
                  icon: Icons.science,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),

                // Test Result
                _buildTextFormField(
                  controller: _testResultController,
                  label: 'Test Result',
                  hint: 'Enter the result of the test',
                  icon: Icons.check_circle,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),

                // Test Date
                GestureDetector(
                  onTap: () => _selectTestDate(context),
                  child: AbsorbPointer(
                    child: _buildTextFormField(
                      controller: TextEditingController(
                          text: _testDate != null
                              ? "${_testDate!.toLocal()}".split(' ')[0]
                              : ''),
                      label: 'Test Date',
                      hint: 'Select test date',
                      icon: Icons.calendar_today,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _addNewLabTests,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add New LabTest"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff613089),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Medical Notes'),
                _buildTextFormField(
                  controller: _medicalNotesController,
                  label: 'Medical Notes',
                  hint: 'Enter medical notes',
                  icon: Icons.note_alt,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                  ElevatedButton.icon(
                  onPressed: _addNewMedicalNotes,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add New Medical Note"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff613089),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Treatment Plans'),
                _buildTextFormField(
                  controller: _prescribedMedicationsController,
                  label: 'Prescribed Medications',
                  hint: 'Enter medications prescribed',
                  icon: Icons.medication,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _treatmentDurationController,
                  label: 'Treatment Duration',
                  hint: 'Enter treatment duration (e.g., 6 weeks)',
                  icon: Icons.access_time,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _treatmentGoalsController,
                  label: 'Treatment Goals',
                  hint: 'Enter treatment goals',
                  icon: Icons.flag,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                _buildTextFormField(
                  controller: _alternativeTherapiesController,
                  label: 'Alternative Therapies',
                  hint: 'Enter alternative therapies',
                  icon: Icons.local_hospital,
                  maxLines: 2,
                ),
              
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _addNewTreatmentPlans,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add New Treatment Plan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff613089),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 20),
                /*
ElevatedButton(
  onPressed: () {
    if (_formKey.currentState?.validate() ?? false) {
      _submitForm();
    
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()), 
      );
    }
  },
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15),
    backgroundColor: const Color(0xffb41391),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: const Text(
    'Submit',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),*/

                const SizedBox(height: 20), // Space below the Submit button

                // Skip Button
                ElevatedButton(
  onPressed: () {
   
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()), 
    );
  },
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15),
    backgroundColor: const Color(0xffb41391),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: const Text(
    'Skip',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xff613089),
        ),
      ),
    );
  }

  // Helper method to build text form fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xff613089)),
        prefixIcon: Icon(icon, color: const Color(0xff613089)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xffb41391)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }
/*
  void _submitForm() {
    // Handle form submission logic
    print('Medical Condition Name: ${_medicalConditionNameController.text}');
    print('Diagnosis Date: ${_diagnosisDateController.text}');
    print('Condition Details: ${_medicalConditionDetailsController.text}');
    print('Test Name: ${_testNameController.text}');
    print('Test Result: ${_testResultController.text}');
    print('Test Date: ${_testDate != null ? "${_testDate!.toLocal()}".split(' ')[0] : ''}');
    print('Medical Notes: ${_medicalNotesController.text}');
    print('Prescribed Medications: ${_prescribedMedicationsController.text}');
    print('Treatment Duration: ${_treatmentDurationController.text}');
    print('Treatment Goals: ${_treatmentGoalsController.text}');
    print('Alternative Therapies: ${_alternativeTherapiesController.text}');
  }*/
}
