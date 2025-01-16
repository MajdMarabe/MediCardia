import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
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
  bool _newPasswordObscureText = true; 
  bool _confirmPasswordObscureText = true; 

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/resetPassword'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}', 
        },
        body: jsonEncode({
          'token': widget.token,
          'newPassword': _newPasswordController.text,
          'confirmPassword': _confirmPasswordController.text,
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
    return Scaffold(
      body: kIsWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  // Web Layout
  Widget _buildWebLayout() {
    return Stack(
      children: [
       
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/c.jpeg'), 
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Container(
            width: 500,
            height: 400,
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
            child: _buildUpdatePasswordForm(),
          ),
        ),
      ],
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout() {
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
              child: _buildUpdatePasswordForm(),
            ),
          ),
        ],
      ),
    );
  }

  // Shared Form
  Widget _buildUpdatePasswordForm() {
    return SingleChildScrollView(
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
              style: TextStyle(fontSize: 15.5, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // New Password
            TextFormField(
              controller: _newPasswordController,
              obscureText: _newPasswordObscureText,
              obscuringCharacter: '•',
              decoration: _buildPasswordFieldDecoration(
                'New Password',
                'Enter your new password',
                _toggleNewPasswordVisibility,
                _newPasswordObscureText,
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

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _confirmPasswordObscureText,
              obscuringCharacter: '•',
              decoration: _buildPasswordFieldDecoration(
                'Confirm New Password',
                'Re-enter your new password',
                _toggleConfirmPasswordVisibility,
                _confirmPasswordObscureText,
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
                child: const Text('Update Password',
                    style: TextStyle(fontSize: 16.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build password field decoration
  InputDecoration _buildPasswordFieldDecoration(
    String label,
    String hint,
    VoidCallback toggleVisibility,
    bool obscureText,
  ) {
    return InputDecoration(
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
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
        borderRadius: BorderRadius.circular(10),
      ),
      prefixIcon: const Icon(Icons.lock, color: Color(0xff613089)),
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xff613089)),
        onPressed: toggleVisibility,
      ),
    );
  }
}
