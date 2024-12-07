import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_application_3/screens/verification_code.dart';

class SignUpDoctorScreen extends StatefulWidget {
  const SignUpDoctorScreen({super.key});

  @override
  State<SignUpDoctorScreen> createState() => _SignUpDoctorScreenState();
}

class _SignUpDoctorScreenState extends State<SignUpDoctorScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _workplaceNameController = TextEditingController();
  final _workplaceAddressController = TextEditingController();

  File? _image;
  bool agreePersonalData = true;
  bool _obscureText = true;

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Image picker method
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitSignUp() async {
    if (!_formSignupKey.currentState!.validate() || !agreePersonalData) {
      if (!agreePersonalData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the processing of personal data')),
        );
      }
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/doctors/register');
    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['fullName'] = _fullNameController.text
        ..fields['email'] = _emailController.text
        ..fields['password_hash'] = _passwordController.text
        ..fields['phone'] = _phoneController.text
        ..fields['specialization'] = _specializationController.text
        ..fields['licenseNumber'] = _licenseNumberController.text
        ..fields['workplaceName'] = _workplaceNameController.text
        ..fields['workplaceAddress'] = _workplaceAddressController.text;

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final doctorId = jsonDecode(responseData)['_id'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerificationCodeScreen(email: _emailController.text, flag: '2')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Logo and Name
                      const Column(
                        children: [
                          
                          Text(
                            'MediCardia', // App name
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BAUHS93', // Set font family
                              color: Color(0xff613089),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

GestureDetector(
  onTap: _pickImage, // Function to select an image
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Circle avatar to hold the image or placeholder
      CircleAvatar(
        radius: 60, // Size of the avatar
        backgroundColor: Colors.grey[300], // Background color for the placeholder
        child: _image == null
            ? const SizedBox.shrink() // If no image, display nothing
            : ClipOval(
                child: Image.file(
                  _image!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover, // Ensure the image fills the circle
                ),
              ),
      ),
      // If there is no image, show the icon and text inside the circle
      if (_image == null) ...[
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo, // Icon for adding a photo
              size: 24, // Icon size
              color: Color(0xff613089), // Icon color
            ),
            SizedBox(height: 5), // Space between icon and text
            Text(
              'Add Photo', // Placeholder text
              style: TextStyle(
                fontSize: 12, // Size of the text
                fontWeight: FontWeight.bold,
                color: Color(0xff613089), // Text color
              ),
            ),
          ],
        ),
      ],
    ],
  ),
),

                      const SizedBox(height: 25.0),

                      _buildTextField(_fullNameController, 'Full Name', 'Enter Full Name', Icons.person),
                      const SizedBox(height: 25.0),
                      _buildTextField(_emailController, 'Email', 'Enter Email', Icons.email, validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter Email';
                        if (!_emailRegExp.hasMatch(value)) return 'Please enter a valid Email';
                        return null;
                      }),
                      const SizedBox(height: 25.0),
                      _buildTextField(_phoneController, 'Phone', 'Enter Phone', Icons.phone),
                      const SizedBox(height: 25.0),
                      _buildTextField(_specializationController, 'Specialization', 'Enter Specialization', Icons.work),
                      const SizedBox(height: 25.0),
                      _buildTextField(_licenseNumberController, 'License Number', 'Enter License Number', Icons.badge),
                      const SizedBox(height: 25.0),
                      _buildTextField(_workplaceNameController, 'Workplace Name', 'Enter Workplace Name', Icons.business),
                      const SizedBox(height: 25.0),
                      _buildTextField(_workplaceAddressController, 'Workplace Address', 'Enter Workplace Address', Icons.location_on),
                      const SizedBox(height: 25.0),
                      _buildPasswordField(),
                      const SizedBox(height: 25.0),

                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (value) {
                              setState(() {
                                agreePersonalData = value ?? false;
                              });
                            },
                            activeColor: const Color(0xff613089),
                          ),
                          const Text('I agree to the processing of personal data'),
                        ],
                      ),

                      const SizedBox(height: 25.0),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff613089),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _submitSignUp,
                          child: const Text(
                            'Sign Up as Doctor',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator ?? (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff613089)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xff613089)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(icon, color: const Color(0xff613089)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xffb41391),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      obscuringCharacter: '•',
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a password';
        if (value.length < 6) return 'Password must be at least 6 characters long';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Color(0xff613089)),
        hintText: 'Enter Password',
        hintStyle: const TextStyle(color: Color(0xff613089)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.lock, color: Color(0xff613089)),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: const Color(0xff613089)),
          onPressed: _togglePasswordVisibility,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xffb41391),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
