import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:flutter_application_3/screens/select_type.dart';
import 'package:flutter_application_3/widgets/welcome_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/u1.jpg'), // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                CircleAvatar(
                  radius: 80.0,
                  backgroundColor: const Color(0xffF0E5FF),
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
                    color: Color.fromARGB(255, 255, 255, 255),
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
      color: Color(0xff613089), 
      textColor: Colors.white, 
      width: 200.0, 
    ),
    SizedBox(height: 12.0), 
    // Sign Up Button
    WelcomeButton(
      buttonText: 'Sign Up',
      onTap:  AccountTypeSelectionScreen(),
      color: Colors.white, 
      textColor: Color(0xff613089), 
      borderColor: Color(0xff613089),
      borderWidth: 1.5, 
      width: 200.0, 
    ),
  ],
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final double width;
  final Color? borderColor;
  final double? borderWidth;
  final double borderRadius;

  const AnimatedButton({
    required this.buttonText,
    required this.onTap,
    required this.color,
    required this.textColor,
    required this.width,
    this.borderColor,
    this.borderWidth,
    required this.borderRadius,
  });



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth!)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12.0,
              spreadRadius: 2.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
