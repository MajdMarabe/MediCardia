import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
class DiabetesQuickAddPage extends StatefulWidget {
  @override
  _DiabetesQuickAddPageState createState() => _DiabetesQuickAddPageState();
}

class _DiabetesQuickAddPageState extends State<DiabetesQuickAddPage> {
  final TextEditingController _dateTimePillController = TextEditingController();
    final TextEditingController _dateTimeClucoseController = TextEditingController();
      final TextEditingController _dateTimeInsulinController = TextEditingController();
  final TextEditingController _pillNameController = TextEditingController(); 
final TextEditingController  _glucoseLevelController = TextEditingController(); 
  final Color primaryColor = Color(0xff613089);
  final Color accentColor = Color(0xff9c27b0);
  final Color backgroundColor = Color(0xfff4e6ff);

 int _pillCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor:  backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Quick Add',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildQuickAddOption(
        icon: Icons.bloodtype,
        title: 'Add Glucose',
        gradientColors: [primaryColor, accentColor],
        onTap: () => _showAddGlucoseModal(context),
        shape: BoxShape.rectangle, // Rounded corners or different shape
        borderRadius: BorderRadius.circular(30), // Rounded corners
      ),
      SizedBox(height: 20),
      _buildQuickAddOption(
         icon: FontAwesomeIcons.capsules,
        title: 'Add Pill',
        gradientColors: [accentColor, primaryColor.withOpacity(0.8)],
        onTap: () => _showAddPillModal(context),
        shape: BoxShape.rectangle, // Rounded corners or different shape
        borderRadius: BorderRadius.circular(30), // Rounded corners
      ),
      SizedBox(height: 20),
      _buildQuickAddOption(
        icon: FontAwesomeIcons.syringe,
        title: 'Add Insulin',
        gradientColors: [primaryColor, accentColor],
        onTap: () => _showAddInsulinModal(context),
        shape: BoxShape.rectangle, // Rounded corners or different shape
        borderRadius: BorderRadius.circular(30), // Rounded corners
      ),
    ],
  ),
),
    );
    
    
  }

  Widget _buildQuickAddOption({
  required IconData icon,
  required String title,
  required List<Color> gradientColors,
  required VoidCallback onTap,
  BoxShape shape = BoxShape.rectangle, 
  BorderRadiusGeometry? borderRadius,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        shape: shape,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius, // Apply rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}


void _showAddGlucoseModal(BuildContext context) async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white, // Keeping background white for contrast
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(  // Wrap the Column with SingleChildScrollView
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Color(0xff613089)), // Close button color
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                },
              ),
            ),
            Center(
              child: Text(
                'GLUCOSE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089), // Primary color for the title
                ),
              ),
            ),
            SizedBox(height: 16),
            // Date & Time Section with Grey Background
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Grey background for Date & Time section
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date & time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      _selectDateTime(context, _dateTimeClucoseController);
                    },
                    child: Text(
                      _dateTimeClucoseController.text.isEmpty
                          ? 'Select Date & Time'
                          : _dateTimeClucoseController.text,
                      style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Glucose Level Section with Input Field
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xfff4e6ff), // Light purple background for input fields
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Glucose Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff613089), // Primary color for glucose level
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _glucoseLevelController, // Add your TextEditingController
                    decoration: InputDecoration(
                      hintText: 'Value',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400, 
                        fontSize: 14, 
                        fontStyle: FontStyle.italic,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      suffixText: 'mg/dl',
                      suffixStyle: TextStyle(
                        color: Color(0xff613089),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 12.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            MealOptionButtons(primaryColor: Color(0xff613089)), // Pass the primary color here
            SizedBox(height: 24),
            // Save Button
            ElevatedButton(
              onPressed: () async {
                // Validate input
                if (_glucoseLevelController.text.isEmpty || _dateTimeClucoseController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }

                // Get glucose level and measurement type
                final glucoseLevel = int.parse(_glucoseLevelController.text);
                final measurementType = "before_meal";  // Update this based on your logic

                // Call API to save the glucose level
                final response = await _addGlucoseReading(glucoseLevel, measurementType, token);
               final data = jsonDecode(response.body);

                // Handle the response
                if (response != null && response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Reading added successfully!")),
                  );
                  Navigator.of(context).pop(); // Close modal after success
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to add reading")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Color(0xff613089), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<http.Response> _addGlucoseReading(int glucoseLevel, String measurementType, String? token) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/bloodSugar/add');
  
  final headers = {
    'Content-Type': 'application/json',
    'token': token ?? '',
  };

  final body = jsonEncode({
    'glucoseLevel': glucoseLevel,
    'measurementType': measurementType,
  'date': _dateTimeClucoseController.text
  });

  final response = await http.post(url, headers: headers, body: body);
  
  return response;
}

Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
  DateTime selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Color(0xff613089), 
          hintColor: Color(0xffb41391), 
          buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      );
    },
  ) ?? DateTime.now();

  TimeOfDay selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Color(0xff613089), 
          hintColor: Color(0xffb41391), 
          timePickerTheme: TimePickerThemeData(
            dialHandColor: Color(0xff613089), 
            dialTextColor: Colors.black, 
            backgroundColor: Colors.white, 
            dayPeriodTextColor: Color(0xff613089), 
          ),
        ),
        child: child!,
      );
    },
  ) ?? TimeOfDay.now();

  final selectedDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  controller.text =
      "${selectedDateTime.toLocal().toString().split(' ')[0]}, ${selectedTime.format(context)}";
}



void _showAddPillModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: primaryColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Center(
                    child: Text(
                      'PILL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Grey background for Date & Time section
                      borderRadius: BorderRadius.circular(10),
                    ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date & Time',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87, // Darker text for contrast
                          ),
                      ),
                      TextButton(
                        onPressed: () {
                           _selectDateTime(context, _dateTimePillController);
                        },
                        child: Text(
                          _dateTimePillController.text.isEmpty
                              ? 'Select Date & Time'
                              : _dateTimePillController.text,
                          style: TextStyle(color: Colors.grey[600],fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                  ),
                  SizedBox(height: 16),
                 
                      // Pill Name Container with TextField
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xfff4e6ff), // Light purple background for input fields
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pill Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff613089), // Same color as previous label
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'e.g., Paracetamol',
                       hintStyle: TextStyle(
      color: Colors.grey.shade400, // لون النص الافتراضي
      fontSize: 14, // حجم النص
      fontStyle: FontStyle.italic, // نمط النص
    ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 12.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xfff4e6ff),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Pill Count',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w600,
                        //     color: primaryColor,
                        //   ),
                        // ),
                        // SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_pillCount > 1) {
                                    _pillCount--;
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.remove_circle,
                                color: primaryColor,
                                size: 36,
                              ),
                            ),
                            // Directly displaying the updated pill count
                            Text(
                              '$_pillCount pill',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff613089)
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _pillCount++;
                                });
                              },
                              icon: Icon(
                                Icons.add_circle,
                                color: primaryColor,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle Save Logic Here
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}







void _showAddInsulinModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(  // Added SingleChildScrollView
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Color(0xff613089)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Center(
              child: Text(
                'INSULIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Date & Time Section with Grey Background
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Grey background for Date & Time section
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date & time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      _selectDateTime(context, _dateTimeInsulinController);
                    },
                    child: Text(
                      _dateTimeInsulinController.text.isEmpty
                          ? 'Select Date & Time'
                          : _dateTimeInsulinController.text,
                      style: TextStyle(color: Colors.grey[600],fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Insulin Amount Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xfff4e6ff),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insulin Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff613089),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Amount',
                       hintStyle: TextStyle(
      color: Colors.grey.shade400, // لون النص الافتراضي
      fontSize: 14, // حجم النص
      fontStyle: FontStyle.italic, // نمط النص
    ),
                      fillColor: Colors.white,
                      filled: true,
                      suffixText: 'mg/dl',
                      suffixStyle: TextStyle(
                        color: Color(0xff613089),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 12.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Updated MealOptionButtons for Insulin
            InsulinOptionButtons(primaryColor: Color(0xff613089)),
            SizedBox(height: 24),
            // Save Button
            ElevatedButton(
              onPressed: () {
                // Handle Save Logic Here
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Color(0xff613089),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



  void _showInputModal(
    BuildContext context, {
    required String title,
    required String fieldLabel,
    String? suffixText,
    required Color fieldColor,
    required List<String> buttons,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: fieldLabel,
                suffixText: suffixText,
                fillColor: fieldColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (buttons.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: buttons
                    .map((btn) => ElevatedButton(
                          onPressed: () {},
                          child: Text(btn),
                        ))
                    .toList(),
              ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MealOptionButtons extends StatefulWidget {
  final Color primaryColor;
  MealOptionButtons({required this.primaryColor});

  @override
  _MealOptionButtonsState createState() => _MealOptionButtonsState();
}

class _MealOptionButtonsState extends State<MealOptionButtons> {
  String selectedMeal = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMealButton('Before Meal', Icons.fastfood, widget.primaryColor),
        _buildMealButton('After Meal', Icons.dinner_dining, widget.primaryColor),
      ],
    );
  }

  Widget _buildMealButton(String text, IconData icon, Color primaryColor) {
    bool isSelected = selectedMeal == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMeal = isSelected ? '' : text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
          border: isSelected
              ? Border.all(color: primaryColor, width: 2)
              : Border.all(color: primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey),
            SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class InsulinOptionButtons extends StatefulWidget {
  final Color primaryColor;
  InsulinOptionButtons({required this.primaryColor});

  @override
  _InsulinOptionButtonsState createState() => _InsulinOptionButtonsState();
}

class _InsulinOptionButtonsState extends State<InsulinOptionButtons> {
  String selectedInsulin = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInsulinButton('Short-acting', Icons.access_alarm, widget.primaryColor),
        _buildInsulinButton('Long-acting', Icons.hourglass_empty, widget.primaryColor),
      ],
    );
  }

  Widget _buildInsulinButton(String text, IconData icon, Color primaryColor) {
    bool isSelected = selectedInsulin == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedInsulin = isSelected ? '' : text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
          border: isSelected
              ? Border.all(color: primaryColor, width: 2)
              : Border.all(color: primaryColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey),
            SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 void viewDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text(message), // Displaying the passed message
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dialog with Custom Message'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Pass the custom message to the viewDialog function
            viewDialog(context, "Reading added successfully!");
          },
          child: Text('Show Dialog'),
        ),
      ),
    );
  }