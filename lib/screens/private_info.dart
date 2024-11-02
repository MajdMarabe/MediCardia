import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class PrivateInfo extends StatefulWidget {
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
                  child: const Column( // Add a Column to contain multiple widgets
                    children: [
                      Text(
                        'Your MediCardia Private Info',
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

                _buildSectionTitle('Medical Notes'),
                _buildTextFormField(
                  controller: _medicalNotesController,
                  label: 'Medical Notes',
                  hint: 'Enter medical notes',
                  icon: Icons.note_alt,
                  maxLines: 3,
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

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _submitForm();
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
                ),
                const SizedBox(height: 20), // Space below the Submit button

                // Skip Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the next page or perform any action you want
                    Navigator.pushReplacementNamed(context, '/nextPage'); // Change '/nextPage' to your target route
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
  }
}
