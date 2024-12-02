import 'package:flutter/material.dart';
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final String token; // Accept the token from the previous screen

  const UpdatePasswordScreen({super.key, required this.token});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _newPasswordObscureText = true; // For new password visibility
  bool _confirmPasswordObscureText = true; // For confirm password visibility

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/resetPassword'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}', // Pass the token
        },
        body: jsonEncode({
          'token': widget.token,
          'newPassword': _newPasswordController.text,
          'confirmPassword': _confirmPasswordController.text
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );

        // Wait for 2 seconds, then navigate back to the LoginScreen
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        });

        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating password')),
        );
      }
    }
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _newPasswordObscureText = !_newPasswordObscureText;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _confirmPasswordObscureText = !_confirmPasswordObscureText;
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Update Your Password',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff613089),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Please enter your new password below.',
                        style: TextStyle(fontSize: 16.0, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // New Password
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _newPasswordObscureText, // Use the state variable
                        obscuringCharacter: '•',
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: const TextStyle(color: Color(0xff613089)),
                          hintText: 'Enter your new password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xffb41391), // Set focused border color
                              width: 2.0, // Set the border width to make it bold
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Color(0xff613089)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _newPasswordObscureText ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xff613089),
                            ),
                            onPressed: _toggleNewPasswordVisibility, // Toggle password visibility
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      
                      // Confirm New Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _confirmPasswordObscureText, // Use the state variable
                        obscuringCharacter: '•',
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          labelStyle: const TextStyle(color: Color(0xff613089)),
                          hintText: 'Re-enter your new password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xffb41391), // Set focused border color
                              width: 2.0, // Set the border width to make it bold
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Color(0xff613089)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordObscureText ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xff613089),
                            ),
                            onPressed: _toggleConfirmPasswordVisibility, // Toggle password visibility
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          } else if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Update Password Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff613089),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Update Password', style: TextStyle(fontSize: 16.0)),
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
}
