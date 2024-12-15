import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_application_3/screens/signup_user.dart';
import 'package:flutter_application_3/screens/signup_doctor.dart';
import 'package:flutter_application_3/widgets/custom_scaffold.dart';

class AccountTypeSelectionScreen extends StatelessWidget {
  const AccountTypeSelectionScreen({Key? key}) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: kIsWeb
          ? Stack(
              children: [
               
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
                    width: 400, 
                    height: 550,
                    padding: const EdgeInsets.all(30),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       
                        const Text(
                          'Create a New Account',
                          style: TextStyle(
                            fontSize: 32.0,
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
                        const SizedBox(height: 30.0),
                        _buildButton(context, 'Patient', const SignUpScreen()),
                        const SizedBox(height: 20.0),
                        _buildButton(context, 'Doctor', const SignUpDoctorScreen()),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : _buildAndroidLayout(context), 
    );
  }


  
  Widget _buildAndroidLayout(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 30.0), 
              decoration: const BoxDecoration(
               color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Create a New Account',
                    style: TextStyle(
                      fontSize: 32.0,
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
                  const SizedBox(height: 30.0),
                  _buildButton(context, 'Patient', const SignUpScreen()),
                  const SizedBox(height: 20.0),
                  _buildButton(context, 'Doctor', const SignUpDoctorScreen()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildButton(BuildContext context, String title, Widget destination) {
    return SizedBox(
      width: 400.0,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => destination,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff613089),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          shadowColor: Colors.purple.withOpacity(0.3),
          elevation: 10.0,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            //fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
