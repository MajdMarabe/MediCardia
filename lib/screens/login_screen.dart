import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/admin_home_mobile.dart';
import 'package:flutter_application_3/screens/doctor_home.dart';
import 'package:flutter_application_3/screens/forget_passsword_screen.dart';
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:flutter_application_3/screens/user_home.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_application_3/screens/select_type.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'welcome_screen.dart';
import 'user_profile.dart';
import 'admin_home.dart';

const storage = FlutterSecureStorage();

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  Future<void> login() async {
    if (_formSignInKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logging in...'),
        ),
      );

      final url = Uri.parse('${ApiConstants.baseUrl}/users/login');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'email': _emailController.text,
        'password_hash': _passwordController.text,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final userid = responseData['_id'];
          final token = responseData['token'];
          final role = responseData['role'];
          
          if (role == 'patient') {
            final age = responseData['medicalCard']['publicData']['age'];
            await storage.write(
                key: 'age', value: age.toString()); // تحويل age إلى String
          }

          await storage.write(key: 'userid', value: userid);
          await storage.write(key: 'token', value: token);

          final userJson = jsonEncode(responseData);
          await storage.write(key: 'user', value: userJson);
          if (!kIsWeb) {
            // للموبايل
            String? tokenFCM = await FirebaseMessaging.instance.getToken();
            if (tokenFCM != null) {
              await FirebaseDatabase.instance.ref('users/$userid').update({
                'fcmToken': tokenFCM,
              });
            }
          } else {
            // للويب
            try {
              FirebaseMessaging messaging = FirebaseMessaging.instance;
/*
              messaging.getToken().then((tokenFCM) {
                print("FCM Token: $tokenFCM");
              });
*/
              /* NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? webToken = await FirebaseMessaging.instance.getToken(
        vapidKey: "BOaWKc1t4Xr-PGiHPOaiUPoNspxgHsv-a0EmXPknX0O07pTGKYl4YI85mn52sNCoVWWM7IfSMRsi55vTgLyg1EE", // ضع المفتاح العام الخاص بالـ VAPID
      );
      if (webToken != null) {
        await FirebaseDatabase.instance.ref('users/$userid').update({
          'fcmToken': webToken,
        });
      }
    } else {
      print("User denied or notifications not enabled on the web.");
    }*/
            } catch (e) {
              print("Error fetching FCM token for web: $e");
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Successful! User ID: $userid')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                if (role == 'patient') {
                  final name = responseData[
                      'username']; // Extract the role from the response
                  storage.write(key: 'username', value: name);

                  return HomePage();
                } else if (role == 'doctor') {
                  final name = responseData[
                      'fullName']; // Extract the role from the response
                  storage.write(key: 'username', value: name);

                  return DoctorHomePage();
                } else if(role == 'admin'){
                            if (!kIsWeb) {
                            return AdminDashboard1();
                            }else {
                  return AdminDashboard();}

                }
                else {
                  return HomePage();
                }
              },
            ),
          );
        } else {
          final errorMessage = jsonDecode(response.body)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Failed: $errorMessage'),
            backgroundColor: Colors.red),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'),
            backgroundColor: Colors.red),
        );
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

/////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: kIsWeb
          ? Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/u1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // AppBar for web
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
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
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WelcomeScreen()),
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
                                  MaterialPageRoute(
                                      builder: (context) => AboutUsPage()),
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
                                print("Login button has focus: $hasFocus");
                              },
                              child: FocusScope(
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xff613089), // Border color
                                      width: 2.0, // Border width
                                    ),
                                    padding: const EdgeInsets.all(
                                        16), // Padding for better visibility
                                  ),
                                  child: const Text(
                                    'Log In',
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
                  child: Container(
                    width: 450,
                    height: 800,
                    padding: const EdgeInsets.all(30),
                    child: _buildSignInFormWeb(),
                  ),
                ),
              ],
            )
          : _buildSignInForm(),
    );
  }

  Widget _buildSignInFormWeb() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20.0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _buildSharedSignInForm(
              width: 500,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20.0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              spacing: 20.0,
              logoSize: 100,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
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
                child: _buildSharedSignInForm(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  spacing: 25.0,
                  logoSize: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedSignInForm({
    required double width,
    required EdgeInsetsGeometry padding,
    required BoxDecoration decoration,
    required double spacing,
    required double logoSize,
  }) {
    return Form(
      key: _formSignInKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Image.asset(
                'assets/images/appLogo.png',
                height: logoSize,
                color: const Color(0xff613089),
              ),
              const SizedBox(height: 10),
              const Text(
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
          SizedBox(height: spacing),
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
              labelStyle: const TextStyle(color: Color(0xff613089)),
              hintText: 'Enter Email',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xffb41391),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(
                Icons.email,
                color: Color(0xff613089),
              ),
            ),
          ),
          SizedBox(height: spacing),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            obscuringCharacter: '•',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              } else if (value.length < 6) {
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
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xff613089),
                ),
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
          ),
          SizedBox(height: spacing),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                if (_emailController.text.isEmpty ||
                    !_emailRegExp.hasMatch(_emailController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please enter a valid Email to reset password.'),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgetPasswordScreen(),
                    ),
                  );
                }
              },
              child: const Text(
                'Forget password?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
              ),
            ),
          ),
          SizedBox(height: spacing),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff613089),
              ),
              child: const Text('Log In'),
            ),
          ),
          SizedBox(height: spacing),
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
                        builder: (context) =>
                            const AccountTypeSelectionScreen()),
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
    );
  }
}
