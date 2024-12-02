import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/signup_user.dart';
import 'package:flutter_application_3/widgets/custom_scaffold.dart';
import 'package:flutter_application_3/screens/signup_doctor.dart';

class AccountTypeSelectionScreen extends StatelessWidget {
  const AccountTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 20), // Increased top space for better balance
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 30.0), // More padding for better spacing
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xfff7f5f7), // Light background color
                    Color(0xffe8e0f2), // Slightly darker tone for a soft gradient
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0), // Increased corner radius for a smoother look
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title section with bold text and improved styling
                  const Text(
                    'Create a New Account',
                    style: TextStyle(
                      fontSize: 32.0, // Larger font for title
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  const Text(
                    'Select Account Type',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30.0), // Increased space for better separation
                  
                  // Elevated button for patient account
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff613089),
                        padding: const EdgeInsets.symmetric(vertical: 12.0), // Reduced vertical padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0), // Rounded corners
                        ),
                        shadowColor: Colors.purple.withOpacity(0.3), // Subtle shadow for depth
                        elevation: 10.0, // More elevation for button depth
                      ),
                      child: const Text(
                        'Patient',
                        style: TextStyle(
                          fontSize: 18.0, // Increased font size for clarity
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  
                  // Elevated button for doctor account
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpDoctorScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff613089),
                        padding: const EdgeInsets.symmetric(vertical: 12.0), // Reduced vertical padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0), // Rounded corners
                        ),
                        shadowColor: Colors.purple.withOpacity(0.3), // Subtle shadow for depth
                        elevation: 10.0, // More elevation for button depth
                      ),
                      child: const Text(
                        'Doctor',
                        style: TextStyle(
                          fontSize: 18.0, // Increased font size for clarity
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
