import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_3/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
import 'pressure_detailed_doctor.dart';
const storage = FlutterSecureStorage();
//widget.patientId;
class BloodPressureControlPage extends StatefulWidget {
    final String patientId;
  const BloodPressureControlPage({Key? key, required this.patientId}) : super(key: key);
  @override
  _BloodPressureControlPageState createState() =>
      _BloodPressureControlPageState();
}

class _BloodPressureControlPageState extends State<BloodPressureControlPage> {
  final List<TimeOfDay> _reminderTimes = [];
  
  int userAge = 0;
    final TextEditingController dateTimeController = TextEditingController();
 final TextEditingController _dateTimeClucoseController =
      TextEditingController();
 Map<String, dynamic>? pressureData;
int age =0;
  @override
  void initState() {
    super.initState();
    fetchPressureData();
  }


Future<void> fetchPressureData() async {
    print('Fetching pressure data...'); // للتحقق
final userid=widget.patientId;
  final  apiUrl = '${ApiConstants.baseUrl}/pressure/$userid/data'; // ضع رابط الـ API هنا

  try {
    // إرسال طلب GET للحصول على بيانات ضغط الدم
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
       'Content-Type': 'application/json',
      },
    );

    // إذا كانت الاستجابة ناجحة
    if (response.statusCode == 200) {
      // تحويل الاستجابة إلى JSON
      final Map<String, dynamic> data = jsonDecode(response.body);

      setState(() {
        pressureData = {
          'today': data['today'],
          'week': data['week'],
          'month': data['month'],
        };
      });
    } else {
      // في حالة حدوث خطأ في الاستجابة
      print('Failed to fetch pressure data: ${response.statusCode}');
    }
  } catch (error) {
    // التعامل مع الأخطاء المحتملة أثناء الطلب
    print('Error fetching pressure data: $error');
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

            scheduleReminder(time, userId,'pressure');
          } else {
            int index = _reminderTimes.indexOf(existingTime);
            if (index != -1) {
              _reminderTimes[index] = time;

              scheduleReminder(time, userId,'pressure');
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




  // Helper method to build text form fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontStyle: FontStyle.italic,
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
                timePickerTheme: const TimePickerThemeData(
                  dialHandColor: Color(0xff613089),
                  backgroundColor: Colors.white,
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

    setState(() {
      controller.text =
          "${selectedDateTime.toLocal().toString().split(' ')[0]}, ${selectedTime.format(context)}";
    });
  }




//////////////////////////////////////////

Future<void> fetchAge() async {
  String? storedAge = await storage.read(key: 'age');
  userAge = int.tryParse(storedAge ?? '0') ?? 0;
  print("Age: $age");
}
@override
Widget build(BuildContext context) {
 fetchAge();
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
                  'Blood Pressure Tracking',
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
                  'Blood Pressure Tracking',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff613089),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 800 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderText(),
                    const SizedBox(height: 20),
                    _buildGraphSectionWithBackground(userAge),
                     const SizedBox(height: 20),
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




  Widget _buildInfoSection() {
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
        children: [
          const Text(
            'Latest Measurements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff613089),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
  _buildMeasurementCard(
    'Systolic',
    '${pressureData != null && pressureData!['today']['systolicLevels'] != null && pressureData!['today']['systolicLevels'].isNotEmpty ? pressureData!['today']['systolicLevels'].last : 'N/A'}',
    const Color(0xFF9B4F96),
  ),
  _buildMeasurementCard(
    'Diastolic',
    '${pressureData != null && pressureData!['today']['diastolicLevels'] != null && pressureData!['today']['diastolicLevels'].isNotEmpty ? pressureData!['today']['diastolicLevels'].last : 'N/A'}',
    const Color(0xFF536DFE),
  ),
],

          ),
          const SizedBox(height: 20),
     
        ],
      ),
    );
  }



 Widget _buildGraphSectionWithBackground(int age) {
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
          'Blood Pressure (Weekly Readings)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff613089),
          ),
        ),
        const SizedBox(height: 10),
        _buildSystolicPressureChart(age),
        const SizedBox(height: 16),
        _buildDiastolicPressureChart(age),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GraphDetailsPage(patientId:widget.patientId)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff613089), 
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 16, 
              ),
            ),
            child: const Text(
              'View Detailed Graphs',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}






Widget _buildSystolicPressureChart(int age) {
  double chartHeight = 200;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Systolic Pressure',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xff613089),
        ),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GraphDetailsPage(patientId:widget.patientId)),
          );
        },
        child: SizedBox(
          height: chartHeight,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  Color lineColor;

                  if (value == 90) {
                    lineColor = Colors.blue.withOpacity(0.5); // ضغط منخفض
                  } else if (age < 30) {
                    if (value == 120) {
                      lineColor = Colors.green.withOpacity(0.5); // طبيعي
                    }  else {
                      lineColor = Colors.transparent; // مرتفع
                    }
                  } else if (age >= 30 && age <= 50) {
                    if (value == 130) {
                      lineColor = Colors.green.withOpacity(0.5); // طبيعي
                    }  else {
                      lineColor = Colors.transparent; // مرتفع
                    }
                  } else {
                    if (value == 140) {
                      lineColor = Colors.green.withOpacity(0.5); // طبيعي
                    }
                     else {
                      lineColor = Colors.transparent; // مرتفع
                    }
                  }

                  return FlLine(
                    color: lineColor,
                    strokeWidth: 1.5,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                                   getTitlesWidget: (value, meta) {
                     List<String> days = pressureData != null && pressureData!['today'] != null
    ? List<String>.from(pressureData!['week']['labels'] ?? [])
    : [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ];


                      final index = value.toInt();
                      if (index >= 0 && index < days.length) {
                        return Text(
                          days[index],
                          style: const TextStyle(fontSize: 12),
                        );
                      }

                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              lineBarsData: [
                LineChartBarData(
                 spots: List.generate(
  pressureData != null && pressureData!['week'] != null
      ? pressureData!['week']['systolicLevels']?.length ?? 0
      : 0,
  (index) {
    double value = 0.0;
    if (pressureData != null &&
        pressureData!['week'] != null &&
        pressureData!['week']['systolicLevels'] != null &&
        index < pressureData!['week']['systolicLevels'].length) {
      value = pressureData!['week']['systolicLevels'][index]?.toDouble() ?? 0.0;
    }

    return FlSpot(index.toDouble(), value);
  },
),
                  isCurved: true,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  color: const Color(0xFF9B4F96), 
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 90,
                    color: Colors.blue.withOpacity(0.2),
                    strokeWidth: 1.5,
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.center,
                      style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                      labelResolver: (line) => '\n\nLow', 
                    ),
                  ),
                  if (age < 30) ...[
                    HorizontalLine(
                      y: 120,
                      color: Colors.green.withOpacity(0.2),
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nNormal',
                      ),
                    ),
                    HorizontalLine(
                      y: 140,
                      color: Colors.transparent,
                      //strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\nHigh',
                      ),
                    ),
                  ],
                  if (age >= 30 && age <= 50) ...[
                    HorizontalLine(
                      y: 130,
                      color: Colors.green.withOpacity(0.2),
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nNormal',
                      ),
                    ),
                    HorizontalLine(
                      y: 160,
                      color: Colors.transparent,
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nHigh',
                      ),
                    ),
                  ],
                  if (age > 50) ...[
                    HorizontalLine(
                      y: 140,
                      color: Colors.green.withOpacity(0.2),
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nNormal',
                      ),
                    ),
                    HorizontalLine(
                      y: 180,
                      color: Colors.transparent,
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nHigh',
                      ),
                    ),
                    HorizontalLine(
                      y: 180,
                      color: Colors.transparent,
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nHigh',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}







Widget _buildDiastolicPressureChart(int age) {
  double chartHeight = 200;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Diastolic Pressure',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xff613089),
        ),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GraphDetailsPage(patientId:widget.patientId)),
          );
        },
        child: SizedBox(
          height: chartHeight,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  Color lineColor;
                  double lineWidth;

                 
                  if (value == 60) {
                    lineColor = Colors.blue.withOpacity(0.5); // ضغط منخفض
                    lineWidth = 1.5;
                  } else if (age < 30) {
                    if (value == 80) {
                      lineColor = Colors.green.withOpacity(0.5); // طبيعي
                      lineWidth = 1.5;
                    }  else {
                      lineColor = Colors.transparent; // مرتفع
                      lineWidth = 1.5;
                    }
                  } else if (age >= 30 && age <= 50) {
                    if (value == 85) {
                      lineColor = Colors.green.withOpacity(0.5); // طبيعي
                      lineWidth = 1.5;
                    }  else {
                      lineColor = Colors.transparent; // مرتفع
                      lineWidth = 1.5;
                    }
                  } else {
                    if (value == 90) {
                      lineColor = Colors.green.withOpacity(0.5); // طبيعي
                      lineWidth = 1.5;
                    }  else {
                      lineColor = Colors.transparent; // مرتفع
                      lineWidth = 1.5;
                    }
                  }

                  return FlLine(
                    color: lineColor,
                    strokeWidth: lineWidth,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                     List<String> days = pressureData != null && pressureData!['today'] != null
    ? List<String>.from(pressureData!['week']['labels'] ?? [])
    : [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ];


                      final index = value.toInt();
                      if (index >= 0 && index < days.length) {
                        return Text(
                          days[index],
                          style: const TextStyle(fontSize: 12),
                        );
                      }

                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              lineBarsData: [
                LineChartBarData(
                 spots: List.generate(
  pressureData != null && pressureData!['week'] != null
      ? pressureData!['week']['diastolicLevels']?.length ?? 0
      : 0,
  (index) {
    double value = 0.0;
    if (pressureData != null &&
        pressureData!['week'] != null &&
        pressureData!['week']['diastolicLevels'] != null &&
        index < pressureData!['week']['diastolicLevels'].length) {
      value = pressureData!['week']['diastolicLevels'][index]?.toDouble() ?? 0.0;
    }

    return FlSpot(index.toDouble(), value);
  },
),

                  isCurved: true,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  color: const Color(0xFF536DFE),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 60,
                    color: Colors.blue.withOpacity(0.2),
                    strokeWidth: 1.5,
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.center,
                      style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                      labelResolver: (line) => '\n\nLow', 
                    ),
                  ),
                  if (age < 30) ...[
                    HorizontalLine(
                      y: 80,
                      color: Colors.green.withOpacity(0.2),
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nNormal',
                      ),
                    ),
                    HorizontalLine(
                      y: 100,
                      color: Colors.transparent,
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\nHigh',
                      ),
                    ),
                  ],
                  if (age >= 30 && age <= 50) ...[
                    HorizontalLine(
                      y: 85,
                      color: Colors.green.withOpacity(0.2),
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nNormal',
                      ),
                    ),
                    HorizontalLine(
                      y: 105,
                      color: Colors.transparent,
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\nHigh',
                      ),
                    ),
                  ],
                  if (age > 50) ...[
                    HorizontalLine(
                      y: 90,
                      color: Colors.green.withOpacity(0.2),
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\n\nNormal',
                      ),
                    ),
                    HorizontalLine(
                      y: 110,
                      color: Colors.transparent,
                      strokeWidth: 1.5,
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.center,
                        style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                        labelResolver: (line) => '\nHigh',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      )
      ],
    );
  }



  Widget _buildMeasurementCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          'mmHg',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Widget _buildLegendItem({required Color color, required String label}) {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 16,
  //         height: 16,
  //         decoration: BoxDecoration(
  //           color: color,
  //           borderRadius: BorderRadius.circular(4),
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  //       ),
  //     ],
  //   );
  // }

}





////////////////////////////////////////////////////


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
                'Monitor your Blood pressure patients by tracking their daily, weekly, and monthly readings.',
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


