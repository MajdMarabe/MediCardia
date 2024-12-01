import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import'user_doctors.dart';
import 'user_home.dart';

final storage = FlutterSecureStorage();

class FindDoctorPage extends StatefulWidget {
  const FindDoctorPage({Key? key}) : super(key: key);

  @override
  _FindDoctorPageState createState() => _FindDoctorPageState();
}

class _FindDoctorPageState extends State<FindDoctorPage> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/doctors/getAllDoctors'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {

          doctors = data.map((doc) {
            return {
              'id': doc['_id'],
              'name': doc['fullName'] ?? 'Unknown',
              'specialty': doc['specialization'] ?? 'Unknown',
              'rating': doc['rating'] ?? 0.0,
              'image': doc['image'] ?? 'https://via.placeholder.com/150',
              'email': doc['email'] ?? 'No email provided',
              'phone': doc['phone'] ?? 'No phone number provided',
              'workplace': {
                'name': doc['workplace']?['name'] ?? 'No workplace name',
                'address': doc['workplace']?['address'] ?? 'No address',
              },
            };
          }).toList();
          isLoading = false;
        });
      } else {
        _showMessage('Failed to load doctors: ${response.body}');
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

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFEFF3FF),
    appBar: AppBar(
      backgroundColor: const Color(0xFFEFF3FF),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
 Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Let’s Find Your\nDoctor",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Categories Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: _CategoryIcon(icon: Icons.remove_red_eye, label: "Eye"),
                onTap: () {
                /*  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EyeDoctorsPage()),
                  );*/
                },
              ),
              GestureDetector(
                child: _CategoryIcon(icon: Icons.favorite, label: "Heart"),
                onTap: () {
               /*   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HeartDoctorsPage()),
                  );*/
                },
              ),
              GestureDetector(
                child: _CategoryIcon(icon: Icons.note, label: "Nose"),
                onTap: () {
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NoseDoctorsPage()),
                  );*/
                },
              ),
              GestureDetector(
                child: _CategoryIcon(icon: Icons.apps, label: "Your Doctors"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorsPage()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            "All Doctors",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : doctors.isEmpty
                    ? const Center(child: Text("No doctors found."))
                    : ListView.builder(
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorDetailPage(
                                    doctor: doctor,
                                  ),
                                ),
                              );
                            },
                            child: DoctorCard(
                              doctor: doctor,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    ),
  );

}


}

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryIcon({required this.icon, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorCard({
    required this.doctor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(doctor['image']),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['specialty'],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Workplace: ${doctor['workplace']['name']}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 18),
                const SizedBox(width: 4),
                Text(
                  doctor['rating'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class DoctorDetailPage extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailPage({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  Future<void> _setAsMyDoctor(BuildContext context) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/doctorsusers/relations');
  final patientId = await storage.read(key: 'userid'); 

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your_auth_token' 
        },
        body: json.encode({
          'doctorId': doctor['id'], 
          'patientId': patientId, 
          'relationType': 'Primary',
          'notes': 'Patient added doctor as primary care provider'
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${doctor['name']} has been set as your doctor.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${doctor['name']} is aleady your doctor.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Background.jpg'), // Add your own asset path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(doctor['image']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            // Doctor details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      doctor['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      doctor['specialty'],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildContactIcon(Icons.chat, Colors.orange),
                      _buildContactIcon(Icons.call, Colors.blue),
                      _buildContactIcon(Icons.video_call, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Address and workplace
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${doctor['workplace']['name']} - ${doctor['workplace']['address']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(Icons.access_time, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Daily Practice: Monday - Friday ",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActivityCard(
                        title: "List of Schedule",
                        icon: Icons.schedule,
                        color: Colors.lightBlue,
                      ),
                      _buildActivityCard(
                        title: "Doctor's Daily Post",
                        icon: Icons.article,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _setAsMyDoctor(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Set as My Doctor",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactIcon(IconData icon, Color color) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
