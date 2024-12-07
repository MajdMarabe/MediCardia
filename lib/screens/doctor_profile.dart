import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formProfileKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController(text: "Dr. John Smith");
  final _emailController = TextEditingController(text: "johnsmith@example.com");
  final _phoneController = TextEditingController(text: "+1 234 567 8901");
  final _specializationController = TextEditingController(text: "Cardiologist");
  final _licenseNumberController = TextEditingController(text: "LIC12345678");
  final _workplaceNameController = TextEditingController(text: "City Hospital");
  final _workplaceAddressController = TextEditingController(text: "123 Main St, Springfield");
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  // FocusNodes for each text field
  final fullNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final specializationFocusNode = FocusNode();
  final licenseFocusNode = FocusNode();
  final workplaceNameFocusNode = FocusNode();
  final workplaceAddressFocusNode = FocusNode();

  Future<void> _editProfilePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FocusNode focusNode, // Add FocusNode here
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            focusNode: focusNode, // Attach FocusNode
            keyboardType: keyboardType,
            validator: validator ?? (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xff613089)),
              hintText: 'Enter $label',
              hintStyle: const TextStyle(color: Color(0xff613089)),
              prefixIcon: Icon(icon, color: const Color(0xff613089)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xffb41391), // Focused border color
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xff613089)),
          onPressed: () {
            setState(() {
              controller.clear(); // Clear the field when edit icon is clicked
              focusNode.requestFocus(); // Request focus on the field
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  backgroundColor: const Color(0xFFF2F5FF),
  appBar: AppBar(
    elevation: 0,
    centerTitle: true,
    backgroundColor: const Color(0xFFF2F5FF),
    title: const Text("Doctor Profile",
    style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),),
    automaticallyImplyLeading: false, 
  ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/images/doctor1.jpg') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _editProfilePhoto,
                        child: CircleAvatar(
                          backgroundColor: const Color(0xff613089),
                          radius: 20,
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields Section
              Form(
                key: _formProfileKey,
                child: Column(
                  children: [
                    _buildEditableField(
                      controller: _fullNameController,
                      label: "Full Name",
                      icon: Icons.person,
                      focusNode: fullNameFocusNode,
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      focusNode: emailFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter an email';
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _phoneController,
                      label: "Phone",
                      icon: Icons.phone,
                      focusNode: phoneFocusNode,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _specializationController,
                      label: "Specialization",
                      icon: Icons.work,
                      focusNode: specializationFocusNode,
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _licenseNumberController,
                      label: "License Number",
                      icon: Icons.badge,
                      focusNode: licenseFocusNode,
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _workplaceNameController,
                      label: "Workplace Name",
                      icon: Icons.business,
                      focusNode: workplaceNameFocusNode,
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      controller: _workplaceAddressController,
                      label: "Workplace Address",
                      icon: Icons.location_on,
                      focusNode: workplaceAddressFocusNode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Save Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff613089),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveProfile,
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formProfileKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _workplaceNameController.dispose();
    _workplaceAddressController.dispose();
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    specializationFocusNode.dispose();
    licenseFocusNode.dispose();
    workplaceNameFocusNode.dispose();
    workplaceAddressFocusNode.dispose();
    super.dispose();
  }
}
