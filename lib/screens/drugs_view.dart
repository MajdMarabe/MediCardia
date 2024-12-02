import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final storage = FlutterSecureStorage();

class MedicineListPage extends StatefulWidget {
  @override
  _MedicineListPageState createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  String? userId;
  List<Map<String, dynamic>> drugs = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();
final TextEditingController _drugNameController = TextEditingController();
 final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
// Variables
  String? _selectedDrugType;
  bool _isTemporary = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  // Fetch User ID from Secure Storage
  Future<void> _getUserId() async {
    userId = await storage.read(key: 'userid');
    if (userId != null) {
      _fetchDrugs(); // Fetch drugs once User ID is available
    }
  }

Future<void> _fetchDrugs() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/$userId/getUserDrugs'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> fetchedDrugs = data['drugs'];

      List<Map<String, dynamic>> drugDetailsList = [];

      for (var drug in fetchedDrugs) {
        final drugId = drug['drug']; // The drug ID
        
        // Fetch drug details based on drugId
        final drugDetailsResponse = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/drugs/$drugId'),
        );

        if (drugDetailsResponse.statusCode == 200) {
          final drugData = jsonDecode(drugDetailsResponse.body);
          
          final drugDetails = drugData['drug']['details']; // Assuming 'drugDetails' contains the detailed information

          final details = drugDetails.isNotEmpty ? drugDetails[0] : null;

          // Get the end date and check if the drug has expired
          final endDateStr = drug['usageEndDate'];

DateTime? endDate;
bool isExpired = false;

if (endDateStr != null) {
  endDate = DateTime.tryParse(endDateStr);
  if (endDate != null) {
    isExpired = endDate.isBefore(DateTime.now());
  }
}

drugDetailsList.add({
  'name': drugData['drug']['Drugname'] ?? 'Unknown',
  'barcode': drugData['Barcode'] ?? 'Unknown',
  'use': details?['Use'] ?? 'No use information',
  'dose': details?['Dose'] ?? 'No dose information',
  'time': details?['Time'] ?? 'No timing information',
  'notes': details?['Notes'] ?? 'No additional notes',
  'isPermanent': drug['isPermanent'],
  'usageStartDate': drug['usageStartDate'],
  'usageEndDate': drug['usageEndDate'],
  'isExpired': isExpired, // Add the expiry status
});
        } else {
          _showMessage('Failed to fetch drug details for ID $drugId');
        }
      }

      setState(() {
        drugs = drugDetailsList;
      });
    } else {
      _showMessage('Failed to fetch drugs: ${response.body}');
    }
  } catch (e) {
    _showMessage('Error: $e');
  }
}


  Future<void> _addDrug(String drugName, bool isTemporary, String? startDate, String? endDate) async {
  try {
    // Prepare the request body with additional fields
    final requestBody = {
      'drugName': drugName,
      'isPermanent': !isTemporary, // If it's not temporary, it's permanent
      'usageStartDate': isTemporary ? startDate : null,
      'usageEndDate': isTemporary ? endDate : null,
    };

    // Make the POST request to the API
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/users/$userId/adddrugs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      _showMessage('Drug added successfully');
      _fetchDrugs(); // Refresh the drug list
    } else {
      _showMessage('Failed to add drug: ${response.body}');
    }
  } catch (e) {
    _showMessage('Error: $e');
  }
}


  // Delete Drug for the User
  Future<void> _deleteDrug(String drugName) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/deletedrugs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'drugName': drugName}),
      );
      if (response.statusCode == 200) {
        _showMessage('deleted successfully $drugName');
        _fetchDrugs(); // Refresh the drug list
      } else {
        _showMessage('Failed to delete drug: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  // Show a message (Snackbar)
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

// Show the Add Drug Dialog with a more creative design and form fields
void _showAddDrugDialog() {
  // Reset the form fields before showing the dialog
  _drugNameController.clear();
  _startDateController.clear();
  _endDateController.clear();
  
  _selectedDrugType = 'Permanent'; // Default drug type
  _isTemporary = false; // Default value for temporary drugs

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog Title with Icon
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Color(0xff613089),
                        size: 40,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Add a New Drug',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff613089),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Drug Name Text Field with Custom Styling
                  TextFormField(
                    controller: _drugNameController,
                    decoration: InputDecoration(
                      labelText: 'Drug name',
                      labelStyle: const TextStyle(color: Color(0xff613089)),
                      prefixIcon: Icon(FontAwesomeIcons.capsules, color: Color(0xff613089)),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      filled: true,
                      fillColor: Color(0xFFF3F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff613089), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff613089), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Drug Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedDrugType,
                    items: ['Permanent', 'Temporary']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDrugType = value!;
                        _isTemporary = _selectedDrugType == 'Temporary'; // Update visibility of dates
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Drug Type',
                      labelStyle: const TextStyle(color: Color(0xff613089)),
                      prefixIcon: Icon(Icons.category, color: Color(0xff613089)),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      filled: true,
                      fillColor: Color(0xFFF3F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff613089), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xff613089), width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Show Start & End Dates only if Temporary is selected
                  // Show Start & End Dates only if Temporary is selected
if (_isTemporary)
  Column(
    children: [
      TextFormField(
        controller: _startDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Start Date',
          labelStyle: const TextStyle(color: Color(0xff613089)),
          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xff613089)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          filled: true,
          fillColor: const Color(0xFFF3F3F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xff613089), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xff613089), width: 2.0),
          ),
        ),
        onTap: () => _selectDateTime(context, _startDateController),
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: _endDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'End Date',
          labelStyle: const TextStyle(color: Color(0xff613089)),
          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xff613089)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          filled: true,
          fillColor: const Color(0xFFF3F3F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xff613089), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xff613089), width: 2.0),
          ),
        ),
        onTap: () => _selectDateTime(context, _endDateController),
      ),
    ],
  ),

                  const SizedBox(height: 16.0),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      ElevatedButton(
                        onPressed: () {
                          // Reset the fields when canceled
                          _drugNameController.clear();
                          _startDateController.clear();
                          _endDateController.clear();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xff613089),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Add Drug Button
                      ElevatedButton(
                        onPressed: () {
                          if (_drugNameController.text.isNotEmpty) {
                            _addDrug(_drugNameController.text, _isTemporary, _startDateController.text, _endDateController.text);
                            _drugNameController.clear();
                            _startDateController.clear();
                            _endDateController.clear();
                            Navigator.pop(context);
                          } else {
                            _showMessage('Please enter a drug name');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff613089),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                        child: const Text(
                          'Add Drug',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
  DateTime selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: const Color(0xff613089), // Apply same primary color as in the calendar
          hintColor: const Color(0xffb41391), // Accent color for selection
          buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      );
    },
  ) ?? DateTime.now();

  controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
}





  // Show Drug Details in a Dialog
  void _showDrugDetailsDialog(Map<String, dynamic> drug) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          drug['name'] ?? 'Unknown Drug',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.description, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Use: ${drug['use']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.medication, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Dose: ${drug['dose']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Time: ${drug['time']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.note, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Notes: ${drug['notes']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color(0xff613089),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}


// Function to build search section (full width)
Widget buildSearchSection() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: const Color(0xFF6A4C9C), width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF6A4C9C), size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return drugs
                      .map((drug) => drug['name'] as String)
                      .where((name) => name
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selectedDrug) {
                  setState(() {
                    searchController.text = selectedDrug;
                    drugs = drugs
                        .where((drug) => drug['name']!
                            .toLowerCase() ==
                            selectedDrug.toLowerCase())
                        .toList();
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController controller,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  searchController = controller;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search for drugs...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
       
      ],
    ),
  );
}

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
         backgroundColor: Colors.white,
         elevation: 0,
         centerTitle: true,
        title: const Text(
          'Medicines',
          style: TextStyle(fontWeight: FontWeight.bold,
        color: Color(0xff613089),
            letterSpacing: 1.5),
        ),
      
      ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Section
          buildSearchSection(),
          const SizedBox(height: 16),
          // Drugs Grid Section
          Expanded(
            child: drugs.isNotEmpty
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: drugs.length,
                    itemBuilder: (context, index) {
                      final drug = drugs[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        color: Colors.purple.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Placeholder Image or Icon
                              Container(
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.medical_services,
                                  size: 48,
                                  color: Color(0xff613089),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Drug Name
                              Text(
                                drug['name'] ?? 'Unknown Drug',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Drug Dose and Count
                              Text(
                                '${drug['dose']}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              // Expired Label (if applicable)
                              if (drug['isExpired'])
                                const Text(
                                  'Not Used',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Spacer(),
                              // Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showDrugDetailsDialog(drug),
                                    child: const Text(
                                      'View Details',
                                      style: TextStyle(
                                        color: Color(0xff613089),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,  color: Color(0xff613089)),
                                    onPressed: () {
                                      _deleteDrug(drug['name'] ?? '');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No drugs available')),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddDrugDialog,
      backgroundColor: const Color(0xff613089),
      child: const Icon(Icons.add),
    ),
  );
}

}