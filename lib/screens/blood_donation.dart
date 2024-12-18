import 'package:flutter/material.dart';

class BloodDonationPage extends StatefulWidget {
  @override
  _BloodDonationPageState createState() => _BloodDonationPageState();
}

class _BloodDonationPageState extends State<BloodDonationPage> {
  // Blood group options
  final List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  String? selectedBloodType;

  // Units options
  final List<int> availableUnits = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  int? selectedUnit;

  // Controllers
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 
@override
Widget build(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  double dialogWidth = width > 600 ? width * 0.4 : width * 0.85;
  double dialogHeight = height > 600 ? 630 : height * 0.7;

  return Scaffold(
    backgroundColor: const Color(0xFFF2F5FF),
    body: Center(
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Form key for validation
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Center(
                  child: Text(
                    "Blood Donation Request",
                    style: TextStyle(
                      color: Color(0xff613089),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Blood Group Selection Row
                _buildLabel("Blood Type"),
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: bloodTypes.map((group) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedBloodType = group;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: selectedBloodType == group ? const Color(0xff613089) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedBloodType == group ? const Color(0xff613089) : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              group,
                              style: TextStyle(
                                color: selectedBloodType == group ? Colors.white : Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Blood Type Validation Message
                FormField<String>(
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message if validation fails
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 12,
                               
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  validator: (value) {
                    if (selectedBloodType == null || selectedBloodType!.isEmpty) {
                      return '  Please select a blood type';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Units Dropdown
                _buildLabel("Units required"),
                DropdownButtonFormField<int>(
                  value: selectedUnit,
                  items: availableUnits.map((unit) {
                    return DropdownMenuItem<int>(
                      value: unit,
                      child: Text('$unit unit(s)'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedUnit = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Select unit(s)",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    labelStyle: const TextStyle(color: Color(0xff613089)),
                    prefixIcon: const Icon(Icons.water_drop, color: Color(0xff613089)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xffb41391)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xff613089)),
                  validator: (value) {
                    if (value == null || value == 0) {
                      return 'Please select a unit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Hospital Name Input
                _buildLabel("Hospital name"),
                _buildTextFormField(
                  controller: _hospitalController,
                  hint: "Enter hospital name",
                  icon: Icons.local_hospital,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hospital name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Location Input
                _buildLabel("Location"),
                _buildTextFormField(
                  controller: _locationController,
                  hint: "Enter location",
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Phone Input
                _buildLabel("Phone number"),
                _buildTextFormField(
                  controller: _phoneController,
                  hint: "Enter phone number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),

                // Request Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff613089),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    ),
                    child: const Text(
                      "Request",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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




  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black54,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        labelStyle: const TextStyle(color: Color(0xff613089)),
        prefixIcon: Icon(icon, color: const Color(0xff613089)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xffb41391)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  String? validatePhoneNumber(String? value) {
    final phoneRegExp = RegExp(r'^\d{10}$');
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    } else if (!phoneRegExp.hasMatch(value)) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

 void _submitForm() {
  if (_formKey.currentState?.validate() ?? false) {
    // Validation successful
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Blood donation request submitted successfully!"),
        backgroundColor: Colors.green,
      ),
    );
    
    // You can add additional code here to handle the actual form submission,
    // such as sending the data to a server or saving it to a database.
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all fields correctly."),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

}
