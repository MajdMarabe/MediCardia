
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_3/services/notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

const storage = FlutterSecureStorage();


class GraphDetailsPage extends StatefulWidget {
  final String patientId;
  const GraphDetailsPage({Key? key, required this.patientId}) : super(key: key);
  @override
  _GraphDetailsPageState createState() => _GraphDetailsPageState();
}

class _GraphDetailsPageState extends State<GraphDetailsPage> {
  Map<String, dynamic>? pressureData;
int age =0;
  @override
  void initState() {
    super.initState();
    fetchPressureData();
  }


Future<void> fetchPressureData() async {
    print('Fetching pressure data...'); 

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

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      setState(() {
        pressureData = {
          'today': data['today'],
          'week': data['week'],
          'month': data['month'],
        };
      });
    } else {
      print('Failed to fetch pressure data: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching pressure data: $error');
  }
}
Future<void> fetchAge() async {
  String? storedAge = await storage.read(key: 'age');
  age = int.tryParse(storedAge ?? '0') ?? 0;
  print("Age: $age");
}
@override
Widget build(BuildContext context) {
 fetchAge();

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
          'Blood Pressure Reading',
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
          'Blood Pressure',
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
  systolicLevels: pressureData != null && pressureData!['today'] != null
      ? List<double>.from(
          pressureData!['today']['systolicLevels']?.map((e) => e.toDouble()) ?? [])
      : [], 
  diastolicLevels: pressureData != null && pressureData!['today'] != null
      ? List<double>.from(
          pressureData!['today']['diastolicLevels']?.map((e) => e.toDouble()) ?? [])
      : [], 
  labels: pressureData != null && pressureData!['today'] != null
      ? List<String>.from(pressureData!['today']['labels'] ?? [])
      : [], 
  period: 'Today',
),
_buildGraphSection(
  age: age,
  systolicLevels: pressureData != null && pressureData!['week'] != null
      ? List<double>.from(
          pressureData!['week']['systolicLevels']?.map((e) => e.toDouble()) ?? [])
      : [], // قيمة افتراضية إذا كانت البيانات مفقودة
  diastolicLevels: pressureData != null && pressureData!['week'] != null
      ? List<double>.from(
          pressureData!['week']['diastolicLevels']?.map((e) => e.toDouble()) ?? [])
      : [],
  labels: pressureData != null && pressureData!['week'] != null
      ? List<String>.from(pressureData!['week']['labels'] ?? [])
      : [], 
  period: 'Week',
),
_buildGraphSection(
  age: age,
  systolicLevels: pressureData != null && pressureData!['month'] != null
      ? List<double>.from(
          pressureData!['month']['systolicLevels']?.map((e) => e.toDouble()) ?? [])
      : [], 
  diastolicLevels: pressureData != null && pressureData!['month'] != null
      ? List<double>.from(
          pressureData!['month']['diastolicLevels']?.map((e) => e.toDouble()) ?? [])
      : [], 
  labels: pressureData != null && pressureData!['month'] != null
      ? List<String>.from(pressureData!['month']['labels'] ?? [])
      : [],
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
              labels.isNotEmpty
    ? labels[value.toInt() % labels.length]
    : 'No Label',                             style: const TextStyle(color: Colors.black54, fontSize: 12),
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
             labels.isNotEmpty
    ? labels[value.toInt() % labels.length]
    : 'No Label',                             style: const TextStyle(color: Colors.black54, fontSize: 12),
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