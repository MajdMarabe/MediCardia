import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'user_doctors.dart';
import 'chat_screen.dart';
import 'permission_requests.dart';
import 'reviews.dart';
import 'appointment.dart';

const storage = FlutterSecureStorage();

class FindDoctorPage extends StatefulWidget {
  const FindDoctorPage({Key? key}) : super(key: key);

  @override
  _FindDoctorPageState createState() => _FindDoctorPageState();
}

class _FindDoctorPageState extends State<FindDoctorPage> {
  List<Map<String, dynamic>> allDoctors = [];
  List<Map<String, dynamic>> displayedDoctors = [];
  bool isLoading = true;
  String selectedSpecialty = "All";
  TextEditingController searchController = TextEditingController();
  List<String> doctorNames = [];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  // Fetch all doctors from the API
  Future<void> fetchDoctors() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/doctors/getAllDoctors'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          allDoctors = data.map((doc) {
            return {
              'id': doc['_id'],
              'name': doc['fullName'] ?? 'Unknown',
              'specialty': doc['specialization'] ?? 'Unknown',
              'rating': doc['averageRating'] ?? 0.0,
              'image': (doc['image']?.isNotEmpty == true)
                  ? doc['image']
                  : 'Unknown',
              'email': doc['email'] ?? 'No email provided.',
              'about': doc['about'] ?? 'No about provided.',
              'phone': doc['phone'] ?? 'No phone number provided.',
              'numberOfPatients': doc['numberOfPatients'] ?? 0,
              'workplace': {
                'name': doc['workplace']?['name'] ?? 'No workplace name.',
                'address': doc['workplace']?['address'] ?? 'No address.',
                'notificationSettings': {
                  'messages': doc['notificationSettings']?['messages'] ?? true,
                  'requests': doc['notificationSettings']?['requests'] ?? true,
                },
              },
            };
          }).toList();
         doctorNames = allDoctors
    .map((doctor) => doctor['name'] as String)
    .where((name) => name != 'Sally Mah')
    .toList();

      
        displayedDoctors = allDoctors
            .where((doctor) => doctor['name'] != 'Sally Mah')
            .toList();
          isLoading = false;
        });
      } else {
        _showMessage('Failed to load doctors');
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

void filterDoctors() {
  String searchQuery = searchController.text.toLowerCase();
  setState(() {
    displayedDoctors = allDoctors.where((doctor) {
      final matchesSpecialty = selectedSpecialty == "All" ||
          doctor['specialty'].toLowerCase() == selectedSpecialty.toLowerCase();
      final matchesSearch = doctor['name'].toLowerCase().contains(searchQuery);
      final isNotSallyMah = doctor['name'] != 'Sally Mah';
      return matchesSpecialty && matchesSearch && isNotSallyMah;
    }).toList();
  });
}


  void _onSearchChanged() {
    filterDoctors();
  }

  ///////////////////////////////////////

  final Map<String, Widget> specialtiesWithIcons = {
    "All": const Icon(Icons.clear_all, color: Color(0xFF613089), size: 18),
    "General": const Icon(FontAwesomeIcons.stethoscope, color: Color(0xFF613089), size: 16),
    "Plastic Surgery": const Icon(FontAwesomeIcons.faceSmile, color: Color(0xFF613089), size: 16),
    "Eye": const Icon(Icons.visibility, color: Color(0xFF613089), size: 18),
    "Nose": Image.asset(
      'assets/images/nose.png',
      width: 15,
      height: 15,
      color: const Color(0xFF613089),
    ),
       
    "Dentistry":
        const Icon(FontAwesomeIcons.tooth, color: Color(0xFF613089), size: 18),
        "Cardiology": const Icon(FontAwesomeIcons.heartbeat,
        color: Color(0xFF613089), size: 18),
        "Endocrinology": const Icon(FontAwesomeIcons.dna,
        color: Color(0xFF613089), size: 16),
          
            "Psychiatry": const Icon(Icons.psychology,
        color: Color(0xFF613089), size: 20),
         "Gynecology":
        const Icon(FontAwesomeIcons.personDress, color: Color(0xFF613089), size: 18),

    "Pediatrics":
        const Icon(Icons.child_friendly, color: Color(0xFF613089), size: 18),

     
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: kIsWeb
          ? AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PermissionRequestsPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Image.asset(
                      'assets/images/subsidiary.png',
                      width: 42,
                      height: 42,
                      color: const Color(0xFF613089),
                    ),
                  ),
                ),
              ],
            )
          : AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              centerTitle: true,
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PermissionRequestsPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Image.asset(
                      'assets/images/subsidiary.png',
                      width: 42,
                      height: 42,
                      color: const Color(0xFF613089),
                    ),
                  ),
                ),
              ],
            ),
        body: ScrollConfiguration(
    behavior: kIsWeb ? TransparentScrollbarBehavior() : const ScrollBehavior(),
        child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth =
              constraints.maxWidth > 600 ? 1000 : constraints.maxWidth;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Let’s Find Your\nDoctor",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A4C9C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildSearchSection(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Doctors",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF613089),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: buildDropdownSection(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : displayedDoctors
              .where((doc) => doc['name'] != 'Sally Mah')
              .toList()
              .isEmpty
          ?  Center(child: Text("No doctors found.",
                              style: TextStyle(fontSize: 16, color: Colors.grey[500])))
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final bool isWeb =
                                        constraints.maxWidth > 600;
                                    final int crossAxisCount = isWeb ? 3 : 2;
                                     final filteredDoctors = displayedDoctors
                    .where((doctor) => doctor['name'] != 'Sally Mah')
                    .toList();
                                    return SingleChildScrollView(
                                      child: GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: isWeb ? 1.4 : 0.8,
                                        ),
                                         itemCount: filteredDoctors.length,
                                        itemBuilder: (context, index) {
                                          final doctor =
                                              displayedDoctors[index];
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DoctorDetailPage(
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
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
       ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorsPage()),
          );
        },
        // ignore: deprecated_member_use
        icon: const Icon(FontAwesomeIcons.userMd, color: Colors.white),
        label: const Text(
          "Your Doctors",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF613089),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

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
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  fetchDoctors();
                  return const Iterable<String>.empty();
                }
                return doctorNames.where((name) => name
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                searchController.text = selection;
                filterDoctors();
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                searchController = controller;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: const InputDecoration(
                    hintText: 'Search for doctors by name...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownSection() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 150,
        child: DropdownButtonFormField<String>(
          value: selectedSpecialty,
          items: specialtiesWithIcons.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                children: [
                  entry.value,
                  const SizedBox(width: 3),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      color: Color(0xFF613089),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedSpecialty = value;
                filterDoctors();
              });
            }
          },
          dropdownColor: Colors.white,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF613089),
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF613089),
            size: 18,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

//////////////////////////// Doctor Detail Page ////////////////////////////////

class DoctorDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailPage({Key? key, required this.doctor}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  int? selectedDay;
  int? selectedTime;
  bool isFavorite = false;
  double averageRating = 0.0;
  int reviewCount = 0;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchRatingData();
  }

  Future<void> fetchRatingData() async {
    final apiUrl =
        '${ApiConstants.baseUrl}/rating/${widget.doctor['id']}'; // Replace with your API URL
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          averageRating = (data['averageRating'] is int)
              ? (data['averageRating'] as int).toDouble()
              : data['averageRating'] is double
                  ? data['averageRating']
                  : 0.0;
          reviewCount = data['reviewCount'] ?? 0; 

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _setAsMyDoctor(BuildContext context) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/doctorsusers/relations');
    final patientId = await storage.read(key: 'userid');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your_auth_token',
        },
        body: json.encode({
          'doctorId': widget.doctor['id'],
          'patientId': patientId,
          'relationType': 'Primary',
          'notes': 'Patient added doctor as primary care provider',
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${widget.doctor['name']} has been set as your doctor.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("${widget.doctor['name']} is already your doctor.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

/////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
 


    Widget buildImageFromBase64OrAsset(String image, double height) {
  try {
    if (image.startsWith('data:image')) {
      image = image.split(',').last;
    }

    final bytes = base64Decode(image); 
    return Image.memory(
      bytes,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  } catch (e) {
    print("Error decoding base64 image: $e");
    return Image.asset(
      "assets/images/default_person.jpg", 
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}


    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: const Color(0xFFF2F5FF),
          appBar: kIsWeb
              ? AppBar(
                  backgroundColor: const Color(0xFFF2F5FF),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  title: const Text(
                    'Doctor Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                      letterSpacing: 1.5,
                    ),
                  ),
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
                  centerTitle: true,
                  title: const Text(
                    'Doctor Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        constraints.maxWidth > 600 ? 800 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        double imageHeight =
                                            constraints.maxWidth > 600
                                                ? 370
                                                : 160;

                         return widget.doctor["image"] != null
    ? !widget.doctor["image"].startsWith('http') 
        ? buildImageFromBase64OrAsset(widget.doctor["image"], imageHeight)
        : Image.asset(
            "assets/images/default_person.jpg",
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          )
    : Image.asset(
        "assets/images/default_person.jpg", 
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
      );


                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dr. ${widget.doctor['name']}',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF613089),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.doctor['specialty'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          /*  IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: const Color(0xFF613089),
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isFavorite = !isFavorite;
                                              });
                                            },
                                          ),*/
                                          IconButton(
                                            icon: const Icon(
                                              Icons.chat,
                                              color: Color(0xFF613089),
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              final String id =
                                                  widget.doctor['id'];
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPage(
                                                            receiverId: id,
                                                            name: widget.doctor[
                                                                'name'],image:widget.doctor['image'])),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                     // const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              icon: Icons.people,
                              value:
                                  widget.doctor['numberOfPatients'].toString(),
                              label: 'Patients',
                              color: const Color(0xFF613089),
                            ),
                            _buildStatCard(
                              icon: Icons.star_rate,
                              value: averageRating.toString(),
                              label: 'Ratings',
                              color: const Color(0xFF613089),
                            ),
                            _buildStatCard(
                              icon: Icons.reviews,
                              value: reviewCount.toString(),
                              label: 'Reviews',
                              color: const Color(0xFF613089),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReviewsPage(
                                          doctorid: widget.doctor['id'])),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (
    widget.doctor['workplace']['name'] !='No workplace name.' &&
    widget.doctor['workplace']['address'] != 'No address.') 
              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Address",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF613089),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Color(0xFF613089)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${widget.doctor['workplace']['name']} - ${widget.doctor['workplace']['address']}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    ],
  ),
),

                       const SizedBox(height: 20),
                 if (widget.doctor['about'] != 'No about provided.' && widget.doctor['about'] != " ") ...[
  const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: Text(
      "About",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF613089),
      ),
    ),
  ),
  const SizedBox(height: 8),
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Text(
      widget.doctor['about'],
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
    ),
  ),
],

   const SizedBox(height: 15),
                     
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
 AppointmentPage(doctorid: widget.doctor['id'],name: widget.doctor['name'] ,),                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF613089),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "     Appointment    ",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _setAsMyDoctor(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF613089),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Set as my doctor  ",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



//////////////////////////////

class TransparentScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;  
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const AlwaysScrollableScrollPhysics(); 
  }
}

