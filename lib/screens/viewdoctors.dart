import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'user_doctors.dart';
import 'user_home.dart';

final storage = FlutterSecureStorage();

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
  List<String> doctorNames = []; // List for autocomplete suggestions

  @override
  void initState() {
    super.initState();
    fetchDoctors();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
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
          doctorNames = allDoctors.map((doctor) => doctor['name'] as String).toList(); // Populate autocomplete options
          displayedDoctors = List.from(allDoctors);
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
        return matchesSpecialty && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged() {
    filterDoctors();
  }

  Widget buildDropdown() {
    final List<String> specialties = [
      "All",
      "Eye",
      "Heart",
      "Nose",
      "General",
      "Pediatrics",
      "Cardiology",
      "Dentistry",
      "Orthopedics",
    ];

    return DropdownButton<String>(
      value: selectedSpecialty,
      items: specialties.map((specialty) {
        return DropdownMenuItem<String>(
          value: specialty,
          child: Text(
            specialty,
            style: const TextStyle(color: Color(0xFF613089)),
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
        fontSize: 16,
        color: Color(0xFF613089),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF613089)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
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
                color: Color(0xFF6A4C9C),
              ),
            ),
            const SizedBox(height: 16),
            buildDropdown(),
            const SizedBox(height: 10),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return doctorNames.where((name) =>
                    name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                searchController.text = selection;
                filterDoctors();
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                searchController = controller;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: const InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            const Text(
              "Doctors",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF613089),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayedDoctors.isEmpty
                      ? const Center(child: Text("No doctors found."))
                      : ListView.builder(
                          itemCount: displayedDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = displayedDoctors[index];
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
          SnackBar(content: Text("${widget.doctor['name']} has been set as your doctor.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.doctor['name']} is already your doctor.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  void _startChat(BuildContext context) {
    // Implement the chat start functionality here
  }

  @override
  Widget build(BuildContext context) {
    List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    List<String> availableTimes = ["9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF613089)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
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
          child: Column(
            children: [
              // Combined box with image, name, and specialty
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                   
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.doctor['image'],
                            width: double.infinity, // Image takes the full width
                            height: 180, // Set a fixed height for the image
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12), // Space between image and text
                        // Doctor Details (name and specialty with icons)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Doctor's name and specialty in the left
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               Text(
  'Dr ${widget.doctor['name']}',
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
                                IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: const Color(0xFF613089),
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.chat,
                                    color: Color(0xFF613089),
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _startChat(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                            const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "About",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF613089),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod sapien nec augue eleifend venenatis.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF613089),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF613089)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${widget.doctor['workplace']['name']} - ${widget.doctor['workplace']['address']}",
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Appointment section
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Appointment",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF613089),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Select Day of the Week
              Align(
                alignment: Alignment.centerLeft, // Align to the left
                child: DropdownButton<int>(
                  hint: Text(
                    "Select Day",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  value: selectedDay,
                  items: List.generate(7, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        days[index],
                        style: const TextStyle(color: Color(0xFF613089)),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedDay = value;
                      selectedTime = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              if (selectedDay != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Available Time",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF613089),
                      ),
                    ),
                                  const SizedBox(height: 8),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          availableTimes.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(availableTimes[index]),
                              selected: selectedTime == index,
                              onSelected: (selected) {
                                setState(() {
                                  selectedTime = selected ? index : null;
                                });
                              },
                              selectedColor: const Color(0xFF613089),
                              labelStyle: TextStyle(
                                color: selectedTime == index
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _setAsMyDoctor(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF613089),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Set as My Doctor",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}