import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final Map<String, List<String>> availableTimesByDay = {
    "Monday": ["09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM"],
    "Tuesday": ["11:00 AM", "11:30 AM", "12:00 PM"],
    "Wednesday": ["01:00 PM", "01:30 PM", "02:00 PM"],
    "Thursday": ["10:00 AM", "11:00 AM"],
    "Friday": ["03:00 PM", "03:30 PM", "04:00 PM"],
  };

  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
      backgroundColor: const Color(0xFFF2F5FF),
      elevation: 0,
      centerTitle: true,
        title: const Text(
          "Appointment",
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
      body: LayoutBuilder(
        builder: (context, constraints) {
        
          final double pageWidth = constraints.maxWidth > 600 ? 900 : double.infinity;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: pageWidth), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Choose a Date",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF613089),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          focusedDay: selectedDate,
                          firstDay: DateTime(2023),
                          lastDay: DateTime(2030),
                          calendarFormat: CalendarFormat.month,
                          selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              selectedDate = selectedDay;
                              selectedTime = null;
                            });
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF613089),
                            ),
                          ),
                          calendarStyle: const CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: Color(0xFF613089),
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Available Times",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF613089),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Builder(
                          builder: (_) {
                            String dayName = _getDayName(selectedDate);
                            List<String>? availableTimes = availableTimesByDay[dayName];
                            if (availableTimes != null && availableTimes.isNotEmpty) {
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: availableTimes
                                    .map(
                                      (time) => ChoiceChip(
                                        label: Text(time),
                                        selected: selectedTime == time,
                                        onSelected: (selected) {
                                          setState(() {
                                            selectedTime = selected ? time : null;
                                          });
                                        },
                                        selectedColor: const Color(0xFF613089),
                                        labelStyle: TextStyle(
                                          color: selectedTime == time
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            } else {
                              return const Center(
                                child: Text(
                                  "No available times for this day.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: selectedTime != null
                              ? () {
                                  String dayName = _getDayName(selectedDate);
                                  print("Appointment booked on $dayName at $selectedTime");
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF613089),
                            disabledForegroundColor: const Color(0xFF613089), disabledBackgroundColor: const Color(0xFF613089),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Book Appointment",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
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

  String _getDayName(DateTime date) {
    return ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][date.weekday - 1];
  }
}
