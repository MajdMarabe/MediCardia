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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Text(
                    "Medicine \nHub",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A4C9C), 
                    ),
                  ),
                  SizedBox(height: 24),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey, size: 28),
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

                  Text(
                    "How can we help you?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Your Drugs Page
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
                        label: "Integration Checker",
                        backgroundColor: Color(0xFFB38DD3), 
                        iconColor: Color(0xFF6A4C9C),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DrugInteractionCheckerPage()),
                          );
                        },
                      ),
                      OptionButton(
                        icon: Icons.qr_code_scanner,
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

                  if (_drugData != null) ...[
                    Text(
                      "Search Result:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        _showDrugDetailsDialog(_drugData!);
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF6A4C9C), width: 2), 
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name: ${_drugData!['Drugname']}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A4C9C)),
                            ),
                            Text("Use: ${_drugData!['details'][0]['Use']}"),
                            SizedBox(height: 8),
                            Text("Tap to view more details", style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
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
