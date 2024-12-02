import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_3/screens/diabets_quick_add.dart'; // Ensure this file exists
import 'package:flutter_application_3/screens/glucose_log.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DiabetesControlPage extends StatefulWidget {
  @override
  _DiabetesControlPageState createState() => _DiabetesControlPageState();
}

class _DiabetesControlPageState extends State<DiabetesControlPage> {
  List<TimeOfDay> _reminderTimes = [];

  Future<void> _showReminderDialog(BuildContext context, {TimeOfDay? existingTime}) async {
    final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Color(0xff613089), // Apply primary color to the time picker
          hintColor: Color(0xff9c27b0), // Accent color for time selection
          timePickerTheme: TimePickerThemeData(
            dialHandColor: Color(0xff613089), // Customize the dial hand
            dialTextColor:Colors.black, // Text color inside the dial
            backgroundColor: Colors.white, // Background color of the time picker
             dayPeriodTextColor: Color(0xff613089),
          ),
        ),
        child: child!,
      );
    },
  );

    if (time != null) {
      setState(() {
        if (existingTime == null) {
          _reminderTimes.add(time);
        } else {
          int index = _reminderTimes.indexOf(existingTime);
          if (index != -1) {
            _reminderTimes[index] = time;
          }
        }
      });
    }
  }

  void _removeReminder(TimeOfDay time) {
    setState(() {
      _reminderTimes.remove(time);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Diabetes Control',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
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
                Container(
                  width: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 100.0,
                        lineWidth: 12.0,
                        animation: true,
                        percent: 0.61,
                        center: Text(
                          "61%",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff613089),
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Color(0xff613089),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Eaten: 48 GL of 64 GL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '32 GL is left',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                       icon: FontAwesomeIcons.capsules,
                        title: 'Pills',
                        value: '2 taken',
                        backgroundColor: Colors.purple.shade50,
                        iconColor: Color(0xff613089),
                      ),
                    ),
                    SizedBox(width: 16),
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
                          value: '143 mg/dl',
                          backgroundColor: Colors.purple.shade50,
                          iconColor: Color(0xff613089),
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
        sideTitles: SideTitles(showTitles: false), // إخفاء العناوين على اليمين
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
        spots: [
          FlSpot(0, 100),
          FlSpot(1, 140),
          FlSpot(2, 120),
          FlSpot(3, 130),
          FlSpot(4, 115),
          FlSpot(5, 125),
          FlSpot(6, 140),
        ],
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
)

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
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            )
                          : Column(
                              children: _reminderTimes.map((time) {
                                return ListTile(
                                  leading: Icon(Icons.notifications_active, color: Color(0xff613089)),
                                  title: Text(
                                    'Reminder at: ${time.format(context)}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Color(0xff613089)),
                                        onPressed: () {
                                          _showReminderDialog(context, existingTime: time);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Color(0xff613089)),
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
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
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
    required String value,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
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
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 36,
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
