import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

const storage = FlutterSecureStorage();

class DoctorsPage extends StatefulWidget {
  @override
  _DoctorsPageState createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];
  bool isLoading = true;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    final patientId = await storage.read(key: 'userid');

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/doctorsusers/relations/patient/$patientId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          doctors = data.map((relation) {
            final doctor = relation['doctorId'];
            return {
              'name': doctor['fullName'] ?? 'Unknown',
              'specialty': doctor['specialization'] ?? 'Unknown',
              'price': doctor['price'] ?? 0,
              'rating': doctor['rating'] ?? 0.0,
              'image': doctor['image'] ?? 'assets/images/doctor1.jpg',
            };
          }).toList();
          filteredDoctors = doctors;
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

  void updateSearchResults(String query) {
    setState(() {
      searchQuery = query;
      filteredDoctors = doctors
          .where((doctor) =>
              doctor['name'].toLowerCase().contains(query.toLowerCase()) ||
              doctor['specialty'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  ////////////////////////////////

  Widget buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF6A4C9C), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF6A4C9C), size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (text) {
                updateSearchResults(text);
                if (text.isEmpty) {
                  fetchDoctors(); // Call fetchDoctors if the search text is empty
                }
              },
              decoration: const InputDecoration(
                hintText: 'Search doctors by name...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

/////////////////////////

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: const Color(0xFFF2F5FF),
          appBar: kIsWeb
              ? AppBar(
                  backgroundColor: const Color(0xFFF2F5FF),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: const Text(
                    "Your Doctors",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF613089),
                      letterSpacing: 1.5,
                      fontSize: 22,
                    ),
                  ),
                  centerTitle: true,
                )
              : AppBar(
                  backgroundColor: const Color(0xFFF2F5FF),
                  elevation: 0,
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF613089)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: const Text(
                    "Your Doctors",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF613089),
                      letterSpacing: 1.5,
                      fontSize: 22,
                    ),
                  ),
                  centerTitle: true,
                ),
          body: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        constraints.maxWidth > 600 ? 1000 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: buildSearchSection(),
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredDoctors.isEmpty
                              ? const Center(child: Text("No doctors found."))
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Check if the screen width is large enough for web
                                    bool isWeb = constraints.maxWidth > 600;

                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isWeb
                                            ? 3
                                            : 2, // Adjust based on device
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: isWeb
                                            ? 1.1
                                            : 0.5, // Adjust aspect ratio
                                      ),
                                      itemCount: filteredDoctors.length,
                                      itemBuilder: (context, index) {
                                        final doctor = filteredDoctors[index];
                                        return DoctorCard(doctor: doctor);
                                      },
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

///////////////////////////////

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorCard({required this.doctor, Key? key}) : super(key: key);


@override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
ClipRRect(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  child: LayoutBuilder(
    builder: (context, constraints) {
      double imageHeight = constraints.maxWidth > 600 ? 240 : 120;

      return doctor["image"] != null && doctor["image"].startsWith('http')
          ? Image.network(
              doctor["image"] ?? "https://via.placeholder.com/150",
              height: imageHeight, 
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.asset(
              doctor["image"] ?? "https://via.placeholder.com/150",
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
            );
    },
  ),
),





          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor["name"] ?? "Unknown",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor["specialty"] ?? "N/A",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow[700], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      doctor["rating"]?.toString() ?? "0.0",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      "${doctor["price"] ?? '0'} \$",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
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
