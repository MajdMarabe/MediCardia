import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F5FF),
    appBar: AppBar(
      title: const Text("Statistics",
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
    body: LayoutBuilder(
      builder: (context, constraints) {
        final double pageWidth = constraints.maxWidth > 600 ? 1100 : constraints.maxWidth * 0.9;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: SizedBox(
                width: pageWidth,
                child: Column(
                  children: [
                    // Quick Statistics
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          InfoCard(
                            title: "Total Patients",
                            value: "1500",
                            icon: Icons.people,
                            iconColor: Colors.blue,
                          ),
                          InfoCard(
                            title: "Registered Doctors",
                            value: "320",
                            icon: FontAwesomeIcons.userMd,
                            iconColor: Colors.orange,
                          ),
                          InfoCard(
                            title: "Blood Donations",
                            value: "250",
                            icon: Icons.bloodtype,
                            iconColor: Colors.red,
                          ),
                          InfoCard(
                            title: "Permission Requests",
                            value: "50",
                            icon: FontAwesomeIcons.fileImport,
                            iconColor: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 300,
                      child: BloodTypeChart(),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: FeatureUsageChart(),
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
  @override
  Widget build(BuildContext context) {
    final bloodTypeData = [
      BloodTypeData('A+', 35, const Color(0xff613089)),
      BloodTypeData('O+', 40, const Color(0xff7A429D)),
      BloodTypeData('B+', 25, const Color(0xff9361B2)),
      BloodTypeData('AB+', 15, const Color(0xffAD7FC7)),
      BloodTypeData('A-', 10, const Color(0xffC79EDC)),
    ];

    final total = bloodTypeData.fold<int>(0, (sum, data) => sum + data.count);

    final updatedBloodTypeData = bloodTypeData.map((data) {
      final percentage = ((data.count / total) * 100).toStringAsFixed(1);
      return BloodTypeData('${data.bloodType} ($percentage%)', data.count, data.color);
    }).toList();

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
          dataSource: updatedBloodTypeData, 
          xValueMapper: (BloodTypeData data, _) => data.bloodType,
          yValueMapper: (BloodTypeData data, _) => data.count,
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
  final int count;
  final Color color;

  BloodTypeData(this.bloodType, this.count, this.color);
}




class FeatureUsageChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            dataSource: [
              FeatureUsageData('Drug Interactions', 80, const Color(0xff613089)), 
              FeatureUsageData('Sugar Tracking', 60, const Color(0xff7A429D)),
              FeatureUsageData('Blood Donation', 40, const Color(0xff9361B2)), 
              FeatureUsageData('Appointment Booking', 70, const Color(0xffAD7FC7)), 
            ],
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


