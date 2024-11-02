import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_3/screens/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final items = const [
    Icon(Icons.home, size: 30),
    Icon(FontAwesomeIcons.search, size: 30),
    Icon(Icons.add, size: 30),
    Icon(FontAwesomeIcons.userCircle, size: 30),
  ];

  int _selectedIndex = 0;

  // List of pages to navigate to
  final List<Widget> _pages = [
    Center(child: Text('Home Page')),
    Center(child: Text('Search Page')),
    Center(child: Text('Add Page')),
    ProfilePage(), // Link to the ProfilePage here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe0c3fc), // Match your gradient colors
      appBar: AppBar(
        title: Text(
          'MediCardia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff613089),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex], // Show the selected page
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
