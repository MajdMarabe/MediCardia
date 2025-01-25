import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:flutter_application_3/screens/verification_code.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class ApiService {
  Future<bool> forgetPassword(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/users/forgetPassword'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    return response.statusCode == 200;
  }
}

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/u1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 450,
              height: 350,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: _buildForm(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 20),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: _buildForm(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Forgot Your Password?',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Color(0xff613089),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          const Text(
            'Enter your email below and we will send you verification code to reset your password.',
            style: TextStyle(fontSize: 14.0, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30.0),
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: Color(0xff613089)),
              hintText: 'Enter your email',
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
              prefixIcon: const Icon(FontAwesomeIcons.envelope, color: Color(0xff613089)),
            ),
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  bool success = await apiService.forgetPassword(_emailController.text);
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerificationCodeScreen(
                          email: _emailController.text,
                          flag: '1',
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset instructions sent'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to send reset instructions. Please try again.'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff613089),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Send',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
