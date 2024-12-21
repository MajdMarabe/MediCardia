import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'doctor_profile.dart';
import 'doctor_calender.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'patient_view.dart';
import 'blood_donation.dart';

const storage = FlutterSecureStorage();

class DoctorHomePage extends StatefulWidget {
  @override
  _DoctorHomePageState createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),
    DoctorCalendarPage(),
    NotificationsPage(),
    DoctorProfilePage(),
  ];

  final items = const [
    Icon(Icons.home, size: 30, color: Colors.white),
    Icon(Icons.calendar_today, size: 30, color: Colors.white),
    Icon(Icons.notifications, size: 30, color: Colors.white),
    Icon(Icons.person, size: 30, color: Colors.white),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        color: const Color(0xff613089),
        buttonBackgroundColor: const Color(0xff613089),
        animationDuration: const Duration(milliseconds: 300),
        height: 60,
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<dynamic> _patients = [];
  List<dynamic> _Allpatients = [];

  bool _isLoading = true;
  bool _showMyPatients = true;
  List<dynamic> _allPatients = [];
  List<dynamic> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchAllPatients() async {
    try {
      final doctorId = await storage.read(key: 'userid');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _Allpatients = data;
          _filteredPatients = data; // هنا نحدث المرضى في القائمة لعرض كل المرضى
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load all patients');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching all patients: $e');
    }
  }

  Future<void> _fetchPatients() async {
    try {
      final doctorId = await storage.read(key: 'userid');
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/doctorsusers/relations/doctor/$doctorId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _patients = data;
          _filteredPatients = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDoctorProfile(),
            const SizedBox(height: 20),
            buildSearchSection(),
            const SizedBox(height: 20),
            buildBloodDonationTile(context),
            const SizedBox(height: 20),
            _buildToggleButtons(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPatientList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBloodDonationTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BloodDonationPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
            CircleAvatar(
              backgroundColor: const Color(0xff613089).withOpacity(0.2),
              child: const Icon(Icons.bloodtype, color: Color(0xff613089)),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Blood Donation",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                    ),
                  ),
                  Text(
                    "Click to view blood donation requests and share information.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      width: double.infinity,
      child: Row(
        children: [
          const Icon(Icons.search, size: 30, color: Color(0xff613089)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for patient by ID...',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredPatients = _showMyPatients
                      ? _patients.where((patient) {
                          final idNumber = patient['patientId']?['medicalCard']
                                  ?['publicData']?['idNumber'] ??
                              '';
                          return idNumber.contains(value);
                        }).toList()
                      : _Allpatients.where((patient) {
                          final idNumber = patient['medicalCard']?['publicData']
                                  ?['idNumber'] ??
                              '';
                          return idNumber.contains(value);
                        }).toList();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorProfile() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff613089),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/doctor1.jpg'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dr.bayan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Specialist: Cardiologist",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProfileStat("250", "Total Patients"),
                    _buildProfileStat("52", "Emergency Cases"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ToggleButtons(
        isSelected: [_showMyPatients, !_showMyPatients],
        onPressed: (int index) {
          setState(() {
            _showMyPatients = index == 0;
            // استدعاء الدالة المناسبة بناءً على الاختيار
            if (_showMyPatients) {
              _fetchPatients(); // استدعاء دالة "مرضاي"
            } else {
              _fetchAllPatients(); // استدعاء دالة "كل المرضى"
            }
          });
        },
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        selectedColor: Colors.white,
        fillColor: const Color(0xff613089),
        color: Colors.black,
        constraints: const BoxConstraints(minHeight: 40, minWidth: 150),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Your patients', style: TextStyle(fontSize: 16)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('All patients', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _filteredPatients.length,
        itemBuilder: (context, index) {
          final patientData = _filteredPatients[index];

          if (_showMyPatients) {
            final name = patientData['patientId']?['username'] ?? 'Unknown';
            final details =
                "ID Number: ${patientData['patientId']?['medicalCard']?['publicData']?['idNumber'] ?? 'N/A'} Location: ${patientData['patientId']?['location'] ?? 'N/A'}";
            final patientId = patientData['patientId']?['_id'] ?? '';

            return _buildPatientInfoTile(
              name,
              details,
              const Color(0xff613089),
              Icons.account_circle,
              patientId,
            );
          } else {
            final name = patientData['username'] ?? 'Unknown';
            final details =
                "ID Number: ${patientData['medicalCard']?['publicData']?['idNumber'] ?? 'N/A'} Location: ${patientData['location'] ?? 'N/A'}";
            final patientId = patientData['_id'] ?? '';

            return _buildPatientInfoTile(
              name,
              details,
              const Color(0xff613089),
              Icons.account_circle,
              patientId,
            );
          }
        },
      ),
    );
  }

  Widget _buildPatientInfoTile(
    String name,
    String details,
    Color iconColor,
    IconData actionIcon,
    String patientId, // إضافة معامل لاستقبال الـ ID
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.2),
        child: Icon(actionIcon, color: iconColor),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(details),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientViewPage(patientId: patientId),
          ),
        );
      },
    );
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xff613089),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            _buildNotificationTile(
              iconColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.2),
              title: "Urgent: AB+ Needed",
              subtitle: "City Hospital | Last donation: 10 days ago",
              urgencyLevel: "High",
            ),
            _buildNotificationTile(
              iconColor: Colors.orange,
              backgroundColor: Colors.orange.withOpacity(0.2),
              title: "O- Blood Needed",
              subtitle: "Central Clinic | Last donation: 25 days ago",
              urgencyLevel: "Moderate",
            ),
            _buildBloodSugarTracking(), // Add the blood sugar tracking section here
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required String urgencyLevel,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white, // Set the notification background to white
      elevation: 4, // Maintain a slight shadow for separation
      child: ListTile(
        contentPadding: const EdgeInsets.all(15.0),
        leading: CircleAvatar(
          backgroundColor: backgroundColor,
          child: Icon(Icons.bloodtype, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            Chip(
              label: Text(urgencyLevel,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: urgencyLevel == "High"
                  ? Colors.red
                  : urgencyLevel == "Moderate"
                      ? Colors.orange
                      : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Blood sugar tracking widget
  Widget _buildBloodSugarTracking() {
    return _buildSectionContainer(
      title: "Blood Sugar Tracking",
      content: Column(
        children: [
          _buildPatientInfoTile1(
            "John Doe",
            "Morning: 110 mg/dL | After Meal: 145 mg/dL",
            Colors.green,
            Icons.timeline,
          ),
          _buildPatientInfoTile1(
            "Mary Jane",
            "Morning: 180 mg/dL | Alert: High",
            Colors.red,
            Icons.warning,
          ),
        ],
      ),
    );
  }

  // Example section container widget
  Widget _buildSectionContainer(
      {required String title, required Widget content}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  // Example patient info tile widget
  Widget _buildPatientInfoTile1(
      String patientName, String info, Color infoColor, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.all(10.0),
      leading: Icon(icon, color: infoColor),
      title: Text(patientName),
      subtitle: Text(info),
    );
  }
}
