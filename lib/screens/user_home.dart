import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_3/screens/user_profile.dart';
import 'package:flutter_application_3/screens/diabetes_control.dart';
import 'package:flutter_application_3/screens/medical_history_view.dart';
import 'package:flutter_application_3/screens/lab_tests_view.dart';
import 'package:flutter_application_3/screens/medical_notes_view.dart';
import 'package:flutter_application_3/screens/treatment_plans_view.dart';
import 'package:flutter/foundation.dart';
import 'blood_donation_home.dart';
import 'drugshome.dart';
import 'viewdoctors.dart';
import 'notification_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'dart:convert';
import 'blood_pressure.dart';
import 'user_calender.dart';

const storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allUsers = [];
  String username = 'Unknown';
  String gender = 'Unknown';
  String bloodType = 'Unknown';
  int age = 0;
  String phoneNumber = 'N/A';
  String idNumber = 'Unknown';
  String? base64Image = '';

  List<String> chronicDiseases = [];
  List<String> allergies = [];
  List<Map<String, dynamic>> allDoctors = [];
  List<Map<String, dynamic>> displayedDoctors = [];
  bool isLoading = true;
  bool _isExpanded = false;
  List<String> doctorNames = [];

  final items = const [
    Icon(
      Icons.home,
      size: 30,
      color: Colors.white,
    ),
    Icon(FontAwesomeIcons.calendar, size: 30, color: Colors.white),
    Icon(Icons.notifications, size: 30, color: Colors.white),
    Icon(FontAwesomeIcons.userCircle, size: 30, color: Colors.white),
  ];

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Container(),
    PatientAppointment(),
    const NotificationPage(),
    ProfilePage(),
  ];
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchDoctors();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
Future<void> fetchDoctors() async {
  try {
    final response =
        await http.get(Uri.parse('${ApiConstants.baseUrl}/rating/top/rated'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> doctorsData = jsonResponse['data'];

      setState(() {

        allDoctors = doctorsData.map((doc) {
          return {
            'id': doc['id'],
            'name': doc['name'] ?? 'Unknown',
            'specialty': doc['speciality'] ?? 'Unknown',
            'about': doc['about'] ?? 'No about provided.',
            'averageRating': doc['averageRating'] ?? 0.0,
            'image': doc['image'] ?? 'Unknown',
            'phone': doc['phone'] ?? 'No phone number provided.',
            'numberOfPatients': doc['numberOfPatients'] ?? 0,
            'numberOfReviews': doc['numberOfReviews'] ?? 0,
            'workplace': {
              'name': doc['workplace']?['name'] ?? 'No workplace name.',
              'address': doc['workplace']?['address'] ?? 'No address.',
            },
          };
        }).toList();


        displayedDoctors = allDoctors
            .where((doctor) => doctor['name'] != 'Sally Mah')
            .toList();
        
        doctorNames = displayedDoctors
            .map((doctor) => doctor['name'] as String)
            .toList();
        
        isLoading = false;
      });
    } else {
      _showMessage('Failed to load doctors');
      setState(() {
        isLoading = false;
      });
    }
  } catch (e) {
    _showMessage('Error: $e');
    setState(() {
      isLoading = false;
    });
  }
}


// Fetch all doctors from the API
  Future<void> fetchUserInfo() async {
    final String? userid = await storage.read(key: 'userid');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/$userid'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          username = data['username'] ?? 'Unknown';
          gender = data['medicalCard']?['publicData']?['gender'] ?? 'Unknown';
          bloodType =
              data['medicalCard']?['publicData']?['bloodType'] ?? 'Unknown';
          age = data['medicalCard']?['publicData']?['age'] ?? 0;
          idNumber =
              data['medicalCard']?['publicData']?['idNumber'] ?? 'Unknown';
          base64Image =
              data['medicalCard']?['publicData']?['image'] ?? 'Unknown';

          chronicDiseases = List<String>.from(
            data['medicalCard']?['publicData']?['chronicConditions'] ?? [],
          );
          allergies = List<String>.from(
            data['medicalCard']?['publicData']?['allergies'] ?? [],
          );
          isLoading = false;
        });
      } else {
        _showMessage('Failed to load user information');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showMessage('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  //////////////////////////////////

  void _showAddChronicDialog(BuildContext context, Function(String) onAdd) {
    // Sample list of chronic diseases
    final List<Map<String, dynamic>> allDiseases = [
      {'name': 'Diabetes', 'icon': Icons.bloodtype},
      {'name': 'Blood Pressure', 'icon': Icons.monitor_heart},
      {'name': 'Asthma', 'icon': Icons.air},
      {'name': 'Cancer', 'icon': Icons.coronavirus},
      {'name': 'Kidney Failure', 'icon': Icons.opacity},
    ];

    List<String> selectedDiseases = [];

    showDialog(
      context: context,
      builder: (context) {
        double dialogWidth = MediaQuery.of(context).size.width > 600
            ? 600
            : MediaQuery.of(context).size.width * 0.9;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: dialogWidth,
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
                    "Add Chronic Disease",
                    style: TextStyle(
                      color: Color(0xff613089),
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10.0, // Spacing between chips
                    runSpacing: 10.0,
                    children: allDiseases.map((disease) {
                      final isSelected =
                          selectedDiseases.contains(disease['name']);
                      return FilterChip(
                        label: Text(
                          disease['name'],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xff613089),
                          ),
                        ),
                        avatar: Icon(
                          disease['icon'],
                          color: isSelected
                              ? Colors.white
                              : const Color(0xff613089),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDiseases.add(disease['name']);
                            } else {
                              selectedDiseases.remove(disease['name']);
                            }
                          });
                        },
                        selectedColor: const Color(0xffb41391),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedDiseases.isNotEmpty) {
                            // Pass the selected diseases to the onAdd function
                            onAdd(selectedDiseases.join(', '));
                            Navigator.pop(context);
                          } else {
                            // Show a message if no disease is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please select a disease')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff613089),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Add"),
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

  void _showAddAllergyDialog(BuildContext context, Function(String) onAdd) {
    TextEditingController allergyController = TextEditingController();
    double dialogWidth = MediaQuery.of(context).size.width > 600
        ? 600
        : MediaQuery.of(context).size.width * 0.9;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: dialogWidth,
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
                    "Add Allergy",
                    style: TextStyle(
                      color: Color(0xff613089),
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: allergyController,
                    decoration: InputDecoration(
                      labelText: 'Enter allergy',
                      labelStyle: const TextStyle(color: Color(0xff613089)),
                      hintText: 'Enter allergy',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon:
                          const Icon(Icons.warning, color: Color(0xff613089)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xffb41391),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (allergyController.text.isNotEmpty) {
                            // Add the entered allergy to the list
                            onAdd(allergyController.text);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter an allergy')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff613089),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Add"),
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

  // Function to build circular service buttons
  Widget buildCircleButton({
    required IconData icon,
    required String label,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: const Color(0xff613089)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
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

  String formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      print("Error parsing date: $e");
      return isoDate;
    }
  }

/////////////////////////////////////////

  Widget buildUserInfo() {
    return StatefulBuilder(
      builder: (context, setState) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xff613089),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildUserAvatar(),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                            children: [
                              const WidgetSpan(
                                child: Icon(Icons.person,
                                    size: 20, color: Colors.white70),
                              ),
                              TextSpan(text: '  Age: $age | Gender: $gender'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                            children: [
                              const WidgetSpan(
                                child: Icon(Icons.bloodtype,
                                    size: 20, color: Colors.white70),
                              ),
                              TextSpan(text: '  Blood Type: $bloodType'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                buildInfoRow(Icons.badge, 'ID Number: $idNumber'),
                buildEditableListRow(FontAwesomeIcons.heartbeat,
                    'Chronic Diseases:', chronicDiseases, (newValue) {
                  setState(() {
                    chronicDiseases.add(newValue);
                  });
                }, (index) {
                  setState(() {
                    chronicDiseases.removeAt(index);
                  });
                }, 'chronic'),
                buildEditableListRow(Icons.warning, 'Allergies:', allergies,
                    (newValue) {
                  setState(() {
                    allergies.add(newValue);
                  });
                }, (index) {
                  setState(() {
                    allergies.removeAt(index);
                  });
                }, 'allergy'),
              ],
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Show Less' : 'Show More',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar() {
    ImageProvider backgroundImage;
    try {
      backgroundImage = buildImageFromBase64(base64Image).image;
    } catch (e) {
      backgroundImage = const AssetImage('assets/images/default_person.jpg');
    }
    return CircleAvatar(
      radius: 42,
      backgroundColor: Colors.white,
      backgroundImage: backgroundImage,
    );
  }

  Widget buildEditableListRow(IconData icon, String title, List<String> list,
      Function(String) onAdd, Function(int) onRemove, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          ...list.map((item) {
            int index = list.indexOf(item);
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    onRemove(index);
                  },
                ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              if (type == 'chronic') {
                _showAddChronicDialog(context, onAdd);
              } else if (type == 'allergy') {
                _showAddAllergyDialog(context, onAdd);
              }
            },
          ),
        ],
      ),
    );
  }

/////////////////////////

  // // Function to build search section
  // Widget buildSearchSection() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 20),
  //     padding: const EdgeInsets.all(15),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 10,
  //           spreadRadius: 2,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(Icons.search, size: 30, color: Color(0xff613089)),
  //         const SizedBox(width: 10),
  //         Expanded(
  //           child: TextField(
  //             decoration: InputDecoration(
  //               border: InputBorder.none,
  //               hintText: 'Search for doctor,  etc.',
  //               hintStyle: TextStyle(color: Colors.grey[400]),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

/////////////////////////////////




  @override
  Widget build(BuildContext context) {
    const isWeb = kIsWeb;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: isWeb
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
                  icon: const Icon(FontAwesomeIcons.calendar,
                      color: Color(0xff613089), size: 20),
                  tooltip: 'Calender',
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
            body: ScrollConfiguration(
      behavior: kIsWeb ? TransparentScrollbarBehavior() : const ScrollBehavior(),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width > 600
              ? MediaQuery.of(context).size.width * 0.75
              : MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              _pages[_selectedIndex],
              if (_selectedIndex == 0)
               SingleChildScrollView(
              physics: kIsWeb 
      ? const AlwaysScrollableScrollPhysics() 
      : const BouncingScrollPhysics(), 
                  child: Column(
                    children: [
                      // Animated Welcome Text
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                'Welcome to MediCardia',
                                textStyle: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff613089),
                                  fontFamily: 'ScriptMTBold',
                                ),
                                speed: const Duration(milliseconds: 100),
                              ),
                            ],
                            totalRepeatCount: 1,
                            pause: const Duration(milliseconds: 500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      buildUserInfo(),
                      // const SizedBox(height: 20),

                      // buildSearchSection(),
                      const SizedBox(height: 20),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'How can we help you?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff613089),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Circular Buttons for Services
                      SizedBox(
                        height: 130,
                        child: ListView(
                            physics: kIsWeb 
      ? const AlwaysScrollableScrollPhysics() 
      : const BouncingScrollPhysics(), 
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            buildCircleButton(
                              icon: FontAwesomeIcons.capsules,
                              label: 'Drugs',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OnlineMedicineHomePage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            buildCircleButton(
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
                            const SizedBox(width: 20),
                            buildCircleButton(
                              icon: Icons.monitor_heart,
                              label: 'Blood Pressure',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BloodPressureControlPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BloodDonationHome(),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
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
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Blood Donation',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            buildCircleButton(
                              icon: FontAwesomeIcons.userMd,
                              label: 'Find Doctor',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FindDoctorPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            buildCircleButton(
                              icon: Icons.fact_check,
                              label: 'Medical History',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicalHistoryPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            buildCircleButton(
                              icon: Icons.science,
                              label: 'Lab Tests',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LabTestsPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            buildCircleButton(
                              icon: Icons.note_alt,
                              label: 'Medical Notes',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicalNotesPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            buildCircleButton(
                              icon: Icons.medication,
                              label: 'Treatment Plans',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TreatmentPlansPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Popular Doctor Section
                      buildPopularDoctorSection(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
        ),
      bottomNavigationBar: isWeb
          ? null
          : CurvedNavigationBar(
              items: items,
              index: _selectedIndex,
              onTap: _onItemTapped,
              height: 70,
              backgroundColor: Colors.white,
              color: const Color(0xff613089),
              buttonBackgroundColor: const Color(0xff613089),
              animationDuration: const Duration(milliseconds: 300),
            ),
    );
  }

Widget buildDoctorCard(String name, String distance, String? base64Image, VoidCallback onTap) {
  ImageProvider backgroundImage;

  // فك تشفير الصورة باستخدام buildImageFromBase64
  try {
    if (base64Image != null && base64Image.isNotEmpty && base64Image != 'Unknown') {
      backgroundImage = buildImageFromBase64(base64Image).image;
      // print(" image: $base64Image");
    } else {
      backgroundImage = const AssetImage('assets/images/default_person.jpg');
    }
  } catch (e) {
    print("Error decoding image: $e");
    backgroundImage = const AssetImage('assets/images/default_person.jpg');
  }

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
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
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image(
              image: backgroundImage,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff613089),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

// "Popular Doctor" Section
Widget buildPopularDoctorSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Doctors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff613089),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     // Handle "See more" action
            //   },
            //   child: const Text(
            //     'See more',
            //     style: TextStyle(
            //       fontSize: 14,
            //       color: Color(0xff613089),
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 180,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : allDoctors.isEmpty
                ? 
                //  Center(
                //     child: Text(
                //       'No doctors available.',
                //       style: TextStyle(fontSize: 16, color: Colors.grey[500])
                //     ),
                //   )
                const Center(child: CircularProgressIndicator())
                :  
                ListView.builder(
                  
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: displayedDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = displayedDoctors[index];
                      return buildDoctorCard(
                        doctor['name'] as String,
                        '${doctor['averageRating']} ⭐',
                        doctor['image'] as String,
                         () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetailPage(
                          doctor: doctor,
                        ),
                      ),
                    );
                  },
                      );
                      
                    },
                  ),
      ),
      const SizedBox(height: 20),
    ],
  );
}

}

/////////////////////////////////

class TransparentScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;  
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const AlwaysScrollableScrollPhysics(); 
  }
}