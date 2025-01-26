import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:flutter_application_3/screens/select_type.dart';
import 'package:flutter_application_3/widgets/welcome_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, 0))
            .animate(
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
                image: AssetImage(
                    'assets/images/u1.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),

          Align(
            alignment: Alignment
                .topCenter, 
            child: Padding(
              padding: const EdgeInsets.only(
                  top:
                      100.0), 
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0, 
                    child: AnimatedOpacity(
                      opacity: _opacityAnimation.value,
                      duration: const Duration(seconds: 2),
                      child: CircleAvatar(
                        radius: 80.0,
                        backgroundColor: const Color(0xffF0E5FF),
                        child: Image.asset(
                          'assets/images/appLogo.png',
                          height: 120.0,
                          width: 120.0,
                          color: const Color(0xff613089),
                        ),
                      ),
                    ),
                  );
                },
              ),
                  const SizedBox(height: 20.0),
                  AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                 return SlideTransition(
  position: _slideAnimation,
  child: AnimatedOpacity(
    opacity: _opacityAnimation.value,
    duration: const Duration(seconds: 2),
    child: const Column(
      children: [

        Text(
          'MediCardia',
          style: TextStyle(
            fontFamily: 'BAUHS93',
            fontSize: 54.0,
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
          
          ),
          textAlign: TextAlign.center,
        ),
                  const SizedBox(height: 12.0),
                  Text(
          'Your Health, Your Priority',
          style:  TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
);

                },
              ),
                  const SizedBox(height: 50.0),
                
                  Column(
                    children: [
                  
                    AnimatedButton(
                    buttonText: 'Log In',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const SignInScreen())),
                    color: const Color(0xff613089),
                    textColor: Colors.white,
                    width: 220.0,
                    borderRadius: 30.0,
                  ),
                      const SizedBox(height: 12.0),
         
                   
                   AnimatedButton(
                    buttonText: 'Sign Up',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const AccountTypeSelectionScreen())),
                    color: Colors.white,
                    textColor: const Color(0xff613089),
                    borderColor: const Color(0xff613089),
                    borderWidth: 2.0,
                    width: 220.0,
                    borderRadius: 30.0,
                  ),
                    ],
                  ),
                ],
              ),
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
