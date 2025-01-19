import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/admin_home.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:flutter_application_3/screens/welcome_screen.dart';
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
    fetchSpecializationCounts(); 
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
          specializationCounts = data; 
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



  // Function to handle log out
Future<void> _logOut() async {
  // Add your logout logic here (e.g., clearing user session, etc.)
  try {
    await storage.deleteAll(); // Clears all stored keys and values
    print('Storage cleared successfully.');
    await FirebaseMessaging.instance.deleteToken();

    // Navigate the user back to the welcome or login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  } catch (e) {
    print('Error clearing storage: $e');
  }
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully!")),
    );
  }
}



///////////////////////////////


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Row(
      children: [
       Sidebar(onLogout: _logOut),
        Expanded(
          flex: 2,
          child: ScrollConfiguration(
            behavior: TransparentScrollbarBehavior(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      child: SpecializationChart(
                        statistics: specializationCounts,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search doctor by name...',
                        labelStyle: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color(0xff613089),
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
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
                    const SizedBox(height: 16),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : doctors.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(), 
                                itemCount: doctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = doctors[index];
                                  if (doctor['fullName'] == 'Sally Mah') {
                                    return const SizedBox(); 
                                  }
                                  return ListTile(
                                    title: Text(doctor['fullName']),
                                    subtitle: Text(
                                      'Patients: ${doctor['numberOfPatients']} | '
                                      'Rating: ${doctor['averageRating']} | '
                                      'Reviews: ${doctor['numberOfReviews']}',
                                    ),
                                    onTap: () {
                                      fetchDoctorStatistics(doctor['_id'], startDate, endDate);
                                    },
                                  );
                                },
                              )
                            : (query.isNotEmpty && doctors.isEmpty && selectedDoctorStats == null
    ? const Center(child: Text("No doctors found."))
    : const SizedBox()),

                    const SizedBox(height: 16),
                    selectedDoctorStats != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Doctor Statistics',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DoctorStatsCards(
                                statistics: {
                                  'appointmentCount': selectedDoctorStats?['statistics']['appointmentCount'] ?? 0,
                                  'availableSlotsCount': selectedDoctorStats?['statistics']['availableSlotsCount'] ?? 0,
                                  'patientCount': selectedDoctorStats?['statistics']['patientCount'] ?? 0,
                                  'averageRating': selectedDoctorStats?['statistics']['averageRating'] ?? 0,
                                  'numberOfReviews': selectedDoctorStats?['statistics']['numberOfReviews'] ?? 0,
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Appointments Ratio',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: _buildPieChartSections(),
                                    centerSpaceRadius: 50,
                                    sectionsSpace: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LegendItem(
                                      color: const Color(0xffC8A7DB),

                                      label:
                                          'Booked appointment: ${selectedDoctorStats?['statistics']['appointmentCount'] ?? 0}'),
                                  const SizedBox(width: 16),
                                  LegendItem(
                                      color: const Color(0xff4F246E),
                                      label:
                                          'Available appointment: ${selectedDoctorStats?['statistics']['availableSlotsCount'] ?? 0}'),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
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
        color: const Color(0xffC8A7DB),
        value: appointmentCount.toDouble(),
        title: '${((appointmentCount / total) * 100).toStringAsFixed(1)}%',
        radius: 100,
         titleStyle: const TextStyle(
    fontSize: 14,
    color: Colors.white,
  ),
      ),
      PieChartSectionData(
        color: const Color(0xff4F246E),
        value: availableSlotsCount.toDouble(),
        title: '${((availableSlotsCount / total) * 100).toStringAsFixed(1)}%',
        radius: 100,
         titleStyle: const TextStyle(
    fontSize: 14,
    color: Colors.white,
  ),
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
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
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
          color: const Color(0xff6A1B9A),
          icon: Icons.people, 
        ),
        StatCard(
          title: "Average Rating",
          value: statistics['averageRating'].toString(),
          color: const Color(0xff6A1B9A),
          icon: Icons.star, 
        ),
        StatCard(
          title: "Number Of Reviews",
          value: statistics['numberOfReviews'].toString(),
          color: const Color(0xff6A1B9A),
          icon: Icons.reviews, 
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon, 
  });




 @override
  Widget build(BuildContext context) {
    return Card(
     color: const Color.fromARGB(255, 250, 240, 250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SpecializationChart extends StatelessWidget {
  final List<dynamic> statistics; 

  const SpecializationChart({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataSource = statistics.map((item) {
      return FeatureUsageData(
        item['specialization'] as String, 
        item['count'] as int, 
        const Color(0xff613089), 
      );
    }).toList();

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: SfCartesianChart(
        title: ChartTitle(text: 'Doctors Count By Specialization'),
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


class SidePanel extends StatelessWidget {
  final Function(String startDate, String endDate) onDateRangeSelected;

  const SidePanel({Key? key, required this.onDateRangeSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: const Color.fromARGB(255, 233, 218, 239),
      child: Column(
        children: [
          CalendarWidget(onDateRangeSelected: onDateRangeSelected),
          Expanded(
            child: ListView(
              children: const [

              ],
            ),
          ),
        ],
      ),
    );
  }
}
