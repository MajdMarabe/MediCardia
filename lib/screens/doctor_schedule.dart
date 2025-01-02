import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DoctorSchedulePage extends StatefulWidget {
  @override
  _DoctorSchedulePageState createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  final Map<String, List<String>> schedule = {
    "Sunday": [],
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": [],
    "Saturday": [],
  };

  String selectedDay = "Monday"; // Default selected day
  String selectedTime = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
      backgroundColor: const Color(0xFFF2F5FF),
      elevation: 0,
      centerTitle: true,
        title: const Text(
          "Doctor Schedule",
          style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xff613089),
          letterSpacing: 1.5,
        ),
        ),

           automaticallyImplyLeading: !kIsWeb,
      leading: kIsWeb
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF613089)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Set your working hours for each day",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 20),
              _buildDaySelector(),
              const SizedBox(height: 20),
              _buildScheduleList(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
  
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF613089),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                  child: const Text("Save Schedule",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildDaySelector() {
  return SingleChildScrollView(
    child: Wrap(
      spacing: 8.0, 
      runSpacing: 8.0, 
      children: schedule.keys.map((day) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = day;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: selectedDay == day ? const Color(0xFF6A1B9A) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selectedDay == day ? const Color(0xFF6A1B9A) : Colors.grey,
              ),
            ),
            child: Text(
              day,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selectedDay == day ? Colors.white : const Color(0xFF6A1B9A),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}



Widget _buildScheduleList() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 5,
    color: Colors.white,
    shadowColor: Colors.grey.withOpacity(0.3),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedDay,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var time in schedule[selectedDay]!)
                Chip(
                  label: Text(time), 
                  backgroundColor: const Color(0xFF6A1B9A).withOpacity(0.2),
                  labelStyle: const TextStyle(
                    color: Color(0xFF6A1B9A),
                  ),
                  onDeleted: () {
                    setState(() {
                      schedule[selectedDay]!.remove(time);
                    });
                  },
                ),
              IconButton(
                icon: const Icon(Icons.add),
                color: const Color(0xFF6A1B9A),
                onPressed: () {
                  _selectTime();
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


String _formatTime(TimeOfDay time) {
  int hour = time.hourOfPeriod; 
  String period = time.period == DayPeriod.am ? "AM" : "PM";
  String minute = time.minute < 10 ? "0${time.minute}" : "${time.minute}";

  return "$hour:$minute $period";
}

void _selectTime() async {
  final TimeOfDay? selected = await showTimePicker(
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
  );

  if (selected != null) {
    final String time = _formatTime(selected); 
    setState(() {
      selectedTime = time;
      schedule[selectedDay]!.add(time);
    });
  }
}
}