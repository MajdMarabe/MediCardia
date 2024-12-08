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
import 'package:table_calendar/table_calendar.dart';
import 'drugshome.dart';
import 'viewdoctors.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    NotificationPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to build circular service buttons
  Widget buildCircleButton({
    required IconData icon, // Accepting IconData for the icon parameter
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
                color: const Color(0xff613089)), // Using IconData here
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

bool _isExpanded = false;
DateTime? _selectedDate;
List<String> chronicDiseases = ['Diabetes'];  
List<String> allergies = ['Penicillin'];  


String phoneNumber = '0598820544'; 
String lastDonationDate = '2024-11-19';  
String idNumber = '123456789';  

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
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/doctor1.jpg'),
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
              'Last Donation: $lastDonationDate', 
              (newValue) {
                setState(() {
                  lastDonationDate = newValue;  
                });
              },
              isDate: true, // Flag to indicate this is a date field
            ),
          
            buildEditableListRow(
                FontAwesomeIcons.heartbeat, 'Chronic diseases:', chronicDiseases,
                (newValue) {
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

Widget buildEditableRow(IconData icon, String text, Function(String) onSave, {bool isDate = false}) {
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
          icon: Icon(Icons.edit, color: Colors.white),
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

Widget buildEditableListRow(IconData icon, String title, List<String> list, Function(String) onAdd, Function(int) onRemove) {
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
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  onRemove(index);
                },
              ),
            ],
          );
        }).toList(),
        IconButton(
          icon: Icon(Icons.add, color: Colors.white),
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
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Add Information", style: TextStyle(color: Color(0xff613089))),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Enter new value',
            labelStyle: const TextStyle(color: Color(0xff613089)),
            prefixIcon: Icon(Icons.edit, color: Color(0xff613089)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff613089)),
            ),
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
              onAdd(controller.text);
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



void _showEditDialog(BuildContext context, String initialValue, Function(String) onSave) {
  TextEditingController controller = TextEditingController(text: '');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Information", style: TextStyle(color: Color(0xff613089))),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Enter new value',
            labelStyle: const TextStyle(color: Color(0xff613089)),
            prefixIcon: Icon(Icons.edit, color: Color(0xff613089)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff613089)),
            ),
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
              onSave(controller.text);  // Save the edited value
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff613089),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("Save"),
          ),
        ],
      );
    },
  );
}

Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(String) onSave) async {
  DateTime initialDate = DateTime.now();
  DateTime? selectedDate = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Last Donation Date', style: TextStyle(color: Color(0xff613089))),
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
                    controller.text = "${selectedDay.toLocal()}".split(' ')[0];  // Format the date
                    onSave(controller.text);  // Save the selected date
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

  if (selectedDate != null) {
    controller.text = "${selectedDate.toLocal()}".split(' ')[0];
    onSave(controller.text);  // Save the selected date
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
  Widget buildDoctorCard(String name, String distance, String imagePath) {
    return Container(
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
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
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
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              buildDoctorCard(
                  'Dr. Benedit Montero', '3.2 km', 'assets/images/doctor1.jpg'),
              buildDoctorCard(
                  'Dr. Pegang Globe', '5.7 km', 'assets/images/doctor2.jpg'),
              buildDoctorCard(
                  'Dr. Linda Brown', '4.1 km', 'assets/images/doctor3.jpg'),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: Stack(
        
        children: [
          _pages[_selectedIndex],
          if (_selectedIndex == 0)
            SingleChildScrollView(
              child: Column(
                children: [
                  // Animated Welcome Text
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
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

                  // User Info Card
                  buildUserInfo(),
                  const SizedBox(height: 20),

                  // Search Section
                  buildSearchSection(),
                  const SizedBox(height: 20),

                  // "How Can We Help You?" Text
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
                          icon: FontAwesomeIcons
                              .capsules, // Directly passing the FontAwesomeIcons
                          label: 'Drugs',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OnlineMedicineHomePage()),
                            );
                          },
                        ),
                        const SizedBox(width: 20),
                        buildCircleButton(
                          icon: Icons.bloodtype, // Icon for Diabetes Control
                          label: 'Diabetes',
                          onTap: () {
                            // Navigate to the Diabetes Control page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DiabetesControlPage(), // Replace with your Diabetes Control page
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
                                  builder: (context) => MedicalHistoryPage()),
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
                                  builder: (context) => LabTestsPage()),
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
                                  builder: (context) => MedicalNotesPage()),
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
                                  builder: (context) => TreatmentPlansPage()),
                            );
                          },
                        ),
                        const SizedBox(width: 20),
                        buildCircleButton(
                          icon: FontAwesomeIcons.userMd,
                          label: 'Find Doctor',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FindDoctorPage()),
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
      bottomNavigationBar: CurvedNavigationBar(
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
}
