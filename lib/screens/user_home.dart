import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/donation_requests.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_3/screens/user_profile.dart';
import 'package:flutter_application_3/screens/diabetes_control.dart';
import 'package:flutter_application_3/screens/medical_history_view.dart';
import 'package:flutter_application_3/screens/lab_tests_view.dart';
import 'package:flutter_application_3/screens/medical_notes_view.dart';
import 'package:flutter_application_3/screens/treatment_plans_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/foundation.dart';
import 'drugshome.dart';
import 'viewdoctors.dart';
import 'notification_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'dart:convert';
import 'blood_pressure.dart';

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
  String lastDonationDate = 'N/A'; 
String? base64Image ='';
  
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
    Icon(FontAwesomeIcons.search, size: 30, color: Colors.white),
    Icon(Icons.notifications, size: 30, color: Colors.white),
    Icon(FontAwesomeIcons.userCircle, size: 30, color: Colors.white),
  ];

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Container(),
    const Center(child: Text('Search Page')),
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

  
  // Function to build circular service buttons
  Future<void> fetchDoctors() async {
  try {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/rating/top/rated'));

    if (kDebugMode) {
      print("The response is: ${response.body}");
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> doctorsData = jsonResponse['data']; // استخراج قائمة الأطباء

      setState(() {
        allDoctors = doctorsData.map((doc) {
          return {
            'id': doc['id'], // لاحظ التعديل هنا
            'name': doc['name'] ?? 'Unknown',
            'specialty': doc['speciality'] ?? 'Unknown',
            'averageRating': doc['averageRating'] ?? 0.0,
            'image':  'assets/images/doctor1.jpg',
            'phone': doc['phone'] ?? 'No phone number provided',
            'numberOfPatients': doc['numberOfPatients'] ?? 0,
            'numberOfReviews': doc['numberOfReviews'] ?? 0,
            'workplace': {
              'name': doc['workplace']?['name'] ?? 'No workplace name',
              'address': doc['workplace']?['address'] ?? 'No address',
            },
          };
        }).toList();

        doctorNames = allDoctors.map((doctor) => doctor['name'] as String).toList();
        displayedDoctors = List.from(allDoctors);
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
  final String ? userid =  await storage.read(key: 'userid');
  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/$userid'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        username = data['username'] ?? 'Unknown';
        gender = data['medicalCard']?['publicData']?['gender'] ?? 'Unknown';
        bloodType = data['medicalCard']?['publicData']?['bloodType'] ?? 'Unknown';
        age = data['medicalCard']?['publicData']?['age'] ?? 0;
        phoneNumber = data['medicalCard']?['publicData']?['phoneNumber'] ?? 'N/A';
        lastDonationDate =
            data['medicalCard']?['publicData']?['lastBloodDonationDate'] ?? 'N/A';
        chronicDiseases = List<String>.from(
          data['medicalCard']?['publicData']?['chronicConditions'] ?? [],
        );
        allergies = List<String>.from(
          data['medicalCard']?['publicData']?['allergies'] ?? [],
        );
        base64Image=data['medicalCard']?['publicData']?['image'] ?? 'Unknown';
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
            child: Icon(icon,
                size: 40,
                color: const Color(0xff613089)), 
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
                            TextSpan(
                                text: '  Age: $age | Gender: $gender'),
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
              buildInfoRow(Icons.credit_card, 'ID Number: 123456789'),
              buildEditableRow(Icons.phone, 'Phone: $phoneNumber', (newValue) {
                setState(() {
                  phoneNumber = newValue;
                });
              }),
              buildEditableRow(
                Icons.calendar_today,
                'Last Donation: ${formatDate(lastDonationDate)}',
                (newValue) {
                  setState(() {
                    lastDonationDate = newValue;
                  });
                },
                isDate: true,
              ),
              buildEditableListRow(FontAwesomeIcons.heartbeat,
                  'Chronic diseases:', chronicDiseases, (newValue) {
                setState(() {
                  chronicDiseases.add(newValue);
                });
              }, (index) {
                setState(() {
                  chronicDiseases.removeAt(index);
                });
              }),
              buildEditableListRow(Icons.warning, 'Allergies:', allergies,
                  (newValue) {
                setState(() {
                  allergies.add(newValue);
                });
              }, (index) {
                setState(() {
                  allergies.removeAt(index);
                });
              }),
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


  


  Widget buildEditableRow(IconData icon, String text, Function(String) onSave,
      {bool isDate = false}) {
    TextEditingController controller = TextEditingController(text: text);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              if (isDate) {
                _selectDate(context, controller, onSave);
              } else {
                _showEditDialog(context, controller.text, onSave);
              }
            },
          ),
        ],
      ),
    );
  }



  Widget buildEditableListRow(IconData icon, String title, List<String> list,
      Function(String) onAdd, Function(int) onRemove) {
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
              _showAddDialog(context, onAdd);
            },
          ),
        ],
      ),
    );
  }



  void _showAddDialog(BuildContext context, Function(String) onAdd) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9;

      double dialogHeight = MediaQuery.of(context).size.height > 900
          ? 200
          : MediaQuery.of(context).size.height * 0.3;

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
            "Add Information",
            style: TextStyle(
              color: Color(0xff613089),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Enter new value',
              labelStyle: TextStyle(color: Color(0xff613089)),
              prefixIcon: Icon(Icons.edit, color: Color(0xff613089)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff613089)),
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
                  onAdd(controller.text);
                  Navigator.pop(context);
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




  void _showEditDialog(
      BuildContext context, String initialValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: '');

    showDialog(
      context: context,
      builder: (context) {
                double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9;

      double dialogHeight = MediaQuery.of(context).size.height > 900
          ? 200
          : MediaQuery.of(context).size.height * 0.3;

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
            "Edit Information",
            style: TextStyle(
              color: Color(0xff613089),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Enter new value',
              labelStyle: TextStyle(color: Color(0xff613089)),
              prefixIcon: Icon(Icons.edit, color: Color(0xff613089)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff613089)),
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
                  onSave(controller.text); 
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



/////////////////////////


  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, Function(String) onSave) async {
    DateTime initialDate = DateTime.now();
    DateTime? selectedDate = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Last Donation Date',
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
                    focusedDay: initialDate,
                    onDaySelected: (selectedDay, focusedDay) {
                      controller.text = "${selectedDay.toLocal()}"
                          .split(' ')[0]; // Format the date
                      onSave(controller.text); 
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
                      titleTextStyle:
                          TextStyle(color: Color(0xff613089), fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDate != null) {
      controller.text = "${selectedDate.toLocal()}".split(' ')[0];
      onSave(controller.text); 
    }
  }

  // Function to build search section
  Widget buildSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Row(
        children: [
          const Icon(Icons.search, size: 30, color: Color(0xff613089)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for doctor,  etc.',
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Function to build doctor cards
  Widget buildDoctorCard(String name, String distance, String imagePath, VoidCallback onTap) {
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
            child: Image.asset(
              imagePath,
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
                icon: const Icon(Icons.home, color: Color(0xff613089), size: 20),
                tooltip: 'Home',
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.search, color: Color(0xff613089), size: 20),
                tooltip: 'Search',
                onPressed: () => _onItemTapped(1),
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xff613089), size: 20),
                tooltip: 'Notifications',
                onPressed: () => _onItemTapped(2),
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.userCircle, color: Color(0xff613089), size: 20),
                tooltip: 'Profile',
                onPressed: () => _onItemTapped(3),
              ),
              const SizedBox(width: 15),
            ],
          )
        : null,
    body: Center(
      child: Container(
      
       width: MediaQuery.of(context).size.width > 600 
          ? MediaQuery.of(context).size.width * 0.75 
          : MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            _pages[_selectedIndex],
            if (_selectedIndex == 0)
              SingleChildScrollView(
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
                    const SizedBox(height: 20),

               
                    buildSearchSection(),
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
                                  builder: (context) => OnlineMedicineHomePage(),
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
                               const SizedBox(width: 20),                       
                            GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationRequestsPage(),
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
            color:const Color(0xff613089) ,
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
                                  builder: (context) => const FindDoctorPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Popular Doctor Section
                    buildPopularDoctorSection(),
                  ],
                ),
              ),
          ],
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
// "Popular Doctor" Section
Widget buildPopularDoctorSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Doctors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff613089),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle "See more" action
              },
              child: const Text(
                'See more',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff613089),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 180,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : allDoctors.isEmpty
                ? const Center(
                    child: Text(
                      'No doctors available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
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