import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'user_profile.dart'; 
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'constants.dart';
import 'verification_code.dart';
import 'welcome_screen.dart';

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

  bool agreePersonalData = true;
  bool _obscureText = true;
  bool isLoading = false; 


  XFile? _imageFile;

  // Regular expression for email validation
  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Function to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _submitSignUp() async {
    if (!_formSignupKey.currentState!.validate() || !agreePersonalData) {
      if (!agreePersonalData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please agree to the processing of personal data')),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${ApiConstants.baseUrl}/doctors/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'password_hash': _passwordController.text,
          'phone': _phoneController.text,
          'specialization': _specializationController.text,
          'licenseNumber': _licenseNumberController.text,
          'workplaceName': _workplaceNameController.text,
          'workplaceAddress': _workplaceAddressController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final doctorId = responseData['_id'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful')),
        );

        // Clear form fields
        _formSignupKey.currentState!.reset();
        _fullNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _phoneController.clear();
        _specializationController.clear();
        _licenseNumberController.clear();
        _workplaceNameController.clear();
        _workplaceAddressController.clear();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerificationCodeScreen(
                  email: _emailController.text, flag: '2')),
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to sign up: ${errorResponse["message"] ?? "Unknown error"}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



Future<String?> encodeImageToBase64(XFile? imageFile) async {
  if (imageFile == null) return null;

  try {
    // Use XFile's bytes property to get the file's data as Uint8List
    final Uint8List bytes = await imageFile.readAsBytes();

    // Return the Base64-encoded string
    return base64Encode(bytes);
  } catch (e) {
    print('Error encoding image to Base64: $e');
    return null;
  }
}


Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 100,
  );

  if (pickedFile != null) {
    setState(() {
      _imageFile = pickedFile; 
    });

    if (kIsWeb) {
     
      print("Running on web platform");
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: kIsWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

Widget _buildWebLayout() {
  return Stack(
    children: [
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/c.jpeg'), 
            fit: BoxFit.cover,
          ),
        ),
      ),
        // AppBar for web
           Align(
  alignment: Alignment.topCenter,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/appLogo.png',
              height: 35,
              width: 35,
              color: const Color(0xff613089),
            ),
            // const SizedBox(width: 10),
            const Text(
              'MediCardia',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'BAUHS93',
                color: Color(0xff613089),
              ),
            ),
          ],
        ),
        Row(
          children: [
 TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
              child: const Text(
                'Home',
                style: TextStyle(
                  color: Color(0xff613089),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                 Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
              
              },
              child: const Text(
                'About',
                style: TextStyle(
                  color: Color(0xff613089),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Focus(
              onFocusChange: (hasFocus) {
                // Handle focus change if needed
                print("Sign Up button has focus: $hasFocus");
              },
              child: FocusScope(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xff613089), // Border color
                      width: 2.0, // Border width
                    ),
                    padding: const EdgeInsets.all(16), // Padding for better visibility
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xff613089),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),

      Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450, 
              maxHeight: 700, 
            ),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: _buildSignUpForm(),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}


  Widget _buildMobileLayout() {
    return CustomScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: _buildSignUpForm(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSignUpForm() {
    return Form(
      key: _formSignupKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Name
                const Column(
                        children: [
                          
                          Text(
                            'MediCardia', 
                            style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BAUHS93', 
                              color: Color(0xff613089),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
GestureDetector(
  onTap: _pickImage, 
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Circle avatar to hold the image or placeholder
       CircleAvatar(
              radius: 50, 
              backgroundColor: Colors.grey[300], 
              child: _imageFile != null 
                  ? kIsWeb
                      ? ClipOval(
                        child: Image.network(
                          _imageFile!.path, // Web uses Image.network
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      )
                      : ClipOval(
                          child: Image.file(
                            File(_imageFile!.path), // For mobile and desktop
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                  : const SizedBox.shrink(), // Placeholder for image
            ),
            
            if (_imageFile == null) ...[
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo, 
                    size: 24, 
                    color: Color(0xff613089), 
                  ),
                  SizedBox(height: 5), 
                  Text(
                    'Add Photo', 
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089), 
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
          const SizedBox(height: 20.0),

          _buildTextField(_fullNameController, 'Full Name', 'Enter Full Name',
              Icons.person),
          const SizedBox(height: 25.0),
          _buildTextField(
            _emailController,
            'Email',
            'Enter Email',
            Icons.email,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter Email';
              if (!_emailRegExp.hasMatch(value)) {
                return 'Please enter a valid Email';
              }
              return null;
            },
          ),
          const SizedBox(height: 25.0),
          _buildTextField(_phoneController, 'Phone', 'Enter Phone',
              Icons.phone, validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter Phone';
            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
              return 'Please enter a valid Phone number';
            }
            return null;
          }),
          const SizedBox(height: 25.0),
          _buildTextField(_specializationController, 'Specialization',
              'Enter Specialization', Icons.work),
          const SizedBox(height: 25.0),
         _buildTextField(
  _licenseNumberController,
  'License Number',
  'Enter License Number',
  Icons.badge,
  validator: (value) {
    if (value == null || value.isEmpty) return 'Please enter License Number';
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      return 'License Number must be exactly 8 digits';
    }
    return null;
  },
),

          const SizedBox(height: 25.0),
          _buildTextField(_workplaceNameController, 'Workplace Name',
              'Enter Workplace Name', Icons.business),
          const SizedBox(height: 25.0),
          _buildTextField(_workplaceAddressController, 'Workplace Address',
              'Enter Workplace Address', Icons.location_on),
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
              const Expanded(
                child: Text(
                    'I agree to the processing of personal data'),
              ),
            ],
          ),

          const SizedBox(height: 25.0),

          isLoading
              ? const CircularProgressIndicator(
                  color: Color(0xff613089),
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff613089),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: _submitSignUp,
                    child: const Text(
                      'Sign Up as Doctor',
                      style: TextStyle(
                          fontSize: 16.0,)
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData icon,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator ??
          (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff613089)),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400, 
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
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
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Color(0xff613089)),
        hintText: 'Enter Password',
        hintStyle: TextStyle(
          color: Colors.grey.shade400, 
          fontSize: 14, 
          fontStyle: FontStyle.italic, 
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.lock, color: Color(0xff613089)),
        suffixIcon: IconButton(
          icon: Icon(_obscureText
              ? Icons.visibility
              : Icons.visibility_off),
          color: const Color(0xff613089),
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
