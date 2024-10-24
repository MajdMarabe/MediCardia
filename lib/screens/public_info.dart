import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PublicInfo extends StatefulWidget {
  final String userId; // Accepting userId from the constructor

  const PublicInfo({super.key, required this.userId});

  @override
  _PublicInfoState createState() => _PublicInfoState();
}

class _PublicInfoState extends State<PublicInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sensitivityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _drugsController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedGender;
  List<String> _selectedChronicDiseases = [];
  String _userName = 'Loading...'; // Initialize username

  List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  List<String> genders = ['Male', 'Female'];
  List<Map<String, dynamic>> chronicDiseases = [
{'name': 'Diabetes', 'icon': Icons.bloodtype},
{'name': 'Hypertension', 'icon': Icons.monitor_heart},
{'name': 'Asthma', 'icon': Icons.air},
{'name': 'Cancer', 'icon': Icons.coronavirus},
{'name': 'Kidney Failure', 'icon': Icons.opacity},

    {'name': 'None', 'icon': Icons.check_circle_outline},
  ];

  DateTime? _lastDonationDate;
/////

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user's name when the widget is initialized
  }

  Future<void> _fetchUserName() async {
    String userId = widget.userId;
    String apiUrl = 'http://10.0.2.2:5001/api/users/$userId';

  
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userName = data['username'] ?? 'No Name'; // Set username
        });
      } else {
        print('Failed to load name, status code: ${response.statusCode}');
        print('Response body: ${response.body}'); // Log response for debugging
        setState(() {
          _userName = 'Unknown User'; // Fallback if the user is not found
        });
      }
    } catch (e) {
      print('Error fetching name: $e'); // Log the error for debugging
      setState(() {
        _userName = 'Error fetching name'; // Fallback on error
      });
    }
  }

//////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff613089), Color(0xffb41391)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Profile Header Section
            _buildProfileHeader(),
            const SizedBox(height: 20),

            // Scrollable Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Personal Info Section
                      _buildSectionTitle('Personal Info'),
                      const SizedBox(height: 10),
                      _buildTextFormField(
                        controller: _idNumberController,
                        label: 'ID Number',
                        hint: 'Enter ID Number',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length != 9) {
                            return 'Please enter a valid 9-digit ID number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _ageController,
                        label: 'Age',
                        hint: 'Enter Age',
                        icon: Icons.calendar_today,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        label: 'Gender',
                        hint: 'Select Gender',
                        items: genders,
                        selectedValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Medical Info Section
                      _buildSectionTitle('Medical Info'),
                      const SizedBox(height: 10),
                      _buildDropdownField(
                        label: 'Blood Type',
                        hint: 'Select Blood Type',
                        items: bloodTypes,
                        selectedValue: _selectedBloodType,
                        onChanged: (value) {
                          setState(() {
                            _selectedBloodType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Chronic Diseases',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff613089)),
                      ),
                      const SizedBox(height: 10),
                      _buildChronicDiseasesChips(),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _sensitivityController,
                        label: 'Allergies',
                        hint: 'Enter Allergies',
                        icon: Icons.safety_check,
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _drugsController,
                        label: 'Drugs',
                        hint: 'Enter Drugs',
                        icon: Icons.medical_services,
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerField(),
                      const SizedBox(height: 30),

                      // Submit Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _submitForm(); // Keep submit function as-is
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xffb41391),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Profile Header Section
  Widget _buildProfileHeader() {
    
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage('https://your_image_url_here.jpg'), // Replace with real image URL
        ),
        const SizedBox(height: 10),
        Text(
          _userName, // Display fetched username
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoCard('please fill it\nyou should know that every doctor can see this', 'Your MediCard public information', Icons.favorite),
           // _buildInfoCard('Calories', '756cal', Icons.local_fire_department),
          //  _buildInfoCard('Weight', '103lbs', Icons.monitor_weight),
          ],
        ),
      ],
    );
  }

  // Helper method to build information cards like in the header
  Widget _buildInfoCard(String title, String value, IconData icon) {
  return Container(
   // width: 100,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: const Color(0xffb41391)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xff613089),
        ),
      ),
    );
  }

  // Helper method to build text form fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xff613089)),
        prefixIcon: Icon(icon, color: const Color(0xff613089)),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // Helper method to build dropdown fields
  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xff613089)),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      value: selectedValue,
      onChanged: onChanged,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  // Helper method to build chronic diseases chips
  Widget _buildChronicDiseasesChips() {
    return Wrap(
      spacing: 10.0,
      children: chronicDiseases.map((disease) {
        final isSelected = _selectedChronicDiseases.contains(disease['name']);
        return FilterChip(
          label: Text(disease['name']),
          avatar: Icon(disease['icon'], color: isSelected ? Colors.white : Colors.black),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedChronicDiseases.add(disease['name']);
              } else {
                _selectedChronicDiseases.remove(disease['name']);
              }
            });
          },
          selectedColor: const Color(0xffb41391),
        );
      }).toList(),
    );
  }

  // Helper method to build date picker field
  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: _selectLastDonationDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Last Donation Date',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _lastDonationDate == null
              ? 'Select Last Donation Date'
              : _lastDonationDate.toString().split(' ')[0],
        ),
      ),
    );
  }

  // Method to select last donation date
  Future<void> _selectLastDonationDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _lastDonationDate = pickedDate;
      });
    }
  }

  // Keep the submit function the same as before
  Future<void> _submitForm() async {
  // Convert allergies (sensitivity) text input to an array by splitting on commas
  List<String> allergiesArray = _sensitivityController.text.split(',');

  // Prepare the data to send to the backend
  Map<String, dynamic> medicalInfo = {
    "publicData": {  // Wrapping the medical information inside "publicData"
      "idNumber": _idNumberController.text,
      "age": int.tryParse(_ageController.text) ?? 0, // Converting age to an integer
      "gender": _selectedGender,
      "bloodType": _selectedBloodType,
      "chronicConditions": _selectedChronicDiseases,
      "allergies": allergiesArray,
      "phoneNumber": _phoneController.text,
      "Drugs": _drugsController.text.split(','), // Ensure drugs are sent as a list
      "lastBloodDonationDate": _lastDonationDate?.toIso8601String(),
    }
  };

  String userId = widget.userId; // Retrieve the userId from widget
  try {
    // Make the PUT request to the backend
    String apiUrl = 'http://10.0.2.2:5001/api/users/${userId}/public-medical-card';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(medicalInfo),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical information updated successfully')),
      );
    } else {
      // If the server did not return a 200 OK response, throw an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update medical information')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }

  }
}
