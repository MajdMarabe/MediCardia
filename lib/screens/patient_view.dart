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
      {'drug': 'Drug1', 'usageStartDate': '2024-12-01', 'usageEndDate': '2024-12-03'},
      {'drug': 'Drug2', 'usageStartDate': '2024-12-01', 'usageEndDate': '2024-12-03'},
    ],
    'medicalHistory': [
      {'conditionName': 'Condition1', 'diagnosisDate': '2024-12-03', 'conditionDetails': 'Details1'},
      {'conditionName': 'Condition2', 'diagnosisDate': '2024-12-03', 'conditionDetails': 'Details2'},
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
      {'prescribedMedications': 'Med1', 'treatmentDuration': '1 week', 'treatmentGoals': 'Goal1', 'alternativeTherapies': 'Therapy1'},
    ],
  };
TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate, int drugIndex) async {
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
                        if (isStartDate) {
                          patientData['Drugs'][drugIndex]['usageStartDate'] = "${selectedDay.toLocal()}".split(' ')[0];
                        } else {
                          patientData['Drugs'][drugIndex]['usageEndDate'] = "${selectedDay.toLocal()}".split(' ')[0];
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

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Patient Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientHeader(),
                const SizedBox(height: 25),
                _buildExpandableSection(
                  title: "Personal Information",
                  sectionKey: 'personalInfo',
                  content: [
                    Text("Username: ${patientData['username']}"),
                    Text("Email: ${patientData['email']}"),
                    Text("Location: ${patientData['location']}"),
                    Text("Phone: ${patientData['phoneNumber']}"),
                  ],
                ),
                const SizedBox(height: 20),
                _buildExpandableSection(
                  title: "Public Information",
                  sectionKey: 'medicalInfo',
                  content: [
                    Text("ID Number: ${patientData['idNumber']}"),
                    Text("Gender: ${patientData['gender']}"),
                    Text("Age: ${patientData['age']}"),
                    Text("Blood Type: ${patientData['bloodType']}"),
                    Text("Last Blood Donation: ${patientData['lastBloodDonationDate']}"),
                  ],
                ),
                const SizedBox(height: 20),
                _buildExpandableSection(
                  title: "Chronic Conditions",
                  sectionKey: 'chronicConditions',
                  content: [
                    if (patientData['chronicConditions'].isEmpty)
                      Text("No chronic conditions listed.")
                    else
                      ...patientData['chronicConditions'].map((condition) => Text(condition)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildExpandableSection(
                  title: "Medications",
                  sectionKey: 'medications',
                  content: [
                    for (var drugIndex = 0; drugIndex < patientData['Drugs'].length; drugIndex++)
                      _buildMedicationSection(drugIndex),
                  ],
                ),
                const SizedBox(height: 20),
                _buildExpandableSection(
                  title: "Medical History",
                  sectionKey: 'medicalHistory',
                  content: [
                    for (var history in patientData['medicalHistory'])
                      Text("Condition: ${history['conditionName']}, Diagnosed: ${history['diagnosisDate']}, Details: ${history['conditionDetails']}"),
                  ],
                ),
                const SizedBox(height: 20),
                _buildExpandableSection(
                  title: "Lab Tests",
                  sectionKey: 'labTests',
                  content: [
                    for (var test in patientData['labTests'])
                      Text("Test: ${test['testName']}, Result: ${test['testResult']}, Date: ${test['testDate']}"),
                  ],
                ),
                const SizedBox(height: 20),
                _buildExpandableSection(
                  title: "Medical Notes",
                  sectionKey: 'medicalNotes',
                  content: [
                    for (var note in patientData['medicalNotes'])
                      Text("Note: ${note['note']}"),
                  ],
                ),
                const SizedBox(height: 20),
                _buildExpandableSection(
                  title: "Treatment Plans",
                  sectionKey: 'treatmentPlans',
                  content: [
                    for (var plan in patientData['treatmentPlans'])
                      Text("Medications: ${plan['prescribedMedications']}, Duration: ${plan['treatmentDuration']}, Goals: ${plan['treatmentGoals']}, Alternative Therapies: ${plan['alternativeTherapies']}"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff613089),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/doctor1.jpg'), // Placeholder
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

  Widget _buildExpandableSection({required String title, required String sectionKey, required List<Widget> content}) {
    return GestureDetector(
      onTap: () => toggleSection(sectionKey),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 3)],
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff613089)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (sectionExpanded[sectionKey] == true)
              ...content,
          ],
        ),
      ),
    );
  }

Widget _buildMedicationSection(int drugIndex) {
    var drug = patientData['Drugs'][drugIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 3),
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff613089)),
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
                  onPressed: () => _selectDate(context, true, drugIndex),
                ),
              ],
            ),
            Row(
              children: [
                Text("End Date: ${drug['usageEndDate']}"),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xff613089)),
                  onPressed: () => _selectDate(context, false, drugIndex),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
