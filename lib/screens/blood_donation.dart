import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/services/notification_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();


class BloodDonationPage extends StatefulWidget {
  @override
  _BloodDonationPageState createState() => _BloodDonationPageState();
}

class _BloodDonationPageState extends State<BloodDonationPage> {
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  String? selectedBloodType;
  String? _hospitalArabicName = '';
  String? _hospitalId = '';
  String? _hospitalCity = '';
  final List<int> availableUnits = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  int? selectedUnit;
  TextEditingController _hospitalController = TextEditingController();
  List<String> _suggestions = [];
  String? hospitalCity;
  double latitude = 31.9466;
  double longitude = 35.3027;
  final MapController mapController = MapController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  Future<void> _getHospitalCoordinates(String hospitalName) async {
    try {
      List<Location> locations = await locationFromAddress(hospitalName);
      if (locations.isNotEmpty) {
        final double lat = locations.first.latitude;
        final double lng = locations.first.longitude;

        setState(() {
          latitude = lat;
          longitude = lng;
        });
        mapController.move(LatLng(lat, lng), 13.0);

        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final city = placemarks.first.locality; // اسم المدينة
          print("City: $city");
          setState(() {
            hospitalCity = city!;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found')),
      );
    }
  }



  Future<void> _getHospitalArabicName(String query) async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConstants.baseUrl}/hospital/gethospital?name=$query'));
      print(response.body);
      if (response.statusCode == 200) {
        //final Map<String, dynamic> responseData = jsonDecode(response.body);

        // تحقق إذا كانت البيانات تحتوي على الاسم العربي للمستشفى
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          // تحقق إذا كانت البيانات تحتوي على المستشفيات
          if (responseData.containsKey('hospitals') &&
              responseData['hospitals'] is List &&
              responseData['hospitals'].isNotEmpty) {
            // الحصول على الاسم العربي من أول مستشفى في القائمة
            final String hospitalArabicName =
                responseData['hospitals'][0]['nameArabic'];
            final String id = responseData['hospitals'][0]['_id'];
            final String city = responseData['hospitals'][0]['city'];
            // هنا يمكنك التعامل مع الاسم العربي كما ترغب، مثلاً تخزينه أو عرضه
            setState(() {
              _hospitalArabicName = hospitalArabicName;
              _hospitalId = id;
              _hospitalCity = city;
            });

            print("Arabic Hospital Name: $_hospitalArabicName");
          } else {
            setState(() {
              _hospitalArabicName =
                  ''; // إذا لم يكن هناك مستشفيات أو البيانات غير صحيحة
            });
          }
        } else {
          setState(() {
            _hospitalArabicName = ''; // إذا كانت الاستجابة غير ناجحة
          });
        }
      } else {
        setState(() {
          _hospitalArabicName = '';
        });
      }
    } catch (e) {
      print("Error fetching hospital name: $e");
      setState(() {
        _hospitalArabicName = '';
      });
    }
  }



  Future<void> _getHospitalSuggestions(String query) async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConstants.baseUrl}/hospital/gethospital?name=$query'));
//print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if 'hospitals' key exists and is a list
        if (responseData.containsKey('hospitals') &&
            responseData['hospitals'] is List) {
          final List<dynamic> hospitals = responseData['hospitals'];
          setState(() {
            _suggestions = hospitals.map((h) => h['name'] as String).toList();
          });
        } else {
          setState(() {
            _suggestions = [];
          });
        }
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    } catch (e) {
      print("Error fetching hospital suggestions: $e");
      setState(() {
        _suggestions = [];
      });
    }
  }



///////////////////////////////////////////


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double dialogWidth = width > 600 ? width * 0.4 : width * 0.85;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
  elevation: 0,
  backgroundColor: const Color(0xFFF2F5FF),
  leading: Visibility(
    visible: !kIsWeb, 
    child: IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),
),
      body: Center(
        child: Container(
          width: dialogWidth,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      "Blood Donation Request",
                      style: TextStyle(
                        color: Color(0xff613089),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Blood Group Selection Row
                  _buildLabel("Blood Type"),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: bloodTypes.map((group) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedBloodType = group;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: selectedBloodType == group
                                  ? const Color(0xff613089)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedBloodType == group
                                    ? const Color(0xff613089)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                group,
                                style: TextStyle(
                                  color: selectedBloodType == group
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Units Dropdown
                  const SizedBox(height: 15),
                  _buildLabel("Units required"),
                  DropdownButtonFormField<int>(
                    value: selectedUnit,
                    items: availableUnits.map((unit) {
                      return DropdownMenuItem<int>(
                        value: unit,
                        child: Text('$unit unit(s)'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedUnit = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Select unit(s)",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      labelStyle: const TextStyle(color: Color(0xff613089)),
                      prefixIcon: const Icon(Icons.water_drop,
                          color: Color(0xff613089)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xffb41391)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xff613089)),
                    validator: (value) {
                      if (value == null || value == 0) {
                        return 'Please select a unit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  /* _buildLabel("Phone number"),
                _buildTextFormField(
                  controller: _phoneController,
                  hint: "Enter phone number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),*/

                  _buildLabel("Hospital name"),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      // print(textEditingValue.text);
                      _getHospitalSuggestions(textEditingValue.text);

                      return _suggestions.where((suggestion) => suggestion
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selectedHospital) {
                      _hospitalController.text = selectedHospital;
                      // print(selectedHospital);
                      _getHospitalArabicName(selectedHospital);
                      print(_hospitalArabicName);
                      _getHospitalCoordinates(_hospitalArabicName!);
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      _hospitalController = controller;
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: _inputDecoration(
                            "Enter hospital name", Icons.local_hospital),
                      );
                    },
                  ),

                  const SizedBox(height: 15),
                  SizedBox(
                    height: 200,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(latitude, longitude),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latitude, longitude),
                              width: 80.0,
                              height: 80.0,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                 const SizedBox(height: 25),

                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff613089),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 12),
                      ),
                      child: const Text(
                        "Request",
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
  }



  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
      labelStyle: const TextStyle(color: Color(0xff613089)),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xffb41391)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Future<void> _submitForm() async {
    if (selectedBloodType == null || _hospitalCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a blood type and hospital city.")),
      );
      return;
    }

    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/users'));

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      String? requiredBloodType = selectedBloodType;
      String? requiredLocation = _hospitalCity;

      final eligibleUsers = users.where((user) {
        final publicData = user['medicalCard']['publicData'];
        final bloodType = publicData['bloodType'] ?? '';
        final lastDonationDate =
            DateTime.tryParse(publicData['lastBloodDonationDate'] ?? '') ??
                DateTime(2000);
        final location = user['location'] ?? '';
        final gender = publicData['gender'] ?? '';
        final allowedDuration =
            gender == 'Female' ? const Duration(days: 120) : const Duration(days: 90);
        final allowedDate = DateTime.now().subtract(allowedDuration);

        return bloodType == requiredBloodType &&
            lastDonationDate.isBefore(allowedDate) &&
            location == requiredLocation;
      }).toList();

      if (eligibleUsers.isNotEmpty) {
        eligibleUsers.forEach((user) {
          _createDonationRequest(user['_id']);
          _sendNotification(user['_id'], "MediCardia",
              "A chance to save a life! Blood donation needed for type $requiredBloodType at [Hospital Name].");
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Request sent to ${eligibleUsers.length} eligible donors!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No eligible donors found.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch users.")),
      );
    }

    bloodTypes.clear();
    availableUnits.clear();
    _hospitalController.clear();
    // Navigate back to the previous page
    Navigator.pop(context);
  }

  Future<void> _createDonationRequest(String assignedUserId) async {
    final userId = await storage.read(key: 'userid');
    if (userId == null) {
      print("User ID not found in storage.");
      return;
    }

    final Map<String, dynamic> requestPayload = {
      'bloodType': selectedBloodType,
      'units': selectedUnit.toString(),
      'hospital': _hospitalId,
      'createdByDoctor': userId,
      'requiredDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'assignedToUser': assignedUserId,
    };

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/donationrequest/addRequest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode == 201) {
      print("Donation request added successfully.");
    } else {
      print(
          "Failed to add donation request. Status code: ${response.statusCode}");
    }
  }

  void _sendNotification(
      String receiverId, String title, String message) async {
    final DatabaseReference usersRef =
        FirebaseDatabase.instance.ref('users/$receiverId');
    final DataSnapshot snapshot = await usersRef.get();

    if (snapshot.exists) {
      final String? fcmToken = snapshot.child('fcmToken').value as String?;

      if (fcmToken != null) {
        try {
          await sendNotifications(
              fcmToken: fcmToken,
              title: title,
              body: message,
              userId: receiverId,
              type: 'donation');
          print('Notification sent successfully');
        } catch (error) {
          print('Error sending notification: $error');
        }
      } else {
        print('FCM token not found for the user.');
      }
    } else {
      print('User not found in the database.');
    }
  }
/*
Future<void> addpermissionToDB(String deadline, selectedPriority, String text ,String patientId, String name) async {
  try {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('Permission').push();
    print('Permission added to Firebase Realtime Database successfully.');

    await ref.set({
      'doctorid': await storage.read(key: 'userid'),
      'userId': patientId,
      'selectedPriority': selectedPriority,
      'body': text,
      'deadline':deadline,
      'name':name,
    });

    print('Permission added to Firebase Realtime Database successfully.');
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error adding permission: $error')),
);

    print('Error adding notification to Firebase: $error');
  }
}

*/
}
