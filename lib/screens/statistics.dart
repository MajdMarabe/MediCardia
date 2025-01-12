import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, dynamic>? statistics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/stats/count'),
      );
      if (response.statusCode == 200) {
        setState(() {
          statistics = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      print('Error fetching statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff9C27B0), Color(0xff6A1B9A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: !kIsWeb,
        leading: kIsWeb
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final double pageWidth =
                    constraints.maxWidth > 600 ? 1100 : constraints.maxWidth * 0.9;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: pageWidth,
                        child: Column(
                          children: [
                            // Quick Statistics
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  InfoCard(
                                    title: "Total Patients",
                                    value: statistics?['userCount'].toString() ?? '0',
                                    icon: Icons.people,
                                    iconColor: Colors.blue,
                                  ),
                                  InfoCard(
                                    title: "Registered Doctors",
                                    value: statistics?['doctorCount'].toString() ?? '0',
                                    icon: FontAwesomeIcons.userMd,
                                    iconColor: Colors.orange,
                                  ),
                                  InfoCard(
                                    title: "Blood Donations",
                                    value: statistics?['DonationRequestcount']
                                            .toString() ??
                                        '0',
                                    icon: Icons.bloodtype,
                                    iconColor: Colors.red,
                                  ),
                                  InfoCard(
                                    title: "Appointments",
                                    value: statistics?['Appointmentcount']
                                            .toString() ??
                                        '0',
                                    icon: FontAwesomeIcons.calendarAlt,
                                    iconColor: Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              height: 300,
                              child: BloodTypeChart(
                                bloodTypeData: statistics?['bloodTypeDistribution'],
                              ),
                            ),
                      SizedBox(
  height: 200,
  child: FeatureUsageChart(statistics: statistics ?? {}), // Provide a default value
),

                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
class FeatureUsageChart extends StatelessWidget {
  final Map<String, dynamic> statistics; // Accept statistics data as a parameter

  const FeatureUsageChart({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataSource = [
      FeatureUsageData('Blood Pressure', statistics['Pressurecount'] ?? 0, const Color(0xff613089)),
      FeatureUsageData('Sugar Tracking', statistics['BloodSugarcount'] ?? 0, const Color(0xff7A429D)),
      FeatureUsageData('Blood Donation', statistics['DonationRequestcount'] ?? 0, const Color(0xff9361B2)),
      FeatureUsageData('Appointment Booking', statistics['Appointmentcount'] ?? 0, const Color(0xffAD7FC7)),
    ];

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: SfCartesianChart(
        title: ChartTitle(text: 'Feature Usage Rate'),
        primaryXAxis: CategoryAxis(
          labelRotation: 45,
        ),
        series: <ChartSeries>[
          ColumnSeries<FeatureUsageData, String>(
            dataSource: dataSource,
            xValueMapper: (FeatureUsageData data, _) => data.feature,
            yValueMapper: (FeatureUsageData data, _) => data.usagePercentage,
            pointColorMapper: (FeatureUsageData data, _) => data.color,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.outer,
              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            spacing: 0.5,
          ),
        ],
      ),
    );
  }
}

class FeatureUsageData {
  final String feature;
  final int usagePercentage;
  final Color color;

  FeatureUsageData(this.feature, this.usagePercentage, this.color);
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 180,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BloodTypeChart extends StatelessWidget {
  final List<dynamic>? bloodTypeData;

  const BloodTypeChart({Key? key, this.bloodTypeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bloodTypeData == null || bloodTypeData!.isEmpty) {
      return const Center(child: Text("No blood type data available."));
    }
final Map<String, Color> bloodTypeColors = {
  'A+': const Color(0xff613089),
  'O+': const Color(0xff7A429D),
  'B+': const Color(0xff9361B2),
  'AB+': const Color(0xffAD7FC7),
  'A-': const Color(0xffC79EDC),
  'O-': const Color(0xff8E44AD), // Add more blood types as needed
  'B-': const Color.fromARGB(255, 56, 21, 69),
  'AB-': const Color.fromARGB(255, 131, 27, 147),
};

final chartData = bloodTypeData!
    .map((data) {
      final bloodType = data['bloodType'];
      final percentage = data['percentage'];
      final color = bloodTypeColors[bloodType] ?? const Color(0xff000000); // Default to black if not found
      return BloodTypeData(bloodType, percentage, color);
    })
    .toList();


    return SfCircularChart(
      title: ChartTitle(text: 'Blood Type Distribution'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.scroll,
        alignment: ChartAlignment.center,
      ),
      series: <CircularSeries>[
        DoughnutSeries<BloodTypeData, String>(
          dataSource: chartData,
          xValueMapper: (BloodTypeData data, _) => data.bloodType,
          yValueMapper: (BloodTypeData data, _) => data.percentage,
          pointColorMapper: (BloodTypeData data, _) => data.color,
          innerRadius: '60%',
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }
}

class BloodTypeData {
  final String bloodType;
  final double percentage;
  final Color color;

  BloodTypeData(this.bloodType, this.percentage, this.color);
}

