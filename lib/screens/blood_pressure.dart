import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BloodPressureControlPage extends StatefulWidget {
  @override
  _BloodPressureControlPageState createState() =>
      _BloodPressureControlPageState();
}

class _BloodPressureControlPageState extends State<BloodPressureControlPage> {
  final List<TimeOfDay> _reminderTimes = [];
  final List<double> _systolicReadings = [121, 138, 90, 120, 50, 139,150];
  final List<double> _diastolicReadings = [84, 86, 60, 40, 100, 120, 130];
  final TextEditingController dateTimeController = TextEditingController();

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



Future<void> _showAddReadingDialog(BuildContext context) async {
  final TextEditingController systolicController = TextEditingController();
  final TextEditingController diastolicController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      // تحديد العرض والارتفاع بناءً على حجم الشاشة
      double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9;

      double dialogHeight = MediaQuery.of(context).size.height >= 729.5999755859375
          ? 300
          : MediaQuery.of(context).size.height * 0.4;

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: dialogWidth,
            height: dialogHeight,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Blood Pressure Reading',
                  style: TextStyle(
                    color: Color(0xff613089),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Systolic Pressure Input Field
                        _buildTextFormField(
                          controller: systolicController,
                          label: "Systolic Pressure",
                          hint: "Enter Systolic Pressure",
                          icon: Icons.favorite,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),

                        // Diastolic Pressure Input Field
                        _buildTextFormField(
                          controller: diastolicController,
                          label: "Diastolic Pressure",
                          hint: "Enter Diastolic Pressure",
                          icon: Icons.favorite_border,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),

                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final double? systolic =
                                    double.tryParse(systolicController.text);
                                final double? diastolic =
                                    double.tryParse(diastolicController.text);

                                if (systolic != null && diastolic != null) {
                                  setState(() {
                                    _systolicReadings.add(systolic);
                                    _diastolicReadings.add(diastolic);
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF613089),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 14),
                              ),
                              child: const Text(
                                'Add Reading',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
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


@override
Widget build(BuildContext context) {
  int userAge = 55;
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
                    _buildInfoSection(),
                    const SizedBox(height: 20),
                    _buildGraphSectionWithBackground(userAge),
                     const SizedBox(height: 20),
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
                '${_systolicReadings.last}',
                const Color(0xFF9B4F96),
              ),
              _buildMeasurementCard('Diastolic', '${_diastolicReadings.last}',
                  const Color(0xFF536DFE)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _showAddReadingDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff613089),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              shadowColor: Colors.purple.withOpacity(0.5),
              elevation: 5,
            ),
            child: const Text(
              'Add Reading',
              style: TextStyle(
                fontSize: 16,
              
                color: Colors.white,
              ),
            ),
          ),
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
                MaterialPageRoute(builder: (context) => GraphDetailsPage()),
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
            MaterialPageRoute(builder: (context) => GraphDetailsPage()),
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
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

                      final index = value.toInt();
                      if (index >= 0 && index < days.length) {
                        return Text(days[index], style: const TextStyle(fontSize: 12));
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
                    _systolicReadings.length,
                    (index) => FlSpot(index.toDouble(), _systolicReadings[index]),
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
            MaterialPageRoute(builder: (context) => GraphDetailsPage()),
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
                      const days = [
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
                    _diastolicReadings.length,
                    (index) =>
                        FlSpot(index.toDouble(), _diastolicReadings[index]),
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
            'Set reminder(s) to measure your systolic & diastolic pressure',
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
}





////////////////////////////////////////////////////





class GraphDetailsPage extends StatefulWidget {
  @override
  _GraphDetailsPageState createState() => _GraphDetailsPageState();
}

class _GraphDetailsPageState extends State<GraphDetailsPage> {
  Map<String, dynamic>? pressureData;

  @override
  void initState() {
    super.initState();
    fetchPressureData();
  }

  Future<void> fetchPressureData() async {
    setState(() {
      pressureData = {
        'today': {
         
          'systolicLevels': [
            120.0,
            125.0,
            130.0,
            115.0,
            110.0,
            118.0,
            140.0,
            150.0,
            40.0,
            60.0,
            170.0
          ],
          'diastolicLevels': [80.0, 82.0, 78.0, 76.0, 79.0, 81.0,60.5,90.0,70.0,50.0,40.0],
          'labels': ['8 AM', '10 AM', '12 PM', '2 PM', '4 PM', '6 PM'],
        },
        'week': {
          
          'systolicLevels': [120.0, 122.0, 118.0, 115.0, 121.0, 119.0, 123.0,99.0,95.0,100.0,140.0,80.0],
          'diastolicLevels': [80.0, 81.0, 78.0, 79.0, 77.0, 76.0, 80.0,90.0,100.0,110.0,120.0,100.0,40.0,20.0],
          'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        },
        'month': {
       
          'systolicLevels': [120.0, 122.0, 119.0, 118.0],
          'diastolicLevels': [80.0, 81.0, 79.0, 78.0],
          'labels': ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
        }
      };
    });
  }

@override
Widget build(BuildContext context) {
  int age = 22;

  return DefaultTabController(
    length: 3,
    child: Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
           appBar: kIsWeb
    ? AppBar(
        backgroundColor: const Color(0xFFF2F5FF),
        elevation: 0,
        automaticallyImplyLeading: false, 
        centerTitle: true,
        title: const Text(
          'Your Blood Pressure Reading',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
      
        bottom: const TabBar(
          indicatorColor: Color(0xff613089),
          labelColor: Color(0xff613089),
          unselectedLabelColor: Colors.black54,
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Today'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
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
          'Your Blood Pressure',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
      
        bottom: const TabBar(
          indicatorColor: Color(0xff613089),
          labelColor: Color(0xff613089),
          unselectedLabelColor: Colors.black54,
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Today'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return pressureData == null
              ? const Center(child: CircularProgressIndicator())
              : Builder(
                  builder: (context) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth > 600 ? 900 : double.infinity,
                        ),
                        child: TabBarView(
                          children: [
                            _buildGraphSection(
                              age: age,
                              systolicLevels: List<double>.from(
                                  pressureData!['today']['systolicLevels']),
                              diastolicLevels: List<double>.from(
                                  pressureData!['today']['diastolicLevels']),
                              labels: List<String>.from(pressureData!['today']['labels']),
                              period: 'Today',
                            ),
                            _buildGraphSection(
                              age: age,
                              systolicLevels: List<double>.from(
                                  pressureData!['week']['systolicLevels']),
                              diastolicLevels: List<double>.from(
                                  pressureData!['week']['diastolicLevels']),
                              labels: List<String>.from(pressureData!['week']['labels']),
                              period: 'Week',
                            ),
                            _buildGraphSection(
                              age: age,
                              systolicLevels: List<double>.from(
                                  pressureData!['month']['systolicLevels']),
                              diastolicLevels: List<double>.from(
                                  pressureData!['month']['diastolicLevels']),
                              labels: List<String>.from(pressureData!['month']['labels']),
                              period: 'Month',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    ),
  );
}



  Widget _buildGraphSection({
    required List<double> systolicLevels,
    required List<double> diastolicLevels,
    required List<String> labels,
    required String period,
    required int age,
  }) {
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
          Text(
            'Blood Pressure ($period)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff613089),
            ),
          ),
          const SizedBox(height: 10),
          _buildSystolicPressureChart(
            age: age,
            systolicLevels: systolicLevels,
            labels: labels,
          ),
          const SizedBox(height: 16),
          _buildDiastolicPressureChart(
            age: age,
            diastolicLevels: diastolicLevels,
            labels: labels,
          ),
        ],
      ),
    );
  }

  Widget _buildSystolicPressureChart({
    required int age,
    required List<double> systolicLevels,
    required List<String> labels,
  }) {
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
        SizedBox(
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
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[value.toInt() % labels.length],
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        );
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
                    systolicLevels.length,
                    (index) => FlSpot(index.toDouble(), systolicLevels[index]),
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
        )
      ],
    );
  }

  Widget _buildDiastolicPressureChart({
    required int age,
    required List<double> diastolicLevels,
    required List<String> labels,
  }) {
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
        SizedBox(
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
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[value.toInt() % labels.length],
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        );
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
                    diastolicLevels.length,
                    (index) => FlSpot(index.toDouble(), diastolicLevels[index]),
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
      ],
    );
  }
}
