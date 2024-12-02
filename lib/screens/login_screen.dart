import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/doctor_home.dart';
import 'package:flutter_application_3/screens/forget_passsword_screen.dart';
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:flutter_application_3/screens/user_home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http; // Import http package
import 'constants.dart';
import 'package:flutter_application_3/screens/select_type.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true; // To manage password visibility

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Function to handle the login process
  Future<void> login() async {
  if (_formSignInKey.currentState!.validate()) {
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logging in...'),
      ),
    );

    // Prepare the API request
    final url = Uri.parse('${ApiConstants.baseUrl}/users/login'); // Replace with your actual API URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': _emailController.text,
      'password_hash': _passwordController.text, // Ensure this matches your API's expected field
    });

    try {
      // Make the POST request
      final response = await http.post(url, headers: headers, body: body);

      // Check for a successful response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body); // Parse the response JSON
        final userid = responseData['_id']; // Extract the user ID
        final token = responseData['token']; // Extract the token
        final role = responseData['role']; // Extract the role from the response

        // Store the data locally
        await storage.write(key: 'userid', value: userid);
        await storage.write(key: 'token', value: token);
        final userJson = jsonEncode(responseData); // Convert the full response to JSON string
        await storage.write(key: 'user', value: userJson);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful! User ID: $userid')),
        );

        // Navigate based on role
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (role == 'patient') {
                return HomePage(); // Replace with the actual Patient's HomePage widget
              } else if (role == 'doctor') {
                return DoctorHomePage(); // Replace with the actual Doctor's HomePage widget
              } else {
                // Default return if no condition matches
                return HomePage(); // Replace with a fallback HomePage widget
              }
            },
          ),
        );
      } else {
        final errorMessage = jsonDecode(response.body)['message']; // Extract the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: $errorMessage')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}


  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
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
                  key: _formSignInKey,
                   child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo and App Name
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/appLogo.png', // Path to the logo
                            height: 100,
                            color: const Color(0xff613089), // Adjust color if needed
                          ),
                          const SizedBox(height: 10),
                          const Text(
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
                      const SizedBox(height: 40.0),
                      // Email Field with Icon
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          } else if (!_emailRegExp.hasMatch(value)) {
                            return 'Please enter a valid Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                              color: Color(0xff613089)), // Matching color
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                              color: Color(0xff613089)), // Matching color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(
                                  0xffb41391), // Set focused border color
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(FontAwesomeIcons.envelope,
                              color: Color(0xff613089)), // Email icon
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText, // Use the state variable
                        obscuringCharacter: '•',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
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
                          prefixIcon:
                              const Icon(Icons.lock, color: Color(0xff613089)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xff613089),
                            ),
                            onPressed:
                                _togglePasswordVisibility, // Toggle password visibility
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xffb41391),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25.0),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            if (_emailController.text.isEmpty ||
                                !_emailRegExp.hasMatch(_emailController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please enter a valid Email to reset password.'),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgetPasswordScreen(),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Forget password?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff613089), // Matching color
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: login, // Call the login function
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xff613089),
                                 // Set background color here
                          ),
                          child: const Text('Log in'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      // Social Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.black45),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),/*
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FaIcon(FontAwesomeIcons.facebookF,
                              color: Color(0xff613089)),
                          FaIcon(FontAwesomeIcons.twitter,
                              color: Color(0xff613089)),
                          FaIcon(FontAwesomeIcons.google,
                              color: Color(0xff613089)),
                          FaIcon(FontAwesomeIcons.apple,
                              size: 33, color: Color(0xff613089)),
                        ],
                      ),
                      const SizedBox(height: 25.0),*/
                      // Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AccountTypeSelectionScreen()),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff613089),
                              ),
                            ),
                          ),
                        ],
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
}