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
  List<String> _selectedChronicDiseases = [];

  List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  List<Map<String, dynamic>> chronicDiseases = [
    {'name': 'Diabetes', 'icon': Icons.healing},
    {'name': 'Hypertension', 'icon': Icons.favorite},
    {'name': 'None', 'icon': Icons.check_circle_outline},
  ];

  DateTime? _lastDonationDate;
  final FocusNode _dateFieldFocusNode = FocusNode(); // FocusNode for date field

  @override
  void initState() {
    super.initState();
    _dateFieldFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _dateFieldFocusNode.dispose(); // Dispose of the FocusNode
    super.dispose();
  }

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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Adding the new text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0), // Generous vertical padding
                    child: Column(
                      children: [
                        // Text with a gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xff613089), // Start color
                                const Color(0xffb41391), // End color
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(10.0), // Inner padding
                          child: Text(
                            'Enter your public medical information.',
                            style: TextStyle(
                              fontSize: 24, // Increased font size for better visibility
                              fontWeight: FontWeight.bold, // Bold font for emphasis
                              color: Colors.white, // White text color for contrast
                              letterSpacing: 1.5, // Space between letters for elegance
                              shadows: [
                                Shadow(
                                  blurRadius: 8.0, // Increased blur for a soft shadow
                                  color: Colors.black.withOpacity(0.3), // Soft black shadow
                                  offset: const Offset(4.0, 4.0), // Shadow offset for depth
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ),
                        const SizedBox(height: 10), // Space between text and next element
                    
                      ],
                    ),
                  ),


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

                  // Blood Type with Validation
                  FormField<String>(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a blood type';
                      }
                      return null;
                    },
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Blood Type',
                          labelStyle: const TextStyle(color: Color(0xff613089)),
                          errorText: state.hasError ? state.errorText : null,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xffb41391),
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedBloodType,
                            hint: const Text(
                              'Select Blood Type',
                              style: TextStyle(color: Color(0xff613089)),
                            ),
                            items: bloodTypes.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Row(
                                  children: [
                                    const Icon(Icons.bloodtype, color: Color(0xff613089)),
                                    const SizedBox(width: 10),
                                    Text(item),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBloodType = value;
                                state.didChange(value);  // Update the FormField state
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

// Chips for Chronic Diseases
const Text(
  ' Select Chronic Diseases',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff613089)),
),
const SizedBox(height: 10),
Wrap(
  spacing: 8.0,
  children: chronicDiseases.map((disease) {
    bool isSelected = _selectedChronicDiseases.contains(disease['name']); // Check if selected
    return ChoiceChip(
      label: Row(
        children: [
          Icon(
            disease['icon'],
            color: isSelected ? Colors.white : const Color(0xff613089), // Change icon color based on selection
          ),
          const SizedBox(width: 5),
          Text(
            disease['name'],
            style: TextStyle(color: isSelected ? Colors.white : Colors.black), // Change text color based on selection
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: const Color(0xff613089),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedChronicDiseases.add(disease['name']);
          } else {
            _selectedChronicDiseases.remove(disease['name']);
          }
        });
      },
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }).toList(),
),



                  const SizedBox(height: 20),

                  // Sensitivity (No validation)
                  _buildTextFormField(
                    controller: _sensitivityController,
                    label: 'Sensitivity',
                    hint: 'Enter Sensitivity',
                    icon: Icons.safety_check,
                  ),
                  const SizedBox(height: 20),

                  // Date of Last Blood Donation (No validation)
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
                        minimumSize: const Size(360, 50),
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
        prefixIcon: Icon(icon, color: const Color(0xff613089)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xffb41391),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
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
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: _dateFieldFocusNode.hasFocus 
                ? const Color(0xffb41391) // Focused border color
                :   const Color(0xff959695),// Normal border color
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Color(0xff613089)),
            const SizedBox(width: 10), // Adds some space between the icon and text
            Text(
              _lastDonationDate != null
                  ? 'Last Donation: ${_lastDonationDate!.day}/${_lastDonationDate!.month}/${_lastDonationDate!.year}'
                  : 'Select Last Donation Date',
              style: TextStyle(
                color: _lastDonationDate != null ? Colors.black : const Color(0xff613089),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Date Picker Dialog
  Future<void> _showCustomDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff613089),
              onPrimary: Colors.white,
              onSurface: Color(0xff613089),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff613089),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _lastDonationDate = selectedDate;
      });
    }
  }
}
