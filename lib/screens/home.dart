import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_3/screens/profile.dart';
import 'package:flutter_application_3/screens/drugs_view.dart';
import 'drugshome.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final items = const [
    Icon(Icons.home, size: 30),
    Icon(FontAwesomeIcons.search, size: 30),
    Icon(Icons.notifications, size: 30),
    Icon(FontAwesomeIcons.userCircle, size: 30),
  ];

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Container(),
    const Center(child: Text('Search Page')),
    const Center(child: Text('Notifications')),
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
          child: Icon(icon, size: 40, color: const Color(0xff613089)), // Using IconData here
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


  // Function to build user info card
  Widget buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Age: 29',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Blood Type: O+',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              buildDoctorCard('Dr. Benedit Montero', '3.2 km', 'assets/images/doctor1.jpg'),
              buildDoctorCard('Dr. Pegang Globe', '5.7 km', 'assets/images/doctor2.jpg'),
              buildDoctorCard('Dr. Linda Brown', '4.1 km', 'assets/images/doctor3.jpg'),
             
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
      backgroundColor: const Color(0xfff2f4f8),
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
        icon: FontAwesomeIcons.capsules, // Directly passing the FontAwesomeIcons
        label: 'Drugs',
        onTap: () {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OnlineMedicineHomePage()),
      );     },
      ),
      const SizedBox(width: 20),
      buildCircleButton(
        icon: Icons.health_and_safety,
        label: 'Diseases',
        onTap: () {
          // Functionality for Diseases
        },
      ),
      const SizedBox(width: 20),
      buildCircleButton(
        icon: Icons.safety_check,
        label: 'Allergies',
        onTap: () {
          // Functionality for Allergies
        },
      ),
      const SizedBox(width: 20),
      buildCircleButton(
        icon: Icons.science,
        label: 'Lab Tests',
        onTap: () {
          // Functionality for Lab Tests
        },
      ),
      const SizedBox(width: 20),
      buildCircleButton(
        icon: FontAwesomeIcons.userMd,
        label: 'Ask Doctor',
        onTap: () {
          // Functionality for Ask Doctor
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
        color: Color(0xff613089),
        buttonBackgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
