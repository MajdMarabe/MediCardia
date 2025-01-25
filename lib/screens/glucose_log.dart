import 'package:flutter/foundation.dart';
import 'constants.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


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
    final userid=await storage.read(key: 'userid') ?? '';
    final headers = {
      'Content-Type': 'application/json',
    };
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/bloodSugar/$userid/glucoseCard'),
      headers: headers,
    );

      if (response.statusCode == 200) {
        print('Fetched glucose data: ${response.body}');

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



///////////////////////

  @override
  Widget build(BuildContext context) {
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
          'Your Glucose',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xff613089)),
            onPressed: () {
              _showShareDialog(context);
            },
          ),
        ],
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
          'Your Glucose',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xff613089)),
            onPressed: () {
              _showShareDialog(context);
            },
          ),
        ],
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
                    avgGlucose: glucoseData!['week']['avgGlucose'],levels: (glucoseData!['week']['levels'] as List<dynamic>)
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



void _showShareDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Use MediaQuery to determine the screen width
      double width = MediaQuery.of(context).size.width;
      double dialogWidth = width > 600 ? 400 : width * 0.8; 

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        backgroundColor: Colors.white,
        child: Container(
          width: dialogWidth, 
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Share Your Glucose Report",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _generateReport(),
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff613089),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Share Now",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  final String report = _generateReport();
                  Share.share(report); 
                  Navigator.pop(context); 
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  String _generateReport() {
  final todayAvg = int.tryParse(glucoseData?['today']['avgGlucose'] ?? '0') ?? 0;
  final weekAvg = int.tryParse(glucoseData?['week']['avgGlucose'] ?? '0') ?? 0;
  final monthAvg = int.tryParse(glucoseData?['month']['avgGlucose'] ?? '0') ?? 0;

    return """
🩸 **Glucose Levels Report** 📊
**Today:** $todayAvg mg/dl ${(todayAvg > 130) ? '😟' : '👌'}
**Week:** $weekAvg mg/dl ${(weekAvg > 130) ? '😟' : '👌'}
**Month:** $monthAvg mg/dl ${(monthAvg > 130) ? '😟' : '👌'}
""";
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
    // تحقق من توافق الطول بين levels و labels
print('Labels: $labels');
print('Levels: $levels');
print('Labels length: ${labels.length}');
print('Levels length: ${levels.length}');


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
              style: const TextStyle(
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
                gridData: const FlGridData(show: false),
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
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: levels
                    .asMap()
                    .entries
                    .map(
                      (entry) {
                        if (entry.key >= 0 && entry.key < labels.length) {
                          return BarChartGroupData(
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
                          );
                        } else {
                          return null;
                        }
                      },
                    )
                    .where((group) => group != null) // إزالة العناصر الفارغة
                    .cast<BarChartGroupData>()
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
