import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:pin_code_fields/pin_code_fields.dart';
import 'update_password.dart';
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:flutter_application_3/screens/public_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class VerificationCodeScreen extends StatefulWidget {
  final String email; 
  final String flag;
  const VerificationCodeScreen({super.key, required this.email, required this.flag});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentText = "";

  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/verifyCode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'verificationCode': _currentText,
        }),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        final userId = await storage.read(key: 'userid') ?? 'default_user_id';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              switch (widget.flag) {
                case '1':
                  return UpdatePasswordScreen(token: token);
                case '2':
                  return const SignInScreen();
                case '3':
                  return PublicInfo(userId: userId);
                default:
                  return const SignInScreen();
              }
            },
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
    return Scaffold(
      body: kIsWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  // Web Layout
  Widget _buildWebLayout() {
    return Stack(
      children: [
        // Background for Web
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/c.jpeg'), 
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
            child: _buildVerificationForm(),
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
              child: _buildVerificationForm(),
            ),
          ),
        ],
      ),
    );
  }

  // Shared Verification Form
  Widget _buildVerificationForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Enter Verification Code',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w900,
                color: Color(0xff613089),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'We have sent a verification code to your email.',
              style: TextStyle(fontSize: 16.0, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40.0),

            // Verification Code Input Field
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
                activeColor: const Color(0xff613089),
                selectedColor: const Color(0xffb41391),
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
              beforeTextPaste: (text) => true,
            ),
            const SizedBox(height: 40.0),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff613089),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
