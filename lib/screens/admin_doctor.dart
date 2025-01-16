import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/admin_home.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDoctorStats extends StatefulWidget {
  @override
  _AdminDoctorStatsState createState() => _AdminDoctorStatsState();
}

class _AdminDoctorStatsState extends State<AdminDoctorStats> {
  List<dynamic> doctors = [];
  bool isLoading = false;
  String query = '';
  Map<String, dynamic>? selectedDoctorStats;
  String startDate = '';
  String endDate = '';
  List<dynamic> specializationCounts = [];

  @override
  void initState() {
    super.initState();
    fetchSpecializationCounts(); // استدعاء دالة جلب البيانات عند بناء الشاشة
  }

  Future<void> fetchDoctorsByName(String name) async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/doctors/admin/search?name=$name'),
      );
      if (response.statusCode == 200) {
        setState(() {
          doctors = json.decode(response.body)['doctors'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch doctors');
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSpecializationCounts() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/doctors/stats/count?startDate=$startDate&endDate=$endDate'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          specializationCounts = data; // تخزين البيانات في القائمة
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch specialization counts');
      }
    } catch (e) {
      print('Error fetching specialization counts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDoctorStatistics(String doctorId,String start,String end ) async {
    try {
      setState(() {
        selectedDoctorStats = null;
        isLoading = true;
      });
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/doctors/$doctorId/stats?startDate=$start&endDate=$end'),
      );
      if (response.statusCode == 200) {
        setState(() {
          selectedDoctorStats = json.decode(response.body);
          doctors = [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load doctor statistics');
      }
    } catch (e) {
      print('Error fetching doctor statistics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      child: SpecializationChart(
                        statistics: specializationCounts,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search Doctor by Name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          query = value;
                        });
                        if (value.isNotEmpty) {
                          fetchDoctorsByName(value);
                        } else {
                          setState(() {
                            doctors = [];
                            selectedDoctorStats = null;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : doctors.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: doctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = doctors[index];
                                  return ListTile(
                                    title: Text(doctor['fullName']),
                                    subtitle: Text(
                                      'Patients: ${doctor['numberOfPatients']} | '
                                      'Rating: ${doctor['averageRating']} | '
                                      'Reviews: ${doctor['numberOfReviews']}',
                                    ),
                                    onTap: () {
                                      fetchDoctorStatistics(doctor['_id'],startDate,endDate);
                                    },
                                  );
                                },
                              )
                            : (query.isEmpty
                                ? SizedBox()
                                : Center(child: Text("No doctors found"))),
                    SizedBox(height: 16),
                    selectedDoctorStats != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Doctor Statistics',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              DoctorStatsCards(
                                statistics: {
                                  'appointmentCount': selectedDoctorStats?['statistics']['appointmentCount'] ?? 0,
                                  'availableSlotsCount': selectedDoctorStats?['statistics']['availableSlotsCount'] ?? 0,
                                  'patientCount': selectedDoctorStats?['statistics']['patientCount'] ?? 0,
                                  'averageRating': selectedDoctorStats?['statistics']['averageRating'] ?? 0,
                                  'numberOfReviews': selectedDoctorStats?['statistics']['numberOfReviews'] ?? 0,
                                },
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Appointments Ratio',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                height: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: _buildPieChartSections(),
                                    centerSpaceRadius: 50,
                                    sectionsSpace: 4,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LegendItem(
                                      color: Colors.green,
                                      label:
                                          'Booked appointment: ${selectedDoctorStats?['statistics']['appointmentCount'] ?? 0}'),
                                  SizedBox(width: 16),
                                  LegendItem(
                                      color: Colors.red,
                                      label:
                                          'Available appointment: ${selectedDoctorStats?['statistics']['availableSlotsCount'] ?? 0}'),
                                ],
                              ),
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          ),
          SidePanel(
            onDateRangeSelected: (start, end) {
              setState(() {
                startDate = start;
                endDate = end;
                fetchSpecializationCounts();
                if (selectedDoctorStats != null) {
                  fetchDoctorStatistics(selectedDoctorStats?['doctorId'],start,end);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (selectedDoctorStats == null) {
      return [];
    }
    final stats = selectedDoctorStats!['statistics'];
    final int appointmentCount = stats['appointmentCount'] ?? 0;
    final int availableSlotsCount = stats['availableSlotsCount'] ?? 0;

    final int total = appointmentCount + availableSlotsCount;
    if (total == 0) {
      return [];
    }

    return [
      PieChartSectionData(
        color: Colors.green,
        value: appointmentCount.toDouble(),
        title: '${((appointmentCount / total) * 100).toStringAsFixed(1)}%',
        radius: 100,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: availableSlotsCount.toDouble(),
        title: '${((availableSlotsCount / total) * 100).toStringAsFixed(1)}%',
        radius: 100,
      ),
    ];
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class DoctorStatsCards extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const DoctorStatsCards({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatCard(
          title: "Patient Count",
          value: statistics['patientCount'].toString(),
          color: Colors.blue,
        ),
        StatCard(
          title: "Average Rating",
          value: statistics['averageRating'].toString(),
          color: Colors.green,
        ),
        StatCard(
          title: "Number Of Reviews",
          value: statistics['numberOfReviews'].toString(),
          color: Colors.green,
        ),
      ],
    );
  }
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
    return Container(
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
    );
  }
}
class SpecializationChart extends StatelessWidget {
  final List<dynamic> statistics; // Accepts a list of statistics data

  const SpecializationChart({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحويل البيانات القادمة من statistics إلى قائمة FeatureUsageData
    final dataSource = statistics.map((item) {
      return FeatureUsageData(
        item['specialization'] as String, // التخصص
        item['count'] as int, // عدد الأطباء
        const Color(0xff613089), // لون ثابت
      );
    }).toList();

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: SfCartesianChart(
        title: ChartTitle(text: 'Doctors Count by Specialization'),
        primaryXAxis: CategoryAxis(
          labelRotation: 45, // دوران النصوص
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
  final String feature; // اسم التخصص
  final int usagePercentage; // عدد الأطباء
  final Color color; // اللون

  FeatureUsageData(this.feature, this.usagePercentage, this.color);
}


class SidePanel extends StatelessWidget {
  final Function(String startDate, String endDate) onDateRangeSelected;

  const SidePanel({Key? key, required this.onDateRangeSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // عرض لوحة التقويم
      color: const Color.fromARGB(255, 233, 218, 239),
      child: Column(
        children: [
          CalendarWidget(onDateRangeSelected: onDateRangeSelected),
          Expanded(
            child: ListView(
              children: [
                // Add any additional content here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
