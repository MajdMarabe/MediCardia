import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'drugs_doctor.dart';
import 'lab_tests_doctor.dart';
import 'med_history_doctor.dart';
import 'med_notes_doctor.dart';
import 'treatments_doctor.dart';
import 'diabetes_doctor.dart';
import 'chat_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
final storage = FlutterSecureStorage();

class PatientViewPage extends StatefulWidget {
    final String patientId;

  const PatientViewPage({Key? key, required this.patientId}) : super(key: key);
  @override
  _PatientViewPageState createState() => _PatientViewPageState();
}

class _PatientViewPageState extends State<PatientViewPage> {
    String username = 'Loading..'; // اسم المستخدم
  String gender = 'Unknown'; // الجنس
  String bloodType = 'Unknown'; // فصيلة الدم
  int age = 0; // العمر
  String phoneNumber = 'N/A'; // رقم الهاتف
  String lastDonationDate = 'N/A'; // آخر تاريخ للتبرع بالدم
String? base64Image ='';
String idNumber ='';
String email ='';
String location ='';

  // القوائم الديناميكية
  List<String> chronicDiseases = []; // قائمة الأمراض المزمنة
  List<String> allergies = []; // قائمة الحساسية
  // حالة التحميل
  bool isLoading = true; // للتحقق مما إذا كان يتم تحميل البيانات
  // Map to track the expanded/collapsed state of each section
  Map<String, bool> sectionExpanded = {
    'personalInfo': false,
    'medicalInfo': false,
  };
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }
  // Toggle function to expand/collapse sections
  void toggleSection(String sectionKey) {
    setState(() {
      sectionExpanded[sectionKey] = !sectionExpanded[sectionKey]!;
    });
  }
Future<void> fetchUserInfo() async {
  final String  userid =  widget.patientId;
  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/$userid'), // Replace {userId} with dynamic ID
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        username = data['username'] ?? 'Unknown';
        gender = data['medicalCard']?['publicData']?['gender'] ?? 'Unknown';
        bloodType = data['medicalCard']?['publicData']?['bloodType'] ?? 'Unknown';
        age = data['medicalCard']?['publicData']?['age'] ?? 0;
        phoneNumber = data['medicalCard']?['publicData']?['phoneNumber'] ?? 'N/A';


 idNumber =data['medicalCard']?['publicData']?['idNumber'] ?? 'Unknown';
 email =data['email']?? 'Unknown';
 location =data['location']?? 'Unknown';

        lastDonationDate =
            data['medicalCard']?['publicData']?['lastBloodDonationDate'] ?? 'N/A';
        chronicDiseases = List<String>.from(
          data['medicalCard']?['publicData']?['chronicConditions'] ?? [],
        );
        allergies = List<String>.from(
          data['medicalCard']?['publicData']?['allergies'] ?? [],
        );
       //  base64Image=data['medicalCard']?['publicData']?['image'] ?? 'Unknown';
        isLoading = false; // Update the loading state
      });
    } else {
      _showMessage('Failed to load user information');
      setState(() {
        isLoading = false;
      });
    }
  } catch (e) {
    _showMessage('Error: $e');
    setState(() {
      isLoading = false;
    });
  }
}
 void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  // Widget to display patient information
  Widget buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xff613089),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/doctor3.jpg'),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text(
      username ,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
          ),
        ],
      ),
    ),
    const SizedBox(width: 10), // Adds spacing between the text and the icon
    IconButton(
      icon: const Icon(
        Icons.chat,
        color: Color.fromARGB(255, 248, 247, 249),
        size: 30,
      ),
      onPressed: () async {
        final String id =widget.patientId;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatPage(receiverId: id,name:username)),
        );
      },
    ),
  ],
)

                                ,
                                              const SizedBox(height: 20),

                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.person,
                                  size: 20, color: Colors.white70),
                            ),
                             TextSpan(text: '  Age: $age | Gender: $gender'),
                          ],
                        ),
                      ),
                       const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.bloodtype,
                                  size: 20, color: Colors.white70),
                            ),
                             TextSpan(text: '  Blood Type: $bloodType'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
             ],
       )
    );
  }

  // Widget for personal information box
Widget buildPersonalInfoBox() {
  return GestureDetector(
    onTap: () => toggleSection('personalInfo'),
    child: Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان الرئيسي مع الأيقونة
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xff613089)),
              const SizedBox(width: 10),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
              ),
              const Spacer(),
              Icon(
                sectionExpanded['personalInfo']!
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                color: const Color(0xff613089),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // عرض المعلومات الشخصية بشكل جميل
          if (sectionExpanded['personalInfo']!) ...[
            _buildInfoRow(Icons.badge, 'ID Number', idNumber),
            _buildInfoRow(Icons.email, 'Email', email),
            _buildInfoRow(Icons.location_on, 'Location', location),
            _buildInfoRow(Icons.phone, 'Phone', phoneNumber),
          ],
        ],
      ),
    ),
  );
}

// دالة مساعدة لبناء صف المعلومات مع أيقونة
Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Color(0xff613089)),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}


  // Widget for public information box
 Widget buildPublicInfoBox() {
  return GestureDetector(
    onTap: () => toggleSection('medicalInfo'),
    child: Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان مع أيقونة السهم
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xff613089)),
              const SizedBox(width: 10),
              const Text(
                'Medical Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
              ),
              const Spacer(),
              Icon(
                sectionExpanded['medicalInfo']!
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                color: const Color(0xff613089),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // المحتوى الموسع
          if (sectionExpanded['medicalInfo']!) ...[
           _buildInfoRow(Icons.healing, 'Chronic Diseases', chronicDiseases.join(', ')),
           _buildInfoRow(Icons.warning_amber_rounded, 'Allergies', allergies.join(', ')),

            _buildInfoRow(Icons.bloodtype, 'Last Blood Donation', lastDonationDate),
          ],
        ],
      ),
    ),
  );
}


  // Widget to build square buttons for services
  Widget buildSquareButton({
    required IconData icon,
    required String label,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xff613089)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Patient Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            buildPatientInfo(),
            const SizedBox(height: 10),
            buildPersonalInfoBox(),
            const SizedBox(height: 10),
            buildPublicInfoBox(),
         
            const SizedBox(height: 20),
            // Remaining GridView for Services
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  buildSquareButton(
                    icon: FontAwesomeIcons.capsules,
                    label: 'Drugs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicineListPage()),
                      );
                    },
                  ),
                 
                  buildSquareButton(
                    icon: Icons.bloodtype,
                    label: 'Diabetes',
                     onTap: () {
         
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiabetesControlPage(), 
            ),
          );
        },
                  ),
                  buildSquareButton(
                    icon: Icons.science,
                    label: 'Lab Tests',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LabTestsPage()),
                      );
                    },
                  ),
                  buildSquareButton(
                    icon: Icons.note_alt,
                    label: 'Medical Notes',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalNotesPage()),
                      );
                    },
                  ),
                  buildSquareButton(
                    icon: Icons.fact_check,
                    label: 'Medical History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalHistoryPage()),
                      );
                    },
                  ),
                  buildSquareButton(
                    icon: Icons.medication,
                    label: 'Treatment Plans',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TreatmentPlansPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
