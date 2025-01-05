import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorSchedulePage extends StatefulWidget {
  @override
  _DoctorSchedulePageState createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  final Map<DateTime, List<Map<String, String>>> schedule = {};
  DateTime selectedDay = DateTime.now();
  int durationMinutes = 15; 
  String? doctorid;

  @override
  void initState() {
    super.initState();
    _fetchDoctorId();
    _buildCalendar();
  }

  Future<void> _fetchDoctorId() async {
    doctorid = await storage.read(key: 'userid');
    if (doctorid != null) {
      _fetchSchedule(selectedDay); 
    }
  }

 Future<void> _fetchSchedule(DateTime day) async {
  if (doctorid == null) return;

  final String apiUrl = "${ApiConstants.baseUrl}/appointment/$doctorid";
  final token = await storage.read(key: 'token') ?? '';
String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDay);

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'token': token,
      },
      body: json.encode({
        'date': formattedDate,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, String>> fetchedSlots = [];

      for (var scheduleItem in data['schedules']) {
        fetchedSlots.add({
          'start': scheduleItem['time']['from'],
          'end': scheduleItem['time']['to'],
        });
      }

      setState(() {
        schedule[day] = fetchedSlots;
      });
    } else {/*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch schedules: ${response.body}")),
      );*/
    }
  } catch (error) {
    if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error fetching schedules: $error")),
    );}
  }
}


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
        leading: IconButton(
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
                "Set your working schedule",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 20),
              _buildCalendar(),
              const SizedBox(height: 20),
              _buildDurationSelector(),
              const SizedBox(height: 20),
              _buildScheduleList(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF613089),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Save Schedule",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {

    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime(DateTime.now().year + 1, 12, 31),
      focusedDay: selectedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: (selected, focused) {
        setState(() {
          selectedDay = selected;
        });
        
        _fetchSchedule(selected);
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: const Color(0xFF6A1B9A),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: const Color(0xFF6A1B9A).withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
    
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select appointment duration:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6A1B9A),
          ),
        ),
        DropdownButton<int>(
          value: durationMinutes,
          items: [15, 30, 45, 60]
              .map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text("$value minutes"),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              durationMinutes = value!;
            });
          },
        ),
      ],
    );
  }
Widget _buildScheduleList() {
  final times = schedule[selectedDay] ?? [];
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
            "Schedule for ${_formatDate(selectedDay)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              for (var slot in times)
                ListTile(
                  title: Text(
                    "${slot['start']} - ${slot['end']}",
                    style: const TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  /*  IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF6A1B9A)),
                        onPressed: () {
                          _showEditTimeSlotDialog(slot['start']!, slot['end']!);
                        },
                      ),*/
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFF6A1B9A)),
                        onPressed: () {
                          _deleteTimeSlot(slot['start']!, slot['end']!);
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add Time Slot",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _addTimeSlot,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showEditTimeSlotDialog(String oldStart, String oldEnd) async {
  TimeOfDay? startTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: int.parse(oldStart.split(':')[0]), minute: int.parse(oldStart.split(':')[1])),
  );

  if (startTime != null) {
    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(oldEnd.split(':')[0]), minute: int.parse(oldEnd.split(':')[1])),
    );

    if (endTime != null) {
      String newStartTime =
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      String newEndTime =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

      await _updateTimeSlot(oldStart, oldEnd, newStartTime, newEndTime);
    }
  }
}


  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
Map<String, String> newSlot = {};

Future<void> _addTimeSlot() async {
  TimeOfDay? startTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (startTime != null) {
    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute),
    );

    if (endTime != null) {
      String formattedStartTime =
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      String formattedEndTime =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

      setState(() {
        schedule.putIfAbsent(selectedDay, () => []).add({
          'start': formattedStartTime,
          'end': formattedEndTime,
        });

        newSlot = {
          'start': formattedStartTime,
          'end': formattedEndTime,
        };
      });
    }
  }
}
Future<void> _deleteTimeSlot(String start, String end) async {
  final String apiUrl = "${ApiConstants.baseUrl}/appointment/$doctorid/schedule";
  final token = await storage.read(key: 'token') ?? '';
String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDay);

  final uri = Uri.parse(apiUrl);

  final response = await http.delete(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'token': token,
    },
    body: json.encode({
      'startTime': start,
      'endTime': end,
      'date':formattedDate,
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Schedule deleted successfully!")),
    );

    setState(() {
      schedule[selectedDay]?.removeWhere((slot) => slot['start'] == start && slot['end'] == end);
      if (schedule[selectedDay]?.isEmpty ?? false) {
        schedule.remove(selectedDay);
      }
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(end)),
    );
  }
}

Future<void> _updateTimeSlot(String oldStart, String oldEnd, String newStart, String newEnd) async {
  final String apiUrl = "${ApiConstants.baseUrl}/appointment/$doctorid/schedule";
  final token = await storage.read(key: 'token') ?? '';

  final uri = Uri.parse(apiUrl);

  final response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'token': token,
    },
    body: json.encode({
      'from': oldStart,
      'to': oldEnd,
      'newFrom': newStart,
      'newTo': newEnd,
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Schedule updated successfully!")),
    );
    _fetchSchedule(selectedDay); 
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.body)),
    );
  }
}

Future<void> _saveSchedule() async {
  doctorid = await storage.read(key: 'userid');

  final String apiUrl = "${ApiConstants.baseUrl}/appointment/$doctorid/schedule";
  final token = await storage.read(key: 'token') ?? '';

  final uri = Uri.parse(apiUrl);

  if (newSlot.isNotEmpty) {
    final startTime = newSlot['start'];
    final endTime = newSlot['end'];
String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDay);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'token': token,
      },
      body: json.encode({
        'doctorId': doctorid,
        'startTime': startTime,
        'endTime': endTime,
        'durationMinutes': durationMinutes,
                'date' : formattedDate,

      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule saved successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("The schedule saved Successfully")),
      );
    }
  }
}


}