import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';

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

class GlucoseLogScreen extends StatelessWidget {
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
                _showShareDialog(context);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            GlucoseCard(
              avgGlucose: '131',
              levels: [154, 140, 120, 131, 150],
              labels: ['6 AM', '9 AM', '12 PM', '3 PM', '6 PM'],
              period: 'Today',
            ),
            GlucoseCard(
              avgGlucose: '108',
              levels: [70, 90, 110, 140, 150],
              labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
              period: 'Week',
            ),
            GlucoseCard(
              avgGlucose: '111',
              levels: [90, 110, 111, 115, 120],
              labels: ['W1', 'W2', 'W3', 'W4', 'W5'],
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
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        backgroundColor: Colors.white,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        "Share Your Glucose Report",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff613089),
                        ),
                        textAlign: TextAlign.center,
                      ),
                     
                      const SizedBox(height: 20),
                      Text(
                        _generateReport(), // Display the report in a scrollable area
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff613089),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                    Share.share(report); // Share the report
                    Navigator.pop(context); // Close the dialog
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  String _generateReport() {
    String avgToday = '131';
    String avgWeek = '108';
    String avgMonth = '111';

    return """
🩸 **Glucose Levels Report** 📊

**Today:** $avgToday mg/dl ${(int.parse(avgToday) > 130) ? '😟' : '😎'}
**Week:** $avgWeek mg/dl ${(int.parse(avgWeek) > 130) ? '😟' : '👌'}
**Month:** $avgMonth mg/dl ${(int.parse(avgMonth) > 130) ? '😟' : '👌'}

Stay healthy and consult your doctor for further advice.
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
          interval: 20, // عرض القيم بفاصل 20
          getTitlesWidget: (double value, TitleMeta meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false), // إخفاء العناوين على اليمين
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
)

          ),
        ],
      ),
    );
  }
}
