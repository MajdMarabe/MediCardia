import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BloodPressureControlPage extends StatefulWidget {
  @override
  _BloodPressureControlPageState createState() =>
      _BloodPressureControlPageState();
}

class _BloodPressureControlPageState extends State<BloodPressureControlPage> {
  final List<TimeOfDay> _reminderTimes = [];
  final List<double> _systolicReadings = [120, 130, 125, 135, 128, 132, 129];
  final List<double> _diastolicReadings = [80, 85, 82, 88, 83, 84, 86];
  final TextEditingController dateTimeController = TextEditingController();

  Future<void> _showReminderDialog(BuildContext context,
      {TimeOfDay? existingTime}) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(
                0xff613089), // Apply primary color to the time picker
            hintColor:
                const Color(0xff9c27b0), // Accent color for time selection
            timePickerTheme: const TimePickerThemeData(
              dialHandColor: Color(0xff613089), // Customize the dial hand
              dialTextColor: Colors.black, // Text color inside the dial
              backgroundColor:
                  Colors.white, // Background color of the time picker
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            //elevation: 10,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight:
                    300, // Set the maximum height of the card (adjust as needed)
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date & Time Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Date & Time',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        TextButton(
                          onPressed: () {
                            _selectDateTime(context, dateTimeController);
                            print(dateTimeController.text);
                          },
                          child: Text(
                            dateTimeController.text.isEmpty
                                ? 'Select Date & Time'
                                : dateTimeController.text,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

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

                    // Action Buttons inside the card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(),
                const SizedBox(height: 20),
                _buildGraphSection(),
                const SizedBox(height: 20),
                _buildReminderSection(context),
              ],
            ),
          ),
        ),
      ),
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
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphSection() {
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
            'Blood Pressure (Week Readings)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          'Day ${value.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        ),
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
                          (index) => FlSpot(
                              index.toDouble(), _systolicReadings[index])),
                      isCurved: true,
                      color: const Color(0xFF9B4F96),
                      barWidth: 4,
                      isStrokeCapRound: true,
                    ),
                    LineChartBarData(
                      spots: List.generate(
                          _diastolicReadings.length,
                          (index) => FlSpot(
                              index.toDouble(), _diastolicReadings[index])),
                      isCurved: true,
                      color: const Color(0xFF536DFE),
                      barWidth: 4,
                      isStrokeCapRound: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                  color: const Color(0xFF9B4F96), label: 'Systolic Pressure'),
              const SizedBox(width: 16),
              _buildLegendItem(
                  color: const Color(0xFF536DFE), label: 'Diastolic Pressure'),
            ],
          ),
        ],
      ),
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

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

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
          'avgSystolic': 120.0,
          'avgDiastolic': 80.0,
          'systolicLevels': [120.0, 125.0, 130.0, 115.0, 110.0, 118.0],
          'diastolicLevels': [80.0, 82.0, 78.0, 76.0, 79.0, 81.0],
          'labels': ['8 AM', '10 AM', '12 PM', '2 PM', '4 PM', '6 PM'],
        },
        'week': {
          'avgSystolic': 118.0,
          'avgDiastolic': 79.0,
          'systolicLevels': [120.0, 122.0, 118.0, 115.0, 121.0, 119.0, 123.0],
          'diastolicLevels': [80.0, 81.0, 78.0, 79.0, 77.0, 76.0, 80.0],
          'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        },
        'month': {
          'avgSystolic': 119.0,
          'avgDiastolic': 78.0,
          'systolicLevels': [120.0, 122.0, 119.0, 118.0],
          'diastolicLevels': [80.0, 81.0, 79.0, 78.0],
          'labels': ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2F5FF),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
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
        body: pressureData == null
            ? const Center(child: CircularProgressIndicator())
            : Builder(
                builder: (context) {
                  return TabBarView(
                    children: [
                      _buildGraphSection(
                        systolicLevels: List<double>.from(
                            pressureData!['today']['systolicLevels']),
                        diastolicLevels: List<double>.from(
                            pressureData!['today']['diastolicLevels']),
                        labels:
                            List<String>.from(pressureData!['today']['labels']),
                        period: 'Today',
                      ),
                      _buildGraphSection(
                        systolicLevels: List<double>.from(
                            pressureData!['week']['systolicLevels']),
                        diastolicLevels: List<double>.from(
                            pressureData!['week']['diastolicLevels']),
                        labels:
                            List<String>.from(pressureData!['week']['labels']),
                        period: 'Week',
                      ),
                      _buildGraphSection(
                        systolicLevels: List<double>.from(
                            pressureData!['month']['systolicLevels']),
                        diastolicLevels: List<double>.from(
                            pressureData!['month']['diastolicLevels']),
                        labels:
                            List<String>.from(pressureData!['month']['labels']),
                        period: 'Month',
                      ),
                    ],
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GraphDetailsPage()),
              );
            },
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          labels[value.toInt() % labels.length],
                          style: const TextStyle(fontSize: 12),
                        ),
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
                          (index) =>
                              FlSpot(index.toDouble(), systolicLevels[index])),
                      isCurved: true,
                      color: const Color(0xFF9B4F96),
                      barWidth: 4,
                      isStrokeCapRound: true,
                    ),
                    LineChartBarData(
                      spots: List.generate(
                          diastolicLevels.length,
                          (index) =>
                              FlSpot(index.toDouble(), diastolicLevels[index])),
                      isCurved: true,
                      color: const Color(0xFF536DFE),
                      barWidth: 4,
                      isStrokeCapRound: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                  color: const Color(0xFF9B4F96), label: 'Systolic Pressure'),
              const SizedBox(width: 16),
              _buildLegendItem(
                  color: const Color(0xFF536DFE), label: 'Diastolic Pressure'),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildLegendItem({required Color color, required String label}) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ],
  );
}
