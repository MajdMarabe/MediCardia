import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; 
import '../theme/theme.dart'; 
import 'update_password.dart'; 
import 'package:flutter_application_3/widgets/custom_scaffold.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationCodeScreen extends StatefulWidget {
  final String email; // Add email parameter to send with verification code

  const VerificationCodeScreen({super.key, required this.email});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentText = "";

  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5001/api/users/verifyCode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
         // 'email': widget.email,
          'verificationCode': _currentText,
        }),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token']; // Get the token
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdatePasswordScreen(token: token),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid verification code')),
        );
      }
    }
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
                      Text(
                        'Verification Code',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: lightColorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'We have sent a verification code to your email.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40.0),
                      PinCodeTextField(
                        appContext: context,
                        length: 4,
                        keyboardType: TextInputType.number,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 60,
                          fieldWidth: 50,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          activeColor: lightColorScheme.primary,
                          selectedColor: lightColorScheme.secondary,
                          inactiveColor: Colors.grey,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        onCompleted: (v) {
                          setState(() {
                            _currentText = v;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _currentText = value;
                          });
                        },
                        beforeTextPaste: (text) {
                          return true;
                        },
                      ),
                      const SizedBox(height: 40.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightColorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontSize: 16.0),
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
}
