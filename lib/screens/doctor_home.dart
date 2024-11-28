import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'doctor_profile.dart';
import 'doctor_calender.dart';

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

class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f4f8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                const SizedBox(height: 50),
                // Header with Profile and Stats
                _buildDoctorProfile(),
                const SizedBox(height: 20),
                // Search Section (Moved after Doctor Profile)
                buildSearchSection(),
                const SizedBox(height: 20),
                
               // Patient List
                _buildPatientList(),
                const SizedBox(height: 20),
               
                
              ],
            ),
          ),
        ),
      ),
    );
  }

 // Function to build search section that fills the page
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
    width: double.infinity,  // Makes the search section fill the entire page width
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
              // Logic for searching by patient ID (e.g., filtering patient list)
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
                  "Dr. John Smith",
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
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

 
  Widget _buildBloodSugarTracking() {
    return _buildSectionContainer(
      title: "Blood Sugar Tracking",
      content: Column(
        children: [
          _buildPatientInfoTile(
            "John Doe",
            "Morning: 110 mg/dL | After Meal: 145 mg/dL",
            Colors.green,
            Icons.timeline,
          ),
          _buildPatientInfoTile(
            "Mary Jane",
            "Morning: 180 mg/dL | Alert: High",
            Colors.red,
            Icons.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return _buildSectionContainer(
      title: "Patient List",
      content: Column(
        children: [
          _buildPatientInfoTile(
            "John Doe",
            "ID: 12345 | Blood Type: A+",
            Colors.green,
            Icons.account_circle,
          ),
          _buildPatientInfoTile(
            "Mary Jane",
            "ID: 67890 | Blood Type: O-",
            Colors.orange,
            Icons.account_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required Widget content}) {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff613089),
            ),
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }

  Widget _buildPatientInfoTile(String name, String details, Color iconColor, IconData actionIcon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.2),
        child: Icon(actionIcon, color: iconColor),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(details),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color:Colors.white),
      onTap: () {
        // Action on tap (e.g., navigate to patient details)
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
          style: TextStyle(
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
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            Chip(
              label: Text(urgencyLevel, style: TextStyle(color: Colors.white)),
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
          _buildPatientInfoTile(
            "John Doe",
            "Morning: 110 mg/dL | After Meal: 145 mg/dL",
            Colors.green,
            Icons.timeline,
          ),
          _buildPatientInfoTile(
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
  Widget _buildSectionContainer({required String title, required Widget content}) {
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  // Example patient info tile widget
  Widget _buildPatientInfoTile(
      String patientName, String info, Color infoColor, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.all(10.0),
      leading: Icon(icon, color: infoColor),
      title: Text(patientName),
      subtitle: Text(info),
    );
  }
}

