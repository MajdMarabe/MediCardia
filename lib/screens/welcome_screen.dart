import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:flutter_application_3/screens/select_type.dart';
import 'package:flutter_application_3/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            CircleAvatar(
              radius: 80.0,
              backgroundColor: const Color(0xffF0E5FF), // Subtle background for logo
              child: Image.asset(
                'assets/images/appLogo.png',
                height: 120.0,
                width: 120.0,
                color: const Color(0xff613089),
              ),
            ),
            const SizedBox(height: 20.0),
            // App Name
            const Text(
              'MediCardia',
              style: TextStyle(
                fontFamily: 'BAUHS93',
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Color(0xff613089),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            // Tagline
            const Text(
              'Your Health, Your Priority',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50.0),
            // Buttons Section
          const Column(
  children: [
    // Login Button
    WelcomeButton(
      buttonText: 'Log In',
      onTap: SignInScreen(),
      color: Color(0xff613089), // Purple background
      textColor: Colors.white, // White text
      width: 200.0, // Fixed width for consistency
    ),
    SizedBox(height: 12.0), // Spacing between buttons
    // Sign Up Button
    WelcomeButton(
      buttonText: 'Sign Up',
      onTap:  AccountTypeSelectionScreen(),
      color: Colors.white, // White background
      textColor: Color(0xff613089), // Purple text
      borderColor: Color(0xff613089), // Purple border
      borderWidth: 1.5, // Thin border
      width: 200.0, // Fixed width for consistency
    ),
  ],
),

          ],
        ),
      ),
    );
  }
}
