import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'welcome_screen.dart';
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'verification_code.dart';

const storage = FlutterSecureStorage();

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  bool agreePersonalData = true;
  bool _obscureText = true;

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
              content: Text('Please agree to the processing of personal data')),
        );
      }
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/users/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _fullNameController.text,
          'email': _emailController.text,
          'password_hash': _passwordController.text,
          'location': _locationController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userId = responseData['_id'];
        await storage.write(key: 'userid', value: userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful: $responseData')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerificationCodeScreen(
                  email: _emailController.text, flag: '3')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }



///////////////////////////////


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
             
                print("Sign Up button has focus: $hasFocus");
              },
              child: FocusScope(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xff613089), 
                      width: 2.0, 
                    ),
                    padding: const EdgeInsets.all(16), 
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
                  child: Container(
                    width: 500,
                    height: 1000,
                    padding: const EdgeInsets.all(30),
                    child: _buildWebLayout(),
                  ),
                ),
              ],
            )
          : _buildSignUpFormMobile(), 
    );
  }



  Widget _buildWebLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: _buildSignUpFormWeb(
            width: 500,
            height: 550,
            padding: const EdgeInsets.all(20.0),
          ),
        ),
      ),
    );
  }




  
  Widget _buildSignUpFormWeb(
      {required double width,
      required double height,
      required EdgeInsets padding}) {
    return Container(
      width: width,
      height: height,
      padding: padding,
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
      child: Form(
        key: _formSignupKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Column(
              children: [
                SizedBox(height: 10.0),
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
            const SizedBox(height: 40.0),

         
            TextFormField(
              controller: _fullNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Full name';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Color(0xff613089)),
                hintText: 'Enter Full Name',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person, color: Color(0xff613089)),
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
                prefixIcon: const Icon(Icons.email, color: Color(0xff613089)),
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

        
            TextFormField(
              controller: _locationController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: const TextStyle(color: Color(0xff613089)),
                hintText: 'Enter Location',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon:
                    const Icon(Icons.location_on, color: Color(0xff613089)),
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
            const SizedBox(height: 25.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitSignUp,
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




   Widget _buildSignUpFormMobile() {
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
                      const SizedBox(height: 40.0),

                    
                      TextFormField(
                        controller: _fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: const TextStyle(color: Color(0xff613089)),
                          hintText: 'Enter Full Name',
                           hintStyle: TextStyle(
      color: Colors.grey.shade400, 
      fontSize: 14, 
      fontStyle: FontStyle.italic, 
    ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.person,
                              color: Color(0xff613089)),
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
                          prefixIcon:
                              const Icon(Icons.email, color: Color(0xff613089)),
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

                 
                      TextFormField(
                        controller: _locationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: const TextStyle(color: Color(0xff613089)),
                          hintText: 'Enter Location',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400, 
                            fontSize: 14, 
                            fontStyle: FontStyle.italic, 
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.location_on,
                              color: Color(0xff613089)),
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
                                _togglePasswordVisibility, 
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

                     
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (value) {
                              setState(() {
                                agreePersonalData = value ?? false;
                              });
                            },
                            activeColor: const Color(
                                0xff613089),
                          ),
                          const Text(
                              'I agree to the processing of personal data'),
                        ],
                      ),

                      const SizedBox(height: 25.0),

                     
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                           style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff613089),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              
                          ),
                          onPressed:
                              _submitSignUp, 
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                            
                              color: Colors.white,
                              fontSize: 16.0
                            ),
                            textAlign: TextAlign.center,
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
