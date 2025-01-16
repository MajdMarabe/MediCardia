import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/admin_doctor.dart';
import 'package:flutter_application_3/screens/admin_home.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:flutter_application_3/screens/patient_admin_web.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:table_calendar/table_calendar.dart';
import 'statistics.dart';
import 'manage_accounts_web.dart';
import 'package:flutter_application_3/screens/admin_home.dart';

import 'admin_drugs_web.dart';
import 'admin_hospitals.dart';//AdminDashboard

import 'package:http/http.dart' as http;

class PatientDashboard extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<PatientDashboard> {
  Map<String, dynamic>? statistics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistics(startDate: '', endDate: '');
  }

  Future<void> fetchStatistics({required String startDate, required String endDate}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/stats/patients?startDate=$startDate&endDate=$endDate'),
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
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                     
                      ],
                    ),
                    SizedBox(height: 16),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : StatsCards(statistics: statistics!),
                    SizedBox(height: 16),
                 
                  ],
                ),
              ),
            ),
          ),
          SidePanel(onDateRangeSelected: (startDate, endDate) {
            fetchStatistics(startDate: startDate, endDate: endDate); 
          }),
        ],
      ),
    );
  }
}




class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color.fromARGB(255, 233, 218, 239),
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Admin Panel",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Image.asset(
                  'assets/images/appLogo.png',
                  height: 70, 
                       width: 70,
                color: const Color(0xff613089),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_customize, color: Colors.purple),
            title: Text("Dashboard"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: Colors.purple), 
            title: Text("Patients"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PatientDashboard()),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.userMd, color: Colors.purple), 
            title: Text("Doctors"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminDoctorStats()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.medication, color: Colors.purple), 
            title: Text("Drugs"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageDrugsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.purple), 
            title: Text("Accounts"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageAccountsPage1()),
              );
            },
          ),
      
        ],
      ),
    );
  }
}



class StatsCards extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatsCards({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InfoCard(
              title: "Total Patients",
              value: statistics['totalPatients'].toString() ?? '0',
              icon: Icons.people,
              iconColor: Colors.blue,
            ),
            InfoCard(
              title: "allergiesCount",
              value: statistics['allergiesCount'].toString() ?? '0',
              icon: FontAwesomeIcons.userMd,
              iconColor: Colors.orange,
            ),
           /* InfoCard(
              title: "Blood Donations",
              value: statistics['DonationRequestcount'].toString() ?? '0',
              icon: Icons.bloodtype,
              iconColor: Colors.red,
            ),
            InfoCard(
              title: "Appointments",
              value: statistics['Appointmentcount'].toString() ?? '0',
              icon: FontAwesomeIcons.calendarAlt,
              iconColor: Colors.purple,
            ),*/
          ],
        ),
        const SizedBox(height: 25), 
        SizedBox(
          height: 300,
          child: GenderChart(
            bloodTypeData: statistics['genderDistribution'],
          ),
        ),
        SizedBox(height: 20), 
        SizedBox(
          height: 200,
          child: ChronicConditionsChart(statistics: statistics),
        ),
        SizedBox(height: 20), 
        SizedBox(
          height: 200,
          child: AgeDistributionBarChart(statistics: statistics),
        ),
      ],
    );
  }
}
class ChronicConditionsChart extends StatelessWidget {
  final Map<String, dynamic> statistics; 

  const ChronicConditionsChart({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chronicConditions = statistics['chronicConditionsDistribution'] as List<dynamic>? ?? [];
    final dataSource = chronicConditions.map((condition) {
      return FeatureUsageData(
        condition['_id'] as String, 
        condition['count'] as int, 
        _generateColor(condition['_id'] as String), 
      );
    }).toList();

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: SfCartesianChart(
        title: ChartTitle(text: 'Chronic Conditions Distribution'),
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

  Color _generateColor(String condition) {
    final colors = [
      const Color(0xff613089),
      const Color(0xff7A429D),
      const Color(0xff9361B2),
      const Color(0xffAD7FC7),
      const Color(0xffC49EDF),
    ];
    return colors[condition.hashCode % colors.length];
  }
}

class AgeDistributionBarChart extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const AgeDistributionBarChart({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ageDistribution = statistics['ageDistribution'] as List<dynamic>? ?? [];
    final dataSource = ageDistribution.map((ageGroup) {
      return AgeDistributionData(
        ageGroup['_id'] as String, 
        ageGroup['count'] as int,
      );
    }).toList();

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: SfCartesianChart(
        title: ChartTitle(text: 'Age Distribution'),
        primaryXAxis: CategoryAxis(
          labelRotation: 45,
          title: AxisTitle(text: 'Age Ranges'),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Number of Patients'),
        ),
        series: <ChartSeries>[
          ColumnSeries<AgeDistributionData, String>(
            dataSource: dataSource,
            xValueMapper: (AgeDistributionData data, _) => data.ageRange,
            yValueMapper: (AgeDistributionData data, _) => data.count,
            pointColorMapper: (AgeDistributionData data, _) => _getColorForAgeRange(data.ageRange),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.outer,
              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForAgeRange(String ageRange) {
    switch (ageRange) {
      case '0-17':
        return Color(0xff613089);
      case '18-25':
        return Color(0xff7A429D);
      case '25-35':
        return Color(0xff9361B2);
      case '35-50':
        return Color(0xffAD7FC7);
      case '50+':
        return Color(0xffC49EDF);
      default:
        return Colors.grey; 
    }
  } 
}

class AgeDistributionData {
  final String ageRange;
  final int count;

  AgeDistributionData(this.ageRange, this.count);
}

class FeatureUsageData {
  final String feature;
  final int usagePercentage;
  final Color color;

  FeatureUsageData(this.feature, this.usagePercentage, this.color);
}



class GenderChart extends StatelessWidget {
  final List<dynamic>? bloodTypeData;

  const GenderChart({Key? key, this.bloodTypeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bloodTypeData == null || bloodTypeData!.isEmpty) {
      return const Center(child: Text("No blood type data available."));
    }
final Map<String, Color> bloodTypeColors = {
  'Male': const Color(0xff613089),

  'Female': const Color(0xffAD7FC7),

};

final chartData = bloodTypeData!
    .map((data) {
      final Gender = data['_id'];
      final percentage = data['count'];
      final color = bloodTypeColors[Gender] ?? const Color(0xff000000); 
      return GenderData(Gender, percentage, color);
    })
    .toList();


    return SfCircularChart(
      title: ChartTitle(text: 'Gender Distribution'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.scroll,
        alignment: ChartAlignment.center,
      ),
      series: <CircularSeries>[
        DoughnutSeries<GenderData, String>(
          dataSource: chartData,
          xValueMapper: (GenderData data, _) => data.Gender,
          yValueMapper: (GenderData data, _) => data.percentage,
          pointColorMapper: (GenderData data, _) => data.color,
          innerRadius: '60%',
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }
}

class GenderData {
  final String Gender;
  final double percentage;
  final Color color;

  GenderData(this.Gender, this.percentage, this.color);
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, color: color),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}


class SidePanel extends StatelessWidget {
  final Function(String startDate, String endDate) onDateRangeSelected;

  const SidePanel({Key? key, required this.onDateRangeSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color:const Color.fromARGB(255, 233, 218, 239),
      child: Column(
        children: [
          CalendarWidget(onDateRangeSelected: onDateRangeSelected), // Pass the callback
          Expanded(
            child: ListView(
              children: [
              /*  ListTile(
                  leading: CircleAvatar(),
                  title: Text("Kendra Stevens"),
                  subtitle: Text("Headache"),
                ),
                ListTile(
                  leading: CircleAvatar(),
                  title: Text("Kristopher Flores"),
                  subtitle: Text("Knee Pain"),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}





class CalendarWidget extends StatefulWidget {
  final Function(String startDate, String endDate) onDateRangeSelected;

  const CalendarWidget({Key? key, required this.onDateRangeSelected}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }@override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Date Range",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1), 
          lastDay: DateTime.utc(2100, 12, 31), 
          focusedDay: _focusedDay, 
          selectedDayPredicate: (day) => _startDate != null &&
              _endDate != null &&
              day.isAfter(_startDate!.subtract(Duration(days: 1))) &&
              day.isBefore(_endDate!.add(Duration(days: 1))),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              if (_startDate == null || (_endDate != null && selectedDay.isBefore(_startDate!))) {
                _startDate = selectedDay;
                _endDate = null;
              } else if (_endDate == null) {
                _endDate = selectedDay;
              } else {
                _startDate = selectedDay;
                _endDate = null;
              }

              _focusedDay = focusedDay; 

              if (_startDate != null && _endDate != null) {
                widget.onDateRangeSelected(
                  _startDate!.toIso8601String(),
                  _endDate!.toIso8601String(),
                );
              }
            });
          },
          calendarFormat: CalendarFormat.month,
          rangeSelectionMode: RangeSelectionMode.enforced,
        ),
        if (_startDate != null && _endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              "Selected Range: ${_startDate!.toLocal()} - ${_endDate!.toLocal()}",
              style: TextStyle(fontSize: 16),
            ),
          ),
        SizedBox(height: 16), 
        ElevatedButton(
          onPressed: () {
            widget.onDateRangeSelected('', '');
          },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff613089),
              ),
          child: Text('Get All Time Data'),
          
        ),
      ],
    ),
  );
}

}
