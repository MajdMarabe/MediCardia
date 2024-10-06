import 'package:flutter/material.dart';

class PublicInfo extends StatefulWidget {
  const PublicInfo({super.key});

  @override
  _PublicInfoState createState() => _PublicInfoState();
}

class _PublicInfoState extends State<PublicInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sensitivityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedChronicDisease;

  List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  List<String> chronicDiseases = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'None'
  ];

  DateTime? _lastDonationDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set background color to white
        child: Center( // Centering the form
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ID Number
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

                  // Age
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

                  // Blood Type
                  _buildDropdownField(
                    value: _selectedBloodType,
                    label: 'Blood Type',
                    hint: 'Select Blood Type',
                    icon: Icons.bloodtype,
                    items: bloodTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Chronic Diseases
                  _buildDropdownField(
                    value: _selectedChronicDisease,
                    label: 'Chronic Diseases',
                    hint: 'Select Chronic Disease',
                    icon: Icons.health_and_safety,
                    items: chronicDiseases,
                    onChanged: (value) {
                      setState(() {
                        _selectedChronicDisease = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Sensitivity
                  _buildTextFormField(
                    controller: _sensitivityController,
                    label: 'Sensitivity',
                    hint: 'Enter Sensitivity',
                    icon: Icons.safety_check,
                  ),
                  const SizedBox(height: 20),

                  // Date of Last Blood Donation
                  _buildDateField(),

                  const SizedBox(height: 20),

                  // Phone Number
                  _buildTextFormField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter Phone Number',
                    icon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle form submission
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User Info Submitted!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff613089),
                        minimumSize: const Size(double.infinity, 50), // Set button width
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom Text Form Field Builder
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff613089)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xff613089)),
        prefixIcon: Icon(icon, color: const Color(0xff613089)), // Icon for input fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
    color: Color(0xffb41391),  // Set focused border color
    width: 2.0,  // Set the border width to make it bold
  ),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // Custom Dropdown Field Builder
  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff613089)),
        border: OutlineInputBorder(
            borderSide: BorderSide(
    color: Color(0xffb41391),  // Set focused border color
    width: 2.0,  // Set the border width to make it bold
  ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Color(0xff613089)),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xff613089)), // Icon for dropdown
                  const SizedBox(width: 10),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Custom Date Field Builder
  Widget _buildDateField() {
    return GestureDetector(
      onTap: () {
        _showCustomDatePicker(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xff613089)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Color(0xff613089)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _lastDonationDate != null
                    ? "${_lastDonationDate!.day}/${_lastDonationDate!.month}/${_lastDonationDate!.year}"
                    : 'Select Date',
                style: TextStyle(
                  color: _lastDonationDate != null ? Colors.black : const Color(0xff613089),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 // Custom Date Picker Dialog
Future<void> _showCustomDatePicker(BuildContext context) async {
  final DateTime? pickedDate = await showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Select a date"),
        content: SizedBox(
          width: double.maxFinite, // Allow the dialog to take full width
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ensures the Column takes only necessary space
              children: [
                SizedBox(
                  height: 250,
                  child: CalendarDatePicker(
                    initialDate: _lastDonationDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    onDateChanged: (DateTime date) {
                      setState(() {
                        _lastDonationDate = date;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_lastDonationDate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff613089),
                  ),
                  child: const Text("Done"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (pickedDate != null) {
    setState(() {
      _lastDonationDate = pickedDate;
    });
  }
}


}
