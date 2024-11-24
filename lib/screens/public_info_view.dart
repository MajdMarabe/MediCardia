import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/private_info.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();


class PublicInfoViewPage extends StatefulWidget {
  final String userId; // Accepting userId from the constructor

  const PublicInfoViewPage({super.key, required this.userId});

  @override
  _PublicInfoState createState() => _PublicInfoState();
}

class _PublicInfoState extends State<PublicInfoViewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sensitivityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _drugsController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedGender;
  List<String> _selectedChronicDiseases = [];
  String _userName = 'Loading...'; // Initialize username

  List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  List<String> genders = ['Male', 'Female'];
  List<Map<String, dynamic>> chronicDiseases = [
{'name': 'Diabetes', 'icon': Icons.bloodtype},
{'name': 'Hypertension', 'icon': Icons.monitor_heart},
{'name': 'Asthma', 'icon': Icons.air},
{'name': 'Cancer', 'icon': Icons.coronavirus},
{'name': 'Kidney Failure', 'icon': Icons.opacity},

    {'name': 'None', 'icon': Icons.check_circle_outline},
  ];

  

  DateTime? _lastDonationDate;
  
  XFile? _imageFile; // Variable to hold the selected image
/////
  @override
  void initState() {
    super.initState();
   // _fetchUserName(); // Fetch the user's name when the widget is initialized
    _getUserData();

    
  }

String? encodeImageToBase64(XFile? imageFile) {
  if (imageFile == null) return null;

  // Convert XFile to File
  File file = File(imageFile.path);

  // Read image bytes from the file
  final bytes = file.readAsBytesSync();

  // Return the Base64-encoded string of the image bytes
  return base64Encode(bytes);
}
 Future<void> getDrugByBarcode(String barcode) async {
  final String apiUrl = '${ApiConstants.baseUrl}/drugs/barcode?barcode=$barcode'; // Query parameter in URL

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final drugName = data['drugName'];

      setState(() {
if (_drugsController.text.isEmpty) {
    _drugsController.text = drugName;
  } else {
    _drugsController.text = '${_drugsController.text}, $drugName';
  }      });
    } else {
      setState(() {
        _drugsController.text = 'Drug not found';
      });
    }
  } catch (e) {
    print('Error: $e');
    setState(() {
      _drugsController.text = 'Error retrieving drug information';
    });
  }
}

Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    // Show dialog to choose between camera and gallery
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery, // or ImageSource.camera
      imageQuality: 100, // Optional: set image quality (0-100)
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile; 
        // Update the image file
      });
    }
  }


Future<void> _selectLastDonationDate(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Last Donation Date', style: TextStyle(color: Color(0xff613089))),
        content: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: TableCalendar(
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.now(),
                  focusedDay: _lastDonationDate ?? DateTime.now(),
                  selectedDayPredicate: (day) {
                    return isSameDay(_lastDonationDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _lastDonationDate = selectedDay; // Update the selected date
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Color(0xffb41391),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0xff613089),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    defaultDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(color: Color(0xff613089), fontSize: 20),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xff613089)),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xff613089)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Allow the user to clear the date selection
              setState(() {
                _lastDonationDate = null; // Set to null when dialog is canceled
              });
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel', style: TextStyle(color: Color(0xff613089))),
          ),
        ],
      );
    },
  );
}


//////
  List<String> drugsList = [];  // List to store user's drugs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff613089), Color(0xffb41391)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header Section
            _buildProfileHeader(),
            const SizedBox(height: 20),

            // Scrollable Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Personal Info Section
                      _buildSectionTitle('Personal Info'),
                      const SizedBox(height: 10),
                      _buildTextFormField(
                        controller: _idNumberController,
                        label: 'ID Number',
                        hint: 'Enter ID Number',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length != 9) {
                            return 'Please enter a valid 9-digit ID number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _ageController,
                        label: 'Age',
                        hint: 'Enter Age',
                        icon: Icons.mood,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        label: 'Gender',
                        hint: 'Select Gender',
                        items: genders,
                        selectedValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                   // Drugs Section: List of Drugs
_buildSectionTitle('Medications'),
_buildTextFormField(
  controller: _drugsController,
  label: 'Drugs',
  hint: 'i.e Rovatin, Advil,..',
  icon: Icons.medical_services,
  suffixIcon: IconButton(
    icon: const Icon(Icons.camera_alt, color: Color(0xff613089)),
    onPressed: () async {
      String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", 
        "Cancel", 
        true, 
        ScanMode.BARCODE,
      );

      if (barcodeScanResult != '-1') {
        print("Scanned Barcode: $barcodeScanResult");
        await getDrugByBarcode(barcodeScanResult);

        setState(() {
          drugsList.add(barcodeScanResult);
        });
      }
    },
  ),
),
const SizedBox(height: 20),
const SizedBox(height: 10),
ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: drugsList.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(drugsList[index]),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          setState(() {
            drugsList.removeAt(index);
          });
        },
      ),
    );
  },
),
const SizedBox(height: 20),
/*
                      ElevatedButton(
                        onPressed: () async {
                          String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
                            "#ff6666", // Color for the scan line
                            "Cancel", // Cancel button text
                            true, // Show flash icon
                            ScanMode.BARCODE, // Scan mode (can also be QR_CODE)
                          );

                          // Check if the scan was successful and update the drugs list
                          if (barcodeScanResult != '-1') {
                            print("Scanned Barcode: $barcodeScanResult");

                            // Example of getting drug by barcode
                            await getDrugByBarcode(barcodeScanResult);

                            // Add the scanned drug to the list (use the actual drug name)
                            setState(() {
                              drugsList.add(barcodeScanResult);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: const Color(0xff613089),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Add Medication',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),

*/
                      // Medical Info Section
                      _buildSectionTitle('Medical Info'),
                      const SizedBox(height: 10),
                      // Blood Type with Validation
                      FormField<String>(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a blood type';
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Blood Type',
                              labelStyle: const TextStyle(color: Color(0xff613089)),
                              errorText: state.hasError ? state.errorText : null,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xffb41391),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedBloodType,
                                hint: const Text(
                                  'Select Blood Type',
                                  style: TextStyle(color: Color(0xff613089)),
                                ),
                                items: bloodTypes.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.bloodtype, color: Color(0xff613089)),
                                        const SizedBox(width: 10),
                                        Text(item),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBloodType = value;
                                    state.didChange(value);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Chronic Diseases',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff613089)),
                      ),
                      const SizedBox(height: 10),
                      _buildChronicDiseasesChips(),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _sensitivityController,
                        label: 'Allergies',
                        hint: 'Enter Allergies',
                        icon: Icons.safety_check,
                      ),
                      const SizedBox(height: 20),
                   
                      _buildDatePickerField(),
                      const SizedBox(height: 30),

                      // Submit Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _submitForm();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivateInfo(userId: widget.userId),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xffb41391),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




Widget _buildProfileHeader() {
  return Column(
    children: [
      GestureDetector(
        onTap: _selectImage, // Function to select an image
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 50, // Size of the avatar
              backgroundColor: Colors.grey[300], // Background color for the placeholder
              child: _imageFile != null 
                  ? ClipOval(
                      child: Image.file(
                        File(_imageFile!.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover, // Ensure the image covers the circle
                      ),
                    )
                  : const SizedBox.shrink(), // Placeholder for image
            ),
            // Only show the icon and text if there is no image
            if (_imageFile == null) ...[
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo, // Icon for adding a photo
                    size: 24, // Icon size
                    color: Color(0xff613089), // Icon color
                  ),
                  SizedBox(height: 5), // Space between icon and text
                  Text(
                    'Add Photo', // Placeholder text
                    style: TextStyle(
                      fontSize: 12, // Size of the text
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089), // Text color
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 10),
      Text(
        _userName, // Display fetched username
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 22, // Username font size
          color: Color(0xff613089), // Matching text color with the theme
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoCard(
            'Please fill it\nyou should know that every doctor can see this', 
            'Your MediCard public information', 
            Icons.favorite,
          ),
          // Add more info cards if needed
        ],
      ),
    ],
  );
}





  // Helper method to build information cards like in the header
  Widget _buildInfoCard(String title, String value, IconData icon) {
  return Container(
   // width: 100,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: const Color(0xffb41391)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xff613089),
        ),
      ),
    );
  }

// Helper method to build text form fields
Widget _buildTextFormField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  int maxLines = 1,
  String? Function(String?)? validator,
  Widget? suffixIcon, // Change type to Widget
  TextInputType? keyboardType, // Add keyboardType parameter
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType, // Set keyboardType here
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
      color: Colors.grey.shade400, // لون النص الافتراضي
      fontSize: 14, // حجم النص
      fontStyle: FontStyle.italic, // نمط النص
    ),
      labelStyle: const TextStyle(color: Color(0xff613089)),
      prefixIcon: Icon(icon, color: const Color(0xff613089)),
      suffixIcon: suffixIcon,
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
    ),
    validator: validator,
  );
}



  // Helper method to build dropdown fields
Widget _buildDropdownField({
  required String label,
  required String hint,
  required List<String> items,
  required String? selectedValue,
  required void Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
     prefixIcon: const Padding(
    padding: EdgeInsets.only(left: 10.0,top: 8.0), // Add padding before the icon
    child: FaIcon(
      FontAwesomeIcons.venusMars,
      color: Color(0xff613089),
    ),
  ), // Icon before the label
      labelText: label,
      hintText: hint,
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
    ),
    value: selectedValue,
    onChanged: onChanged,
    items: items.map((String value) {
      IconData icon = value == 'Male' ? Icons.male : Icons.female; // Determine the icon based on gender

      return DropdownMenuItem<String>(
        value: value,
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff613089)), // Gender icon
            const SizedBox(width: 10),
            Text(value),
          ],
        ),
      );
    }).toList(),
  );
}



  // Helper method to build chronic diseases chips
Widget _buildChronicDiseasesChips() {
  return Wrap(
    spacing: 10.0,
    children: chronicDiseases.map((disease) {
      final isSelected = _selectedChronicDiseases.contains(disease['name']);
      return FilterChip(
        label: Text(
          disease['name'],
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xff613089), // Text color changes based on selection
          ),
        ),
        avatar: Icon(disease['icon'], color: isSelected ? Colors.white : Color(0xff613089)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedChronicDiseases.add(disease['name']);
            } else {
              _selectedChronicDiseases.remove(disease['name']);
            }
          });
        },
        selectedColor: const Color(0xffb41391),
        backgroundColor: Colors.white, // Background color for unselected state
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      );
    }).toList(),
  );
}


Widget _buildDatePickerField() {
  return TextFormField(
    controller: TextEditingController(
      text: _lastDonationDate != null ? DateFormat('yyyy-MM-dd').format(_lastDonationDate!.toLocal()) : null,
    ),

    readOnly: true, // Prevent keyboard from appearing
    onTap: () {
      _selectLastDonationDate(context); // Call the date selection method
    },
    decoration: InputDecoration(
      labelText: 'Last Donation Date',
      hintText: 'Select Last Donation Date',
       labelStyle: const TextStyle(color: Color(0xff613089)),
      prefixIcon: const Icon(Icons.calendar_today, color: Color(0xff613089)), // Icon before hint text
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
      ),
      focusedBorder: OutlineInputBorder( // Border when focused
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0), // Change this to the color you want
      ),
      enabledBorder: OutlineInputBorder( // Border when enabled
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
      ),
    ),
  );
}
Future<void> _getUserData() async {
  // Read the user ID asynchronously
  final userId = await storage.read(key: 'userid');

  // Check if userId is not null
  if (userId != null) {
    // Call the API to fetch user data
    await _fetchUserData(userId);
  } else {
    print('User ID not found');
  }
}
Future<void> _fetchUserData(String userId) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/users/$userId'); // Replace with your actual API URL

  try {
    final response = await http.get(url);

    // Handle the HTTP response
    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);

      // Ensure response contains the expected fields
      if (userData.containsKey('medicalCard') && userData['medicalCard'] != null) {
        final medicalCard = userData['medicalCard'];
        final publicData = medicalCard['publicData'] ?? {};

        // Parsing user profile data
        _idNumberController.text = publicData['idNumber'] ?? '';
        _userName = userData['username'] ?? '';
        _ageController.text = publicData['age']?.toString() ?? '';
        _phoneController.text = publicData['phoneNumber'] ?? '';
        _selectedBloodType = publicData['bloodType'] ?? '';
        _selectedGender = publicData['gender'] ?? '';

        // Parsing lastBloodDonationDate into DateTime
        final lastDonationDateString = publicData['lastBloodDonationDate'];
        if (lastDonationDateString != null && lastDonationDateString.isNotEmpty) {
          _lastDonationDate = DateTime.parse(lastDonationDateString); // Convert string to DateTime
        } else {
          _lastDonationDate = null; // If no date provided, set to null
        }

        // Fetching drugs list
        List<dynamic> drugs = publicData['Drugs'] ?? [];
        setState(() {
          drugsList = List<String>.from(drugs.map((drug) => drug.toString()));
        });
      } else {
        print('User medical data is missing or malformed');
      }
    } else {
      // Handle unsuccessful response
      print('Failed to load user data: ${response.statusCode}');
    }
  } catch (e) {
    // Handle errors during the request
    print('Error: $e');
  }
}


  // Keep the submit function the same as before
Future<void> _submitForm() async {
    String? base64Image = encodeImageToBase64(_imageFile);

  List<String> allergiesArray = _sensitivityController.text.isNotEmpty 
      ? _sensitivityController.text.split(',') 
      : []; 

  Map<String, dynamic> medicalInfo = {
  "publicData": { 
    "idNumber": _idNumberController.text.isNotEmpty ? _idNumberController.text : null,
    "age": int.tryParse(_ageController.text) ?? null,
    "gender": _selectedGender ?? null,
    "bloodType": _selectedBloodType ?? null,
    "chronicConditions": _selectedChronicDiseases.isNotEmpty ? _selectedChronicDiseases : [], // Change here to use empty array
    "allergies": allergiesArray.isNotEmpty ? allergiesArray : [], 
    "phoneNumber": _phoneController.text.isNotEmpty ? _phoneController.text : null,
    "Drugs": _drugsController.text.isNotEmpty 
              ? _drugsController.text.split(',').map((drug) => drug.trim()).toList() 
              : [],
    // Set lastBloodDonationDate to an empty string if not selected
    "lastBloodDonationDate": _lastDonationDate?.toIso8601String() ?? "", // Use an empty string if no date is selected
    "image": base64Image,
  }
};


  print('Request Payload: ${json.encode(medicalInfo)}'); 

  String userId = widget.userId; 
  try {
    String apiUrl = '${ApiConstants.baseUrl}/users/$userId/public-medical-card';
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(medicalInfo),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical information updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medical information: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
}