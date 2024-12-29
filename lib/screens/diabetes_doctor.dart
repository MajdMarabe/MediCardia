import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_3/screens/glucose_log_doctor.dart';
import 'package:flutter_application_3/services/notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class DiabetesControlPage extends StatefulWidget {
  @override
  final String patientId;
  const DiabetesControlPage({Key? key, required this.patientId}) : super(key: key);
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
     final userid=widget.patientId;
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
      final userId = widget.patientId;
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
                   _buildHeaderText(),
                      const SizedBox(height: 25),
                      _buildGraphSection(),
                      const SizedBox(height: 32),
                      _buildInfoSection(),
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
                MaterialPageRoute(builder: (context) => GlucoseLogScreen(patientId:  widget.patientId)),
              );
            },
            child: _buildInfoCard(
              icon: Icons.bloodtype,
              title: 'Detailed Glucose Readings',
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





///////////////////////////////////////






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
  Widget _buildHeaderText() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color.fromARGB(255, 71, 1, 74), Color.fromARGB(255, 218, 59, 246)], 
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(2, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.bar_chart_rounded,
          color: Colors.white,
          size: 40,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diabetes Tracking Insights',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Monitor your diabetic patients glucose control by tracking their daily, weekly, and monthly readings.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}



/////////////////////////////////////////////







