import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DiabetesQuickAddPage extends StatefulWidget {
  @override
  _DiabetesQuickAddPageState createState() => _DiabetesQuickAddPageState();
}

class _DiabetesQuickAddPageState extends State<DiabetesQuickAddPage> {
  final TextEditingController _dateTimeClucoseController = TextEditingController();
  final TextEditingController _glucoseLevelController = TextEditingController();
  final Color primaryColor = const Color(0xff613089);
  final Color accentColor = const Color(0xff9c27b0);
  final Color backgroundColor = const Color(0xfff4e6ff);
  String _glucoseErrorText = ''; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: kIsWeb
              ? AppBar(
                  backgroundColor: const Color(0xFFF2F5FF),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  title: const Text(
          'Quick Add',
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Quick Add',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Center( 
        child: _buildQuickAddOption(
          icon: Icons.bloodtype,
          title: 'Add Glucose',
          gradientColors: [primaryColor, accentColor],
          onTap: () => _showAddGlucoseModal(context),
        ),
      ),
    );
  }



 /////////////////////////////


  Widget _buildQuickAddOption({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGlucoseModal(BuildContext context) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff613089)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const Center(
                child: Text(
                  'GLUCOSE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff613089),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Date & Time Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
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
              const SizedBox(height: 16),
              // Glucose Level Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xfff4e6ff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Glucose Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff613089),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: _glucoseLevelController,
                      decoration: InputDecoration(
                        hintText: 'Value',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontStyle: FontStyle.italic),
                        fillColor: Colors.white,
                        filled: true,
                        suffixText: 'mg/dl',
                        suffixStyle: const TextStyle(color: Color(0xff613089)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _glucoseErrorText.isEmpty ? null : _glucoseErrorText, 
                      ),
                      onChanged: (value) {
                        setState(() {
                          _glucoseErrorText = '';
                        });

                        final glucoseLevel = int.tryParse(value);
                        if (glucoseLevel == null || glucoseLevel < 50 || glucoseLevel > 450) {
                          setState(() {
                            _glucoseErrorText = 'Please enter a value between 50 and 450'; 
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const MealOptionButtons(primaryColor: Color(0xff613089)),
              const SizedBox(height: 24),
              // Save Button
              ElevatedButton(
                onPressed: () async {
                  // Validate input
                  if (_glucoseLevelController.text.isEmpty || _dateTimeClucoseController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill in all fields")),
                    );
                    return;
                  }

                  // Get glucose level and check if it's within the valid range
                  final glucoseLevel = int.tryParse(_glucoseLevelController.text);
                  if (glucoseLevel == null || glucoseLevel < 50 || glucoseLevel > 450) {
                    setState(() {
                      _glucoseErrorText = "Please enter a value between 50 and 450"; 
                    });
                    return;
                  }

                  const measurementType = "before_meal"; 

                  // Call API to save the glucose level
                  final response = await _addGlucoseReading(glucoseLevel, measurementType, token);
                  final data = jsonDecode(response.body);

                  // Handle the response
                  if (response != null && response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Reading added successfully!")),
                    );
                     // Retain the date and glucose level after successful save
                    setState(() {
                      _dateTimeClucoseController.text = '';  
                      _glucoseLevelController.text = '';     
                    });

                    Navigator.of(context).pop(); 
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to add reading")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xff613089), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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


///////////////////////////////////////

  
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
            primaryColor: const Color(0xff613089),
            hintColor: const Color(0xffb41391),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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
            primaryColor: const Color(0xff613089),
            hintColor: const Color(0xffb41391),
            timePickerTheme: const TimePickerThemeData(
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

    if (mounted) {
      controller.text =
          "${selectedDateTime.toLocal().toString().split(' ')[0]}, ${selectedTime.format(context)}";
    }
  }
}



/////////////////////////////////


class MealOptionButtons extends StatefulWidget {
  final Color primaryColor;
  const MealOptionButtons({required this.primaryColor});

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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            const SizedBox(height: 5),
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
