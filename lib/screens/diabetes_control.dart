import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_3/screens/diabets_quick_add.dart'; // Ensure this file exists
import 'package:flutter_application_3/screens/glucose_log.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_application_3/main.dart';

class DiabetesControlPage extends StatefulWidget {
  @override
  _DiabetesControlPageState createState() => _DiabetesControlPageState();
}

class _DiabetesControlPageState extends State<DiabetesControlPage> {
  List<TimeOfDay> _reminderTimes = [];
  late List<FlSpot> weekReadings;
  final storage = FlutterSecureStorage();
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
    final headers = {
      'Content-Type': 'application/json',
      'token': await storage.read(key: 'token') ?? '',
    };
    final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bloodSugar/glucoseCard'),
        headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> levels = data['week']['levels'];
      List<dynamic> labels = data['week']['labels'];

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
            primaryColor:
                Color(0xff613089), // Apply primary color to the time picker
            hintColor: Color(0xff9c27b0), // Accent color for time selection
            timePickerTheme: TimePickerThemeData(
              dialHandColor: Color(0xff613089), // Customize the dial hand
              dialTextColor: Colors.black, // Text color inside the dial
              backgroundColor:
                  Colors.white, // Background color of the time picker
              dayPeriodTextColor: Color(0xff613089),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      // Retrieve the userId from secure storage
      final userId =
          await storage.read(key: 'userid'); // Read the user ID from storage
      if (userId != null) {
        setState(() {
          if (existingTime == null) {
            // Add new reminder time
            _reminderTimes.add(time);
            // Schedule the reminder and add it to the database
            scheduleReminder(time, userId);
          } else {
            // Update existing reminder time
            int index = _reminderTimes.indexOf(existingTime);
            if (index != -1) {
              _reminderTimes[index] = time;
              // Reschedule the reminder after modifying it
              scheduleReminder(time, userId);
            }
          }
        });
      } else {
        // Handle case where userId is not found
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
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
          'Diabetes Control',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GlucoseLogScreen(),
                            ),
                          );
                        },
                        child: _buildInfoCard(
                          icon: Icons.bloodtype,
                          title: 'Glucose',
                          gradientColors: [
                            Color(0xff613089),
                            Color(0xff9c27b0)
                          ],
                          iconColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
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
                      Text(
                        'Glucose, week avg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff613089),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 20,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) => Text(
                                    'Day ${value.toInt()}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: weekReadings,
                                isCurved: true,
                                color: Color(0xff613089),
                                barWidth: 4,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff613089).withOpacity(0.3),
                                      Color(0xff613089).withOpacity(0.1),
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
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
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
                      Text(
                        'Set reminder(s) to measure your glucose level',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff613089),
                        ),
                      ),
                      SizedBox(height: 20),
                      _reminderTimes.isEmpty
                          ? Text(
                              'No reminders set.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey.shade600),
                            )
                          : Column(
                              children: _reminderTimes.map((time) {
                                return ListTile(
                                  leading: Icon(Icons.notifications_active,
                                      color: Color(0xff613089)),
                                  title: Text(
                                    'Reminder at: ${time.format(context)}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Color(0xff613089)),
                                        onPressed: () {
                                          _showReminderDialog(context,
                                              existingTime: time);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
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
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showReminderDialog(context);
                        },
                        child: Text('Add Reminder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff613089),
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Floating Action Button for "Quick Add"
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to DiabetesQuickAddPage when FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiabetesQuickAddPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xff613089),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
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
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
