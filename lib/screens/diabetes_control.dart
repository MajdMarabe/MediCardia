import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_3/screens/glucose_log.dart';
import 'package:flutter_application_3/services/notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class DiabetesControlPage extends StatefulWidget {
  @override
  _DiabetesControlPageState createState() => _DiabetesControlPageState();
}

class _DiabetesControlPageState extends State<DiabetesControlPage> {
  final List<TimeOfDay> _reminderTimes = [];
  late List<FlSpot> weekReadings;
  final storage = const FlutterSecureStorage();
  final TextEditingController _dateTimeClucoseController =
      TextEditingController();
  final TextEditingController _glucoseLevelController = TextEditingController();
  String _glucoseErrorText = '';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    weekReadings = [];
    fetchGlucoseReadings();
  }

  // Fetch glucose readings for the week from the API
  Future<void> fetchGlucoseReadings() async {
    final userid=await storage.read(key: 'userid') ?? '';
    final headers = {
      'Content-Type': 'application/json',
    };
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/bloodSugar/$userid/glucoseCard'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> levels = data['week']['levels'];
      //List<dynamic> labels = data['week']['labels'];

      setState(() {
        weekReadings = List.generate(levels.length, (index) {
          return FlSpot(index.toDouble(), levels[index].toDouble());
        });
      });
    } else {
      throw Exception('Failed to load glucose readings');
    }
  }

  Future<void> _showReminderDialog(BuildContext context,
      {TimeOfDay? existingTime}) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xff613089),
            hintColor: const Color(0xff9c27b0),
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
    );
    if (time != null) {
      final userId = await storage.read(key: 'userid');
      if (userId != null) {
        setState(() {
          if (existingTime == null) {
            _reminderTimes.add(time);

            scheduleReminder(time, userId,'glucose');
          } else {
            int index = _reminderTimes.indexOf(existingTime);
            if (index != -1) {
              _reminderTimes[index] = time;

              scheduleReminder(time, userId,'glucose');
            }
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found!')),
        );
      }
    }
  }

  void _removeReminder(TimeOfDay time) {
    setState(() {
      _reminderTimes.remove(time);
    });
    flutterLocalNotificationsPlugin.cancel(time.hashCode);
  }

  //////////////////////////////////////

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
                  centerTitle: true,
                  title: const Text(
                    'Diabetes Tracking',
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
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF613089)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: const Text(
                    'Diabetes Tracking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
          body: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        constraints.maxWidth > 600 ? 800 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(),
                      const SizedBox(height: 20),
                      _buildQuickAddOption(
                        icon: Icons.bloodtype,
                        title: 'Add Glucose Reading',
                        gradientColors: [
                          const Color(0xff613089),
                          const Color(0xff9c27b0)
                        ],
                        onTap: () => _showAddGlucoseModal(context),
                      ),
                      const SizedBox(height: 25),
                      _buildGraphSection(),
                      const SizedBox(height: 32),
                      _buildReminderSection(context),
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

//////////////////////////////

  Widget _buildInfoSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GlucoseLogScreen()),
              );
            },
            child: _buildInfoCard(
              icon: Icons.bloodtype,
              title: 'Glucose Log',
              gradientColors: [
                const Color(0xff613089),
                const Color(0xff9c27b0)
              ],
              iconColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

///////////////////////////////////

Widget _buildQuickAddOption({
  required IconData icon,
  required String title,
  required List<Color> gradientColors,
  required VoidCallback onTap,
}) {
  return Center(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {
                        _selectDateTime(context, _dateTimeClucoseController);
                      },
                      child: Text(
                        _dateTimeClucoseController.text.isEmpty
                            ? 'Select Date & Time'
                            : _dateTimeClucoseController.text,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic),
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
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            fontStyle: FontStyle.italic),
                        fillColor: Colors.white,
                        filled: true,
                        suffixText: 'mg/dl',
                        suffixStyle: const TextStyle(color: Color(0xff613089)),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _glucoseErrorText.isEmpty
                            ? null
                            : _glucoseErrorText,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _glucoseErrorText = '';
                        });

                        final glucoseLevel = int.tryParse(value);
                        if (glucoseLevel == null ||
                            glucoseLevel < 50 ||
                            glucoseLevel > 450) {
                          setState(() {
                            _glucoseErrorText =
                                'Please enter a value between 50 and 450';
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
                  if (_glucoseLevelController.text.isEmpty ||
                      _dateTimeClucoseController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill in all fields")),
                    );
                    return;
                  }

                  // Get glucose level and check if it's within the valid range
                  final glucoseLevel =
                      int.tryParse(_glucoseLevelController.text);
                  if (glucoseLevel == null ||
                      glucoseLevel < 50 ||
                      glucoseLevel > 450) {
                    setState(() {
                      _glucoseErrorText =
                          "Please enter a value between 50 and 450";
                    });
                    return;
                  }

                  const measurementType = "before_meal";

                  // Call API to save the glucose level
                  final response = await _addGlucoseReading(
                      glucoseLevel, measurementType, token);
                  //final data = jsonDecode(response.body);

                  // Handle the response
                  if (response != null && response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Reading added successfully!")),
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

  Future<http.Response> _addGlucoseReading(
      int glucoseLevel, String measurementType, String? token) async {
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

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller) async {
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
                buttonTheme:
                    const ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
              child: child!,
            );
          },
        ) ??
        DateTime.now();

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
        ) ??
        TimeOfDay.now();

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




//////////////////////////////

  Widget _buildGraphSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Glucose, week avg',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff613089),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        'Day ${value.toInt()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: weekReadings,
                    isCurved: true,
                    color: const Color(0xff613089),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xff613089).withOpacity(0.3),
                          const Color(0xff613089).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: _reminderTimes.isEmpty
          ? MediaQuery.of(context).size.width * 0.9
          : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set reminder(s) to measure your glucose level',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff613089),
            ),
          ),
          const SizedBox(height: 20),
          _reminderTimes.isEmpty
              ? Text(
                  'No reminders set.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                )
              : Column(
                  children: _reminderTimes.map((time) {
                    return ListTile(
                      leading: const Icon(Icons.notifications_active,
                          color: Color(0xff613089)),
                      title: Text(
                        'Reminder at: ${time.format(context)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xff613089)),
                            onPressed: () {
                              _showReminderDialog(context, existingTime: time);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xff613089)),
                            onPressed: () {
                              _removeReminder(time);
                            },
                          ),
                        ],
                      ),
                      onLongPress: () {
                        _removeReminder(time);
                      },
                    );
                  }).toList(),
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _showReminderDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff613089),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}



/////////////////////////////////////////////


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
        _buildMealButton(
            'After Meal', Icons.dinner_dining, widget.primaryColor),
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
          color:
              isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
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





