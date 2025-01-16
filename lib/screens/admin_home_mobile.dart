import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'statistics.dart';
import 'manage_accounts.dart';
import 'admin_drugs.dart';
import 'admin_hospitals.dart';

class AdminDashboard1 extends StatelessWidget {
  const AdminDashboard1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double pageWidth = constraints.maxWidth > 600 ? 700 : double.infinity;

          return Center(
            child: Container(
              width: pageWidth,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              'Welcome to the admin dashboard!',
                              textStyle: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff613089),
                                fontFamily: 'ScriptMTBold',
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: const Duration(milliseconds: 500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: constraints.maxWidth > 600 ? 2.5 : 1.5,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        List<String> titles = [
                          'Manage Accounts',
                          'Statistics',
                          'Hospitals',
                          'Drugs'
                        ];
                        List<String> routes = [
                          '/manageAccounts',
                          '/statistics',
                          '/Hospitals',
                          '/Drugs'
                        ];
                        List<IconData> icons = [
                          Icons.people,
                          Icons.bar_chart,
                          FontAwesomeIcons.hospital,
                          FontAwesomeIcons.capsules,
                        ];

                        return _buildNavigationButton(
                            context, titles[index], routes[index], icons[index]);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

Widget _buildNavigationButton(
    BuildContext context, String title, String route, IconData icon) {
  return GestureDetector(
    onTap: () {
      if (route == '/statistics') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatisticsPage()),
        );
      } else if (route == '/manageAccounts') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageAccountsPage()),
        );
      }
      else if (route == '/Hospitals') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageHospitalsPage()),
        );
      } 
      else if (route == '/Drugs') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageDrugsPage()),
        );
      }  else {
        Navigator.pushNamed(context, route);
      }
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff9C27B0), Color(0xff6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (route == '/statistics') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatisticsPage()),
            );
          } else if (route == '/manageAccounts') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageAccountsPage()),
            );
          }   else if (route == '/Hospitals') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageHospitalsPage()),
        );
      } 
      else if (route == '/Drugs') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageDrugsPage()),
        );
      } else {
            Navigator.pushNamed(context, route);
          }
        },
        splashColor: Colors.white.withOpacity(0.5),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

}