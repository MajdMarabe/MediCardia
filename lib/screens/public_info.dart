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



class PublicInfo extends StatefulWidget {
  final String userId; // Accepting userId from the constructor

  const PublicInfo({super.key, required this.userId});

  @override
  _PublicInfoState createState() => _PublicInfoState();
}

class _PublicInfoState extends State<PublicInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sensitivityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _drugNameController = TextEditingController();
 final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Variables
  String? _selectedDrugType;
  bool _isTemporary = false;
  bool _isActive = true;
  List<Map<String, dynamic>> _drugsList = [];
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
    _fetchUserName(); // Fetch the user's name when the widget is initialized
    
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


  Future<void> _fetchUserName() async {
    String userId = widget.userId;
    String apiUrl = '${ApiConstants.baseUrl}/users/$userId';

  
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userName = data['username'] ?? 'No Name'; // Set username
        });
      } else {
        print('Failed to load name, status code: ${response.statusCode}');
        print('Response body: ${response.body}'); // Log response for debugging
        setState(() {
          _userName = 'Unknown User'; // Fallback if the user is not found
        });
      }
    } catch (e) {
      print('Error fetching name: $e'); // Log the error for debugging
      setState(() {
        _userName = 'Error fetching name'; // Fallback on error
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
          _buildProfileHeader(),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
        borderRadius: BorderRadius.circular(15), // Add border radius here
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
                                state.didChange(value);  // Update the FormField state
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                      const SizedBox(height: 20),                    const SizedBox(height: 20),
                    const Text(
                      'Select Chronic Diseases',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff613089)),
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

                    // Drugs Section with Barcode
                    const Text(
                      'Add Drugs',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff613089)),
                    ),
                    const SizedBox(height: 10),
                    _buildDrugForm(),


                    const SizedBox(height: 30),
  _buildDatePickerField(),
                      const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _submitForm();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PrivateInfo(userId: widget.userId)),
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
Widget _buildDrugForm() {
  return Column(
    children: [
      // Drug Name Row
      Row(
        children: [
          Expanded(
            child: _buildTextFormField(
              controller: _drugNameController,
              label: 'Drug Name',
              hint: 'e.g., Rovatin',
              icon: Icons.medical_services,
            ),
          ),
          IconButton(
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
              }
            },
          ),
        ],
      ),
      
      // Add space between fields
      SizedBox(height: 16.0),

      // Drug Type Dropdown
      DropdownButtonFormField<String>(
        value: _selectedDrugType,
        items: ['Permanent', 'Temporary']
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedDrugType = value!;
            _isTemporary = _selectedDrugType == 'Temporary';
          });
        },
        decoration: InputDecoration(
          labelText: 'Drug Type',
          prefixIcon: Icon(Icons.category, color: Color(0xff613089)),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          filled: true,
          fillColor: Color(0xFFF3F3F3), 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Color(0xff613089), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Color(0xff613089), width: 2.0),
          ),
        ),
      ),
      
      SizedBox(height: 16.0),

      if (_isTemporary)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  prefixIcon: Icon(Icons.calendar_today, color: Color(0xff613089)),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  filled: true,
                  fillColor: Color(0xFFF3F3F3), 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Color(0xff613089), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Color(0xff613089), width: 2.0),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _startDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  prefixIcon: Icon(Icons.calendar_today, color: Color(0xff613089)),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  filled: true,
                  fillColor: Color(0xFFF3F3F3), 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Color(0xff613089), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Color(0xff613089), width: 2.0),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _endDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      
      SizedBox(height: 16.0),
/*
      CheckboxListTile(
        value: _isActive,
        onChanged: (value) {
          setState(() {
            _isActive = value!;
          });
        },
        title: const Text('Still in Use'),
        activeColor: Color(0xff613089), 
      ),
      */
      SizedBox(height: 16.0),

      ElevatedButton(
        onPressed: _addDrug,
        child: const Text('Add Drug'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Color(0xff613089), // Text color
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    ],
  );
}



Future<void> _scanBarcode() async {
  try {
    String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", 
      "Cancel", 
      true, 
      ScanMode.BARCODE, 
    );

    if (barcodeScanResult != '-1') {
      print("Scanned Barcode: $barcodeScanResult");

     await getDrugByBarcode(barcodeScanResult);

    
    }
  } catch (e) {
    print("Error scanning barcode: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to scan barcode')),
    );
  }
}
Future<void> _addDrug() async {
  if (_drugNameController.text.isNotEmpty) {
    Map<String, dynamic> drugData = {
      'drugName': _drugNameController.text.trim(),
      'isPermanent': !_isTemporary, 
      'usageStartDate': _isTemporary ? _startDateController.text : null,
      'usageEndDate': _isTemporary ? _endDateController.text : null,
    };

    print('Drug Data: ${json.encode(drugData)}');

    String userId = widget.userId;
    String apiUrl = '${ApiConstants.baseUrl}/users/$userId/adddrugs';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(drugData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drug added successfully')),
        );
        setState(() {
          _drugsList.add({
            'name': _drugNameController.text.trim(),
            'type': _selectedDrugType,
            'startDate': _isTemporary ? _startDateController.text : null,
            'endDate': _isTemporary ? _endDateController.text : null,
            'isActive': _isActive,
          });
           _drugNameController.clear();
           _endDateController.clear();
           _startDateController.clear();
           
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add drug: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}


 Future<void> getDrugByBarcode(String barcode) async {
  final String apiUrl = '${ApiConstants.baseUrl}/drugs/barcode?barcode=$barcode'; 

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final drugName = data['drugName'];

      setState(() {
if (_drugNameController.text.isEmpty) {
    _drugNameController.text = drugName;
  } else {
    _drugNameController.text = '${_drugNameController.text}, $drugName';
  }      });
    } else {
      setState(() {
        _drugNameController.text = 'Drug not found';
      });
    }
  } catch (e) {
    print('Error: $e');
    setState(() {
      _drugNameController.text = 'Error retrieving drug information';
    });
  }
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff613089), // Custom color for this text
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



  Future<void> _submitForm() async {
  String? base64Image;
  if (_imageFile != null) {
    base64Image = encodeImageToBase64(_imageFile);
  }

  List<String> allergiesArray = _sensitivityController.text.isNotEmpty
      ? _sensitivityController.text.split(',')
      : [];

  Map<String, dynamic> medicalInfo = {
    "publicData": {
      "idNumber": _idNumberController.text.isNotEmpty ? _idNumberController.text : null,
      "age": int.tryParse(_ageController.text) ?? null,
      "gender": _selectedGender ?? null,
      "bloodType": _selectedBloodType ?? null,
      "chronicConditions": _selectedChronicDiseases.isNotEmpty ? _selectedChronicDiseases : [],
      "allergies": allergiesArray.isNotEmpty ? allergiesArray : [],
      "phoneNumber": _phoneController.text.isNotEmpty ? _phoneController.text : null,
      "lastBloodDonationDate": _lastDonationDate?.toIso8601String() ?? "",
    }
  };

  // Add the image only if it's not null
  if (base64Image != null) {
    medicalInfo["publicData"]["image"] = base64Image;
  }

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
      // Only show error if the status code is not 200
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