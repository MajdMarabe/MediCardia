import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'doctor_profile.dart';
import 'doctor_calender.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'patient_view.dart';
import 'blood_donation.dart';
import 'package:flutter/foundation.dart';
import 'notification_page.dart';
import 'reviews_doctor.dart';
import 'doctor_schedule.dart';


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
    NotificationPage(),
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

////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Image.asset(
                    'assets/images/appLogo.png',
                    height: 35,
                    width: 35,
                    color: const Color(0xff613089),
                  ),
                  // const SizedBox(width: 4),
                  const Text(
                    'MediCardia',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BAUHS93',
                      color: Color(0xff613089),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              toolbarHeight: 60,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.home,
                      color: Color(0xff613089), size: 20),
                  tooltip: 'Home',
                  onPressed: () => _onItemTapped(0),
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.search,
                      color: Color(0xff613089), size: 20),
                  tooltip: 'Search',
                  onPressed: () => _onItemTapped(1),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications,
                      color: Color(0xff613089), size: 20),
                  tooltip: 'Notifications',
                  onPressed: () => _onItemTapped(2),
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.userCircle,
                      color: Color(0xff613089), size: 20),
                  tooltip: 'Profile',
                  onPressed: () => _onItemTapped(3),
                ),
                const SizedBox(width: 15),
              ],
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: kIsWeb
          ? null
          : CurvedNavigationBar(
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

//////////////////////////////////////

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<dynamic> _patients = [];
  List<dynamic> _Allpatients = [];
  String? doctorid; 
  String username='';
  String speciality='';
  int totalpatients=0;
int averageRating=0;
  bool _isLoading = true;
  bool _showMyPatients = true;
  String? base64ImageDoctor ='';

  //List<dynamic> _allPatients = [];
  List<dynamic> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
    fetchUserInfo();
    _fetchPatients();

  }
   Future<void> fetchUserInfo() async {
  final String ? userid =  await storage.read(key: 'userid');
  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/doctors/$userid'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        username = data['fullName'] ?? 'Unknown';
       speciality=data['specialization'] ?? 'Unknown';
        base64ImageDoctor=data['image'] ?? 'Unknown';
       
  totalpatients=   data['numberOfPatients'] ?? 'Unknown';
  averageRating= data['averageRating'] ?? 'Unknown';
      });
    } else {
      _showMessage('Failed to load user information');
      setState(() {
        _isLoading = false;
      });
    }
  } catch (e) {
    _showMessage('Error: $e');
    setState(() {
      _isLoading = false;
    });
  }
}
 void _showMessage(String message) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

  Future<void> _loadDoctorId() async {
    doctorid = await storage.read(key: 'userid'); // Use await inside async method
    setState(() {}); // Update the UI when the doctorid is loaded
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
          _filteredPatients = data;
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



Image buildImageFromBase64(String? base64Image) {
  try {
    if (base64Image == null || base64Image.isEmpty) {
      return Image.asset('assets/images/default_person.jpg'); 
    }

    final bytes = base64Decode(base64Image);
    print("Decoded bytes length: ${bytes.length}");

    return Image.memory(bytes);
  } catch (e) {
  
    print("Error decoding image: $e");
    return Image.asset('assets/images/default_person.jpg');
  }
}




/////////////////////////////////



@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F5FF),
    body: Center(
      child: SizedBox(
        width: kIsWeb
            ? MediaQuery.of(context).size.width * 0.75
            : MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildDoctorProfile(),
                    const SizedBox(height: 30),
                    buildSearchSection(),
                    const SizedBox(height: 30),
                         Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: buildBloodDonationTile(context)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DoctorSchedulePage()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff613089).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.access_time,  
                                        color: Color(0xff613089),
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Set Your Schedule",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff613089),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: buildReviewsTile(context)),
                      ],
                    ),
                    const SizedBox(height: 30),
                 
                    _buildToggleButtons(),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildPatientList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xff613089).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/blood-donation.png',
                width: 40,
                height: 40,
                color: const Color(0xff613089),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Blood Donation",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff613089),
            ),
          ),
        
        ],
      ),
    ),
  );
}


Widget buildReviewsTile(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReviewsPage(doctorid: doctorid as String,)),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xff613089).withOpacity(0.15),
            child: const Icon(Icons.star, size: 28, color: Color(0xff613089)),
          ),
          const SizedBox(height: 12),
          const Text(
            "Reviews \n",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff613089),
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


  Widget _buildUserAvatar() {
  ImageProvider backgroundImage;
  try {
    backgroundImage = buildImageFromBase64(base64ImageDoctor).image;
  } catch (e) {
    backgroundImage = const AssetImage('assets/images/default_person.jpg');
  }
  return CircleAvatar(
    radius: 42,
    backgroundColor: Colors.white,
    backgroundImage: backgroundImage,
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
        _buildUserAvatar(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                 "Dr.$username",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                 Text(
                  "Specialist:$speciality",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProfileStat(totalpatients.toString(), "Total Patients"),
                    _buildProfileStat(averageRating.toString(), "average Rating"),

                    
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

            if (_showMyPatients) {
              _fetchPatients();
            } else {
              _fetchAllPatients();
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
            padding: EdgeInsets.symmetric(horizontal: 25),
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
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patientData = _filteredPatients[index];
        if (_showMyPatients) {
          final name = patientData['patientId']?['username'] ?? 'Unknown';
          final details =
              "ID Number: ${patientData['patientId']?['medicalCard']?['publicData']?['idNumber'] ?? 'N/A'} Location: ${patientData['patientId']?['location'] ?? 'N/A'}";
          final patientId = patientData['patientId']?['_id'] ?? '';
          final base64Image = patientData['patientId']?['image'] ?? '';

          return _buildPatientInfoTile(
            name,
            details,
            base64Image, 
            patientId,
          );
        } else {
          final name = patientData['username'] ?? 'Unknown';
          final details =
              "ID Number: ${patientData['medicalCard']?['publicData']?['idNumber'] ?? 'N/A'} Location: ${patientData['location'] ?? 'N/A'}";
          final patientId = patientData['_id'] ?? '';
          final base64Image = patientData['medicalCard']?['publicData']?['image'] ?? '';

          return _buildPatientInfoTile(
            name,
            details,
            base64Image,
            patientId,
          );
        }
      },
    ),
  );
}


Widget _buildUserAvatarPatient(String base64Image) {
  ImageProvider backgroundImage;
  try {
    backgroundImage = buildImageFromBase64(base64Image).image; 
  } catch (e) {
    backgroundImage = const AssetImage('assets/images/default_person.jpg'); 
  }
  return CircleAvatar(
    radius: 20,
    backgroundColor: Colors.white,
    backgroundImage: backgroundImage, 
  );
}


Widget _buildPatientInfoTile(
  String name,
  String details,
  String base64Image, 
  String patientId,
) {
  return ListTile(
    leading: _buildUserAvatarPatient(base64Image), 
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




////////////////////////////////////////

/*

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
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
            _buildBloodSugarTracking(), 
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
      color: Colors.white, 
      elevation: 4, 
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
*/