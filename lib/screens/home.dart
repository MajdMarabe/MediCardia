import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_3/screens/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'drug_interaction_checker.dart';
import 'drug_info.dart'; // Import the new page

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

  // List of pages to navigate to
  final List<Widget> _pages = [
    Container(), // Home page is initially empty
    const Center(child: Text('Search Page')),
    const Center(child: Text('Add Page')),
    ProfilePage(), // Link to the ProfilePage here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to navigate to the DrugInteractionCheckerPage
  void _navigateToDrugInteractionChecker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DrugInteractionCheckerPage()),
    );
  }

  // Function to navigate to the DrugInfoFromBarcodePage
  void _navigateToDrugInfoFromBarcode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DrugInfoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe0c3fc), // Match your gradient colors
      appBar: AppBar(
        title: const Text(
          'MediCardia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff613089),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex], // Show the selected page

          // Add the "Drug Interaction" section within Home Page content
          if (_selectedIndex == 0) // Only show in the 'Home Page' section
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to MediCardia',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Drug Interaction Checker
                  GestureDetector(
                    onTap: _navigateToDrugInteractionChecker,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      decoration: BoxDecoration(
                        color: Color(0xff613089),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 5),
                            color: Color(0xff613089).withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.medical_services, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Drug Interaction Checker',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Drug Info from Barcode
                  GestureDetector(
                    onTap: _navigateToDrugInfoFromBarcode,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      decoration: BoxDecoration(
                        color: Color(0xff613089),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 5),
                            color: Color(0xff613089).withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         Image.asset(
                    'assets/images/barcode.png', // The path to your image
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                          const SizedBox(width: 10),
                          const Text(
                            'Drug Info From Barcode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        backgroundColor: Colors.transparent,
        color: Color(0xff613089),
        buttonBackgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
