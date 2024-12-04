import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'drug_interaction_checker.dart';
import 'drug_info_barcode.dart';
import 'drugs_view.dart';

class OnlineMedicineHomePage extends StatefulWidget {
  @override
  _OnlineMedicineHomePageState createState() => _OnlineMedicineHomePageState();
}

class _OnlineMedicineHomePageState extends State<OnlineMedicineHomePage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _drugData;
  String? _errorMessage;
  List<String> _suggestions = []; // قائمة الاقتراحات
  bool _isFetchingSuggestions = false;

  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final apiUrl = "${ApiConstants.baseUrl}/drugs//getDrug/Suggestions?query=$query";

    try {
      setState(() {
        _isFetchingSuggestions = true;
      });

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _suggestions = List<String>.from(data['suggestions'].map((item) => item['Drugname']));
          _errorMessage = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _suggestions = [];
          _errorMessage = "No suggestions found.";
        });
      } else {
        setState(() {
          _suggestions = [];
          _errorMessage = "Error: ${response.statusCode}";
        });
      }
    } catch (error) {
      setState(() {
        _suggestions = [];
        _errorMessage = "An error occurred. Please try again.";
      });
    } finally {
      setState(() {
        _isFetchingSuggestions = false;
      });
    }
  }

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
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FF),
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
              Text(
                "Medicine Hub",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4C9C),
                ),
              ),
              SizedBox(height: 24),
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

              // Search Bar with Auto Complete
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
                child: Column(
                  children: [
                    Row(
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
                            onChanged: (value) {
                              fetchSuggestions(value);
                            },
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                searchDrug(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_suggestions.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_suggestions[index]),
                            onTap: () {
                              _searchController.text = _suggestions[index];
                              _suggestions.clear();
                              searchDrug(_searchController.text);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: 32),

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
                  OptionButtonWithImage(
                    imagePath: 'assets/images/barcode.png',
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
              SizedBox(height: 15),
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
      
                            if (_drugData!['image'] != null)
                              Image.network(
                                _drugData!['image'],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            //SizedBox(width: 16),
                            Text(
                              "Name: ${_drugData!['Drugname']}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A4C9C)),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text("Use: ${_drugData!['details'][0]['Use']}"),
                        SizedBox(height: 8),
                        Text("Dose: ${_drugData!['details'][0]['Dose']}"),
                      ],
                    ),
                  ),
                ),   
              ],
              if (_errorMessage != null)
                Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),

                  ),
                ),
            ],
          ),
        ),
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

  OptionButton({required this.icon, required this.label, required this.backgroundColor, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionButtonWithImage extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  OptionButtonWithImage({required this.imagePath, required this.label, required this.backgroundColor, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 40, height: 40, color: iconColor),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
