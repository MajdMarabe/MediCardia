import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/signup_screen.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Create a New Account',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900,
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
                  const SizedBox(height: 25.0),
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
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Text(
                        'Patient',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
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
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      child: const Text(
                        'Doctor',
                        style: TextStyle(fontSize: 16.0),
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
