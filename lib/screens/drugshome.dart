import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'drug_interaction_checker.dart';
import 'drug_info.dart';
import 'drugs_view.dart';

class OnlineMedicineHomePage extends StatefulWidget {
  @override
  _OnlineMedicineHomePageState createState() => _OnlineMedicineHomePageState();
}

class _OnlineMedicineHomePageState extends State<OnlineMedicineHomePage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _drugData;
  String? _errorMessage;

  Future<void> searchDrug(String drugName) async {
    final apiUrl = "${ApiConstants.baseUrl}/drugs/getDrugbyName?name=$drugName"; 

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _drugData = json.decode(response.body)['drug'];
          _errorMessage = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _drugData = null;
          _errorMessage = "Drug not found.";
        });
      } else {
        setState(() {
          _drugData = null;
          _errorMessage = "Error: ${response.statusCode}";
        });
      }
    } catch (error) {
      setState(() {
        _drugData = null;
        _errorMessage = "An error occurred. Please try again.";
      });
    }
  }

  void _showDrugDetailsDialog(Map<String, dynamic> drug) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(drug['Drugname'] ?? 'Unknown Drug'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Use: ${drug['details'][0]['Use']}"),
              Text("Dose: ${drug['details'][0]['Dose']}"),
              Text("Time: ${drug['details'][0]['Time']}"),
              Text("Notes: ${drug['details'][0]['Notes']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF6A4C9C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Gradient
              Text(
                "Medicine Hub",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4C9C),
                ),
              ),
              SizedBox(height: 24),
              // Gradient Background Effect
              Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9575CD), Color(0xFF6A4C9C)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Search Bar with Drop Shadow and Gradient Border
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Color(0xFF6A4C9C), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF6A4C9C), size: 28),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search for drugs.",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            searchDrug(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Option Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OptionButton(
                    icon: Icons.medical_services,
                    label: "Your Drugs",
                    backgroundColor: Color(0xFFD1A7E7),
                    iconColor: Color(0xFF6A4C9C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MedicineListPage()),
                      );
                    },
                  ),
                  OptionButton(
                    icon: Icons.integration_instructions,
                    label: "Interaction Checker",
                    backgroundColor: Color(0xFFB38DD3),
                    iconColor: Color(0xFF6A4C9C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DrugInteractionCheckerPage()),
                      );
                    },
                  ),
                  // Changed barcode icon to image
                  OptionButtonWithImage(
                    imagePath: 'assets/images/barcode.png', // Image for barcode
                    label: "Find by Barcode",
                    backgroundColor: Color(0xFF9575CD),
                    iconColor: Color(0xFF6A4C9C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DrugInfoPage()),
                      );
                    },
                  ),
                ],
              ),

              // Display Search Results with Images and Animation
              if (_drugData != null) ...[
                SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    _showDrugDetailsDialog(_drugData!);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF6A4C9C), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Add image of drug if available
                            if (_drugData!['image'] != null)
                              Image.network(
                                _drugData!['image'], // assuming image URL is provided
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            SizedBox(width: 16),
                            Text(
                              "Name: ${_drugData!['Drugname']}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A4C9C)),
                            ),
                          ],
                        ),
                        Text("Use: ${_drugData!['details'][0]['Use']}"),
                        SizedBox(height: 8),
                        Text("Tap to view more details", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ] else if (_errorMessage != null) ...[
                SizedBox(height: 32),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Option Button Widget with Animated Effect (for icon)
class OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  OptionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Color(0xFF6A4C9C))),
      ],
    );
  }
}

// Option Button with Image (for barcode option)
class OptionButtonWithImage extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  OptionButtonWithImage({
    required this.imagePath,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              imagePath,
              width: 32,
              height: 32,
              color: iconColor, // Optional: You can apply a color filter here if needed
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Color(0xFF6A4C9C))),
      ],
    );
  }
}
