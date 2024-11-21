import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_3/screens/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'drug_interaction_checker.dart';
import 'drug_info.dart';

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
      backgroundColor: Color(0xfff6f8fc), // Soft background color
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
                  const SizedBox(height: 30),

                  // Box for Drug Interaction Checker
                  GestureDetector(
                    onTap: _navigateToDrugInteractionChecker,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10), // Slightly rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // Subtle shadow
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 5), // Slight lift effect
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.healing, size: 40, color: Color(0xff613089)),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Drug Interaction Checker',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff613089),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Check interactions between drugs',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Box for Drug Info from Barcode
                  GestureDetector(
                    onTap: _navigateToDrugInfoFromBarcode,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10), // Slightly rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // Subtle shadow
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 5), // Slight lift effect
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                    'assets/images/barcode.png', // The path to your image
                    width: 35,
                    height: 35,
                    color: Color(0xff613089),
                  ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Drug Info From Barcode',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff613089),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Scan barcodes to get drug details',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
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
        backgroundColor: Colors.white,
        color: Color(0xff613089),
        buttonBackgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
