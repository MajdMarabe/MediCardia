import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'drugs_doctor.dart';
import 'lab_tests_doctor.dart';
import 'med_history_doctor.dart';
import 'med_notes_doctor.dart';
import 'treatments_doctor.dart';
import 'diabetes_doctor.dart';

class PatientViewPage extends StatefulWidget {
  @override
  _PatientViewPageState createState() => _PatientViewPageState();
}

class _PatientViewPageState extends State<PatientViewPage> {
  // Map to track the expanded/collapsed state of each section
  Map<String, bool> sectionExpanded = {
    'personalInfo': false,
    'medicalInfo': false,
  };

  // Toggle function to expand/collapse sections
  void toggleSection(String sectionKey) {
    setState(() {
      sectionExpanded[sectionKey] = !sectionExpanded[sectionKey]!;
    });
  }

  // Widget to display patient information
  Widget buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xff613089),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/doctor3.jpg'),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Majd',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 4)
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.person,
                                  size: 20, color: Colors.white70),
                            ),
                            const TextSpan(text: '  Age: 22 | Gender: Female'),
                          ],
                        ),
                      ),
                       const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.bloodtype,
                                  size: 20, color: Colors.white70),
                            ),
                            const TextSpan(text: '  Blood Type: B+'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
             ],
       )
    );
  }

  // Widget for personal information box
  Widget buildPersonalInfoBox() {
    return GestureDetector(
      onTap: () => toggleSection('personalInfo'),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
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
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff613089),
                  ),
                ),
                const Spacer(),
                Icon(
                  sectionExpanded['personalInfo']!
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: const Color(0xff613089),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (sectionExpanded['personalInfo']!) ...[
             
              const Text('ID Number: 123456789'),
              const Text('Email: majd.th2002@gmail.com'),
              const Text('Location: gfdsf'),
              const Text('Phone: 0598820544'),
            
             
            ],
          ],
        ),
      ),
    );
  }

  // Widget for public information box
  Widget buildPublicInfoBox() {
    return GestureDetector(
      onTap: () => toggleSection('medicalInfo'),
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
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
                const Text(
                  'Medical Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff613089),
                  ),
                ),
                const Spacer(),
                Icon(
                  sectionExpanded['medicalInfo']!
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: const Color(0xff613089),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (sectionExpanded['medicalInfo']!) ...[
            
              const Text('Chronic Diseases: Diabetes'),
              const Text('Allergies: Bencilin '),
              const Text('Last Blood Donation: 2024-11-19'),
            
            ],
          ],
        ),
      ),
    );
  }

  // Widget to build square buttons for services
  Widget buildSquareButton({
    required IconData icon,
    required String label,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xff613089)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
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
        centerTitle: true,
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            buildPatientInfo(),
            const SizedBox(height: 10),
            buildPersonalInfoBox(),
            const SizedBox(height: 10),
            buildPublicInfoBox(),
         
            const SizedBox(height: 20),
            // Remaining GridView for Services
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  buildSquareButton(
                    icon: FontAwesomeIcons.capsules,
                    label: 'Drugs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicineListPage()),
                      );
                    },
                  ),
                 
                  buildSquareButton(
                    icon: Icons.bloodtype,
                    label: 'Diabetes',
                     onTap: () {
         
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiabetesControlPage(), 
            ),
          );
        },
                  ),
                  buildSquareButton(
                    icon: Icons.science,
                    label: 'Lab Tests',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LabTestsPage()),
                      );
                    },
                  ),
                  buildSquareButton(
                    icon: Icons.note_alt,
                    label: 'Medical Notes',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalNotesPage()),
                      );
                    },
                  ),
                  buildSquareButton(
                    icon: Icons.fact_check,
                    label: 'Medical History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalHistoryPage()),
                      );
                    },
                  ),
                  buildSquareButton(
                    icon: Icons.medication,
                    label: 'Treatment Plans',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TreatmentPlansPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
