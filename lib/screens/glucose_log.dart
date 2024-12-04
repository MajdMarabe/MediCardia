import 'constants.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(GlucoseApp());
}

class GlucoseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GlucoseLogScreen(),
    );
  }
}

class GlucoseLogScreen extends StatefulWidget {
  @override
  _GlucoseLogScreenState createState() => _GlucoseLogScreenState();
}

class _GlucoseLogScreenState extends State<GlucoseLogScreen> {
  final storage = FlutterSecureStorage();
  Map<String, dynamic>? glucoseData;

  @override
  void initState() {
    super.initState();
    fetchGlucoseData();
  }

  Future<void> fetchGlucoseData() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token not found');
      }
final headers = {
    'Content-Type': 'application/json',
    'token': token ?? '',
  };
   // final response = await http.post(url, , body: body);

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bloodSugar/glucoseCard'),
        headers: headers
      );

      if (response.statusCode == 200) {
        setState(() {
          glucoseData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching glucose data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Your Glucose',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
        ),
        body: glucoseData == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                GlucoseCard(
  avgGlucose: glucoseData!['today']['avgGlucose'],
  levels: (glucoseData!['today']['levels'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  labels: List<String>.from(glucoseData!['today']['labels']),
  period: 'Today',
),

                  GlucoseCard(
                    avgGlucose: glucoseData!['week']['avgGlucose'],levels: (glucoseData!['today']['levels'] as List<dynamic>)
    .map((e) => (e as num).toDouble())
    .toList(),

                    labels: List<String>.from(glucoseData!['week']['labels']),
                    period: 'Week',
                  ),
                  GlucoseCard(
                    avgGlucose: glucoseData!['month']['avgGlucose'],
levels: (glucoseData!['month']['levels'] as List<dynamic>)
    .map((e) => (e as num).toDouble())
    .toList(),
                    labels: List<String>.from(glucoseData!['month']['labels']),
                    period: 'Month',
                  ),
                ],
              ),
      ),
    );
  }
}

class GlucoseCard extends StatelessWidget {
  final String avgGlucose;
  final List<double> levels;
  final List<String> labels;
  final String period;

  const GlucoseCard({
    required this.avgGlucose,
    required this.levels,
    required this.labels,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avg Blood Glucose',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$avgGlucose mg/dl',
                        style: TextStyle(
                          color: int.parse(avgGlucose) > 130 ? Colors.red : Colors.green,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    int.parse(avgGlucose) > 130 ? '😟' : '👌',
                    style: const TextStyle(fontSize: 40),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$period Glucose Levels',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
                borderData: FlBorderData(show: false),
                barGroups: levels
                    .asMap()
                    .entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            width: 16,
                            color: const Color(0xff613089),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 200,
                              color: const Color(0xff613089).withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
