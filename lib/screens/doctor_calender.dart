import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorCalendarPage extends StatefulWidget {
  @override
  _DoctorCalendarPageState createState() => _DoctorCalendarPageState();
}

class _DoctorCalendarPageState extends State<DoctorCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _events = {
    DateTime.now(): ['Routine Checkup - 10:00 AM', 'Cardiology Conference - 3:00 PM'],
    DateTime.now().add(Duration(days: 1)): ['Surgery - 9:00 AM', 'Team Meeting - 2:00 PM'],
    DateTime.now().add(Duration(days: 3)): ['Follow-up Appointment - 11:30 AM'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        backgroundColor: const Color(0xff613089),
      ),
      body: Column(
        children: [
          // Calendar Widget
          _buildCalendar(),
          const SizedBox(height: 10),
          // Scheduled Events Section
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
    
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: (day) => _events[day] ?? [],
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: const Color(0xff613089),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      
    );
    
  }

  Widget _buildEventList() {
    final events = _events[_selectedDay] ?? [];
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Scheduled Events",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff613089),
            ),
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            const Center(
              child: Text(
                "No events for this day",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      child: const Icon(Icons.event, color: Colors.blue),
                    ),
                    title: Text(events[index]),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      // Action on tap (e.g., view event details)
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
