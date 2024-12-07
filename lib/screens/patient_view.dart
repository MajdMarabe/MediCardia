import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PatientViewPage extends StatefulWidget {
  @override
  _PatientViewPageState createState() => _PatientViewPageState();
}

class _PatientViewPageState extends State<PatientViewPage> {
  final Map<String, dynamic> patientData = {
    'username': 'mlak',
    'email': 'mlak@gmail.com',
    'location': 'Nablus',
    'idNumber': '123456789',
    'gender': 'Female',
    'age': 26,
    'bloodType': 'B-',
    'chronicConditions': ['Diabetes'],
    'allergies': [],
    'lastBloodDonationDate': '2024-12-03T00:00:00.000+00:00',
    'phoneNumber': '0598820544',
    'Drugs': [
      {
        'drug': 'Drug1',
        'usageStartDate': '2024-12-01',
        'usageEndDate': '2024-12-03'
      },
      {
        'drug': 'Drug2',
        'usageStartDate': '2024-12-01',
        'usageEndDate': '2024-12-03'
      },
    ],
    'medicalHistory': [
      {
        'conditionName': 'Condition1',
        'diagnosisDate': '2024-12-03',
        'conditionDetails': 'Details1'
      },
      {
        'conditionName': 'Condition2',
        'diagnosisDate': '2024-12-03',
        'conditionDetails': 'Details2'
      },
    ],
    'labTests': [
      {'testName': 'Test1', 'testResult': 'Positive', 'testDate': '2024-12-09'},
      {'testName': 'Test2', 'testResult': 'Negative', 'testDate': '2024-12-09'},
    ],
    'medicalNotes': [
      {'note': 'Note1'},
      {'note': 'Note2'},
    ],
    'treatmentPlans': [
      {
        'prescribedMedications': 'Med1',
        'treatmentDuration': '1 week',
        'treatmentGoals': 'Goal1',
        'alternativeTherapies': 'Therapy1'
      },
    ],
  };

 TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _drugNameController = TextEditingController();
  String _selectedDrugType = 'Permanent';
  bool _isTemporary = false;
  DateTime? _selectedDate;
   final TextEditingController _diagnosisDateController =
      TextEditingController();
       final TextEditingController _testDateController = TextEditingController();
       List<dynamic> medicalNotes = [];
       List<dynamic> treatmentPlans = [];

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isStartDate, int drugIndex) async {
  if (drugIndex < 0 || drugIndex >= patientData['Drugs'].length) {
    // If the drugIndex is invalid, print an error message and return
    print("Invalid drug index");
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Date', style: TextStyle(color: Color(0xff613089))),
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
                      // Update the correct field in patientData based on isStartDate
                      if (isStartDate) {
                        patientData['Drugs'][drugIndex]['usageStartDate'] =
                            "${selectedDay.toLocal()}".split(' ')[0];
                        controller.text = "${selectedDay.toLocal()}".split(' ')[0];
                      } else {
                        patientData['Drugs'][drugIndex]['usageEndDate'] =
                            "${selectedDay.toLocal()}".split(' ')[0];
                        controller.text = "${selectedDay.toLocal()}".split(' ')[0];
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Color(0xffb41391),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xff613089),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(color: Color(0xff613089), fontSize: 20),
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


Future<void> _selectDateTime(BuildContext context, TextEditingController controller, bool isStartDate) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Date', style: TextStyle(color: Color(0xff613089))),
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
                      // Update the correct controller (Start or End date)
                      if (isStartDate) {
                        controller.text = "${selectedDay.toLocal()}".split(' ')[0];
                      } else {
                        controller.text = "${selectedDay.toLocal()}".split(' ')[0];
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Color(0xffb41391),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xff613089),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(color: Color(0xff613089), fontSize: 20),
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

 Future<void> _selectMedicalHistoryDate(BuildContext context) async {
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


 Future<void> _selectLabTestDate(BuildContext context) async {
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
                    focusedDay: _selectedDate ?? DateTime.now(),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _testDateController.text = "${selectedDay.toLocal()}".split(' ')[0];
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
                      titleTextStyle: TextStyle(color: Color(0xff613089), fontSize: 20),
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

  Map<String, bool> sectionExpanded = {
    'personalInfo': false,
    'medicalInfo': false,
    'chronicConditions': false,
    'medications': false,
    'medicalHistory': false,
    'labTests': false,
    'medicalNotes': false,
    'treatmentPlans': false,
  };

  void toggleSection(String section) {
    setState(() {
      sectionExpanded[section] = !sectionExpanded[section]!;
    });
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff613089),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage:
                AssetImage('assets/images/doctor1.jpg'), // Placeholder
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientData['username'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Age: ${patientData['age']} | Blood Type: ${patientData['bloodType']}",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildExpandableSection(
    {required String title,
    required String sectionKey,
    required List<Widget> content}) {
  return GestureDetector(
    onTap: () => toggleSection(sectionKey),
    child: Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xff613089)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
              ),
              const Spacer(),
              Icon(
                sectionExpanded[sectionKey]! ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: const Color(0xff613089),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (sectionExpanded[sectionKey] == true) ...content,
        ],
      ),
    ),
  );
}


 Widget _buildMedicationSection(int drugIndex) {
  var drug = patientData['Drugs'][drugIndex];
  
  // Controllers for start and end date
  TextEditingController startDateController = TextEditingController(text: drug['usageStartDate']);
  TextEditingController endDateController = TextEditingController(text: drug['usageEndDate']);

  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services, color: Color(0xff613089)),
              const SizedBox(width: 10),
              Text(
                "Drug: ${drug['drug']}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff613089)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text("Start Date: ${drug['usageStartDate']}"),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xff613089)),
                onPressed: () => _selectDate(context, startDateController, true, drugIndex),
              ),
            ],
          ),
          Row(
            children: [
              Text("End Date: ${drug['usageEndDate']}"),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xff613089)),
                onPressed: () => _selectDate(context, endDateController, false, drugIndex),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


 void _showAddDrugDialog() {
  // Reset the form fields before showing the dialog
  _drugNameController.clear();
  _startDateController.clear();
  _endDateController.clear();
  _selectedDrugType = 'Permanent'; // Default drug type
  _isTemporary = false; // Default value for temporary drugs

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
                  const Row(
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
                  TextFormField(
                    controller: _drugNameController,
                    decoration: InputDecoration(
                      labelText: 'Drug name',
                      labelStyle: const TextStyle(color: Color(0xff613089)),
                      prefixIcon: Icon(Icons.medical_services, color: Color(0xff613089)),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      filled: true,
                      fillColor: Color(0xFFF3F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff613089), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff613089), width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the drug name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Drug Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedDrugType,
                    items: ['Permanent', 'Temporary']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDrugType = value!;
                        _isTemporary = _selectedDrugType == 'Temporary'; // Update visibility of dates
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Drug Type',
                      labelStyle: const TextStyle(color: Color(0xff613089)),
                      prefixIcon: Icon(Icons.category, color: Color(0xff613089)),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      filled: true,
                      fillColor: Color(0xFFF3F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff613089), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff613089), width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Show Start & End Dates only if Temporary is selected
                  if (_isTemporary)
                    Column(
                      children: [
                        // Start Date TextFormField
                        TextFormField(
                          controller: _startDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            labelStyle: const TextStyle(color: Color(0xff613089)),
                            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xff613089)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xff613089), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xff613089), width: 2.0),
                            ),
                          ),
                           onTap: () async {
          // Pass the controller and true for Start Date
          await _selectDateTime(context, _startDateController, true);
        },
                        ),
                        const SizedBox(height: 20),

                        // End Date TextFormField
                        TextFormField(
                          controller: _endDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            labelStyle: const TextStyle(color: Color(0xff613089)),
                            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xff613089)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xff613089), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color(0xff613089), width: 2.0),
                            ),
                          ),
                         onTap: () async {
          // Pass the controller and false for End Date
          await _selectDateTime(context, _endDateController, false);
        },

                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff613089),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_drugNameController.text.isNotEmpty) {
                            // Add the new drug to patient data
                            setState(() {
                              patientData['Drugs'].add({
                                'drug': _drugNameController.text,
                                'usageStartDate': _startDateController.text,
                                'usageEndDate': _endDateController.text,
                              });
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff613089),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Add Drug'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showAddMedicalHistoryDialog() {
  final conditionController = TextEditingController();
  final detailsController = TextEditingController();
  final diagnosisDateController = TextEditingController();
  
  // Date picker variable
  DateTime? _selectedDiagnosisDate;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Add New Medical History", style: TextStyle(color: Color(0xff613089))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: conditionController,
                decoration: InputDecoration(
                  labelText: "Condition Name",
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  prefixIcon: Icon(Icons.medical_services, color: Color(0xff613089)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089)),
                  ),
                ),
              ),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(
                  labelText: "Condition Details",
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  prefixIcon: Icon(Icons.notes, color: Color(0xff613089)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff613089)),
                  ),
                ),
              ),
               GestureDetector(
                onTap: () => _selectMedicalHistoryDate(context), // Show date picker
                child: AbsorbPointer(
                  child: TextField(
                    controller: _diagnosisDateController,
                    decoration: InputDecoration(
                      labelText: "Diagnosis Date",
                      labelStyle: const TextStyle(color: Color(0xff613089)),
                      prefixIcon: Icon(Icons.calendar_today, color: Color(0xff613089)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff613089)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newItem = {
                'conditionName': conditionController.text,
                'diagnosisDate': diagnosisDateController.text,
                'conditionDetails': detailsController.text,
              };
              setState(() {
                patientData['medicalHistory'].add(newItem);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff613089),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text("Add"),
          ),
        ],
      );
    },
  );
}


Future<void> _showAddLabTestDialog() async{
   final nameController = TextEditingController();
    final resultController = TextEditingController();
    final FocusNode nameFocusNode = FocusNode();
    final FocusNode resultFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add New Lab Test", style: TextStyle(color: Color(0xff613089))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  decoration: InputDecoration(
                    labelText: "Test Name",
                    labelStyle: const TextStyle(color: Color(0xff613089)),
                    prefixIcon: Icon(Icons.science, color: Color(0xff613089)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff613089)),
                    ),
                  ),
                ),
                TextField(
                  controller: resultController,
                  focusNode: resultFocusNode,
                  decoration: InputDecoration(
                    labelText: "Test Result",
                    labelStyle: const TextStyle(color: Color(0xff613089)),
                    prefixIcon: Icon(Icons.check_circle, color: Color(0xff613089)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff613089)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectLabTestDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _testDateController,
                      decoration: InputDecoration(
                        labelText: "Test Date",
                        labelStyle: const TextStyle(color: Color(0xff613089)),
                        prefixIcon: Icon(Icons.calendar_today, color: Color(0xff613089)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff613089)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final newItem = {
                  'testName': nameController.text,
                  'testDate': _testDateController.text,
                  'testResult': resultController.text,
                };
                setState(() {
                   patientData['labTests'].add(newItem);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff613089),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }


 void showAddMedicalNotesDialog() {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add New Medical Note", style: TextStyle(color: Color(0xff613089))),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: "Note",
                    labelStyle: const TextStyle(color: Color(0xff613089)),
                    prefixIcon: Icon(Icons.note, color: Color(0xff613089)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff613089)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final newItem = {
                  'note': noteController.text,
                };
                setState(() {
                  medicalNotes.add(newItem);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff613089),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

   void showAddTreatmentPlansDialog({Map<String, dynamic>? treatmentPlan, int? index}) {
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
          "Patient Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPatientHeader(), // عرض تفاصيل المريض
            const SizedBox(height: 20),

            // قسم معلومات شخصية
            _buildExpandableSection(
              title: "Personal Information",
              sectionKey: 'personalInfo',
              content: [
                Text("Username: ${patientData['username']}"),
                Text("Email: ${patientData['email']}"),
                Text("Location: ${patientData['location']}"),
                Text("ID Number: ${patientData['idNumber']}"),
                Text("Gender: ${patientData['gender']}"),
                Text("Phone Number: ${patientData['phoneNumber']}"),
              ],
            ),

            const SizedBox(height: 20),

            // قسم معلومات طبية
            _buildExpandableSection(
              title: "Medical Information",
              sectionKey: 'medicalInfo',
              content: [
                Text("Blood Type: ${patientData['bloodType']}"),
                Text("Age: ${patientData['age']}"),
                Text(
                    "Chronic Conditions: ${patientData['chronicConditions'].join(", ")}"),
                Text("Allergies: ${patientData['allergies'].join(", ")}"),
                Text(
                    "Last Blood Donation: ${patientData['lastBloodDonationDate']}"),
              ],
            ),

            const SizedBox(height: 20),

            // قسم الأدوية
          _buildExpandableSection(
  title: "Drugs",
  sectionKey: 'medications',
  content: [
    for (int i = 0; i < patientData['Drugs'].length; i++)
      _buildMedicationSection(i),
    
    Center(
  child: ElevatedButton(
      onPressed: () {
        // Call the _showAddDrugDialog method to display the dialog
        _showAddDrugDialog();
      },
      child: Text('Add Drug'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff613089),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0)),
    ),
  ),
)
  ],
),


            const SizedBox(height: 20),

         _buildExpandableSection(
  title: "Medical History",
  sectionKey: 'medicalHistory',
  content: [
    for (var history in patientData['medicalHistory'])
      Text("${history['conditionName']} - ${history['diagnosisDate']}"),
    
    Center(
  child: ElevatedButton(
    onPressed: _showAddMedicalHistoryDialog,
    child: Text('Add Medical History'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xff613089),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
  ),
)

  ],
),

            const SizedBox(height: 20),

            // قسم الفحوصات المخبرية
            _buildExpandableSection(
              title: "Lab Tests",
              sectionKey: 'labTests',
              content: [
                for (var test in patientData['labTests'])
                  Text("${test['testName']} - ${test['testResult']} - ${test['testDate']}"),
                     Center(
  child: ElevatedButton(
    onPressed: () => _showAddLabTestDialog(),
    child: Text('Add Lab Test'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xff613089),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
  ),
)
              ],
            ),

            const SizedBox(height: 20),

            // قسم الملاحظات الطبية
            _buildExpandableSection(
              title: "Medical Notes",
              sectionKey: 'medicalNotes',
              content: [
                for (var note in patientData['medicalNotes'])
                  Text(note['note']),
                   Center(
  child: ElevatedButton(
    onPressed: showAddMedicalNotesDialog, // Pass the method reference without parentheses.
    child: Text('Add Medical Notes'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xff613089),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
  ),
)

              ],
            ),

            const SizedBox(height: 20),

            // قسم خطط العلاج
            _buildExpandableSection(
              title: "Treatment Plans",
              sectionKey: 'treatmentPlans',
              content: [
                for (var plan in patientData['treatmentPlans'])
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Prescribed Medications: ${plan['prescribedMedications']}"),
                      Text("Treatment Duration: ${plan['treatmentDuration']}"),
                      Text("Treatment Goals: ${plan['treatmentGoals']}"),
                      Text(
                          "Alternative Therapies: ${plan['alternativeTherapies']}"),
                    ],
                  ),
                  Center(
  child: ElevatedButton(
    onPressed: showAddTreatmentPlansDialog, // Pass the method reference without parentheses.
    child: Text('Add Treatment Plans'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xff613089),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
  ),
)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
