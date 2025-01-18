import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/constants.dart'as constants;
import 'package:flutter_application_3/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorCalendarPage extends StatefulWidget {
  @override
  _DoctorCalendarPageState createState() => _DoctorCalendarPageState();
}

class _DoctorCalendarPageState extends State<DoctorCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _events = [];
  String? doctorid;

  @override
  void initState() {
    super.initState();
    _fetchDoctorId();
  }

  Future<void> _fetchDoctorId() async {
    doctorid = await storage.read(key: 'userid');
    if (doctorid != null) {
      //_fetchSchedule(selectedDay); 
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
          "Calendar",
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
          double screenWidth = constraints.maxWidth;
          double pageWidth = screenWidth > 800 ? 900 : screenWidth * 1;

          return Center(
            child: SizedBox(
              width: pageWidth,
              child: Column(
                children: [
                  _buildCalendar(),
                  Expanded(
                    child: _buildEventList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool isPastEvent(DateTime selectedDate) {
    var now = DateTime.now();
    return selectedDate.isBefore(now);
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
            _fetchBookedSlots();
          });
        },
        eventLoader: (day) {
          return _events.where((event) {
            if (event['date'] == null || event['date'] is! String) {
              return false;
            }
            try {
              DateTime eventDate = DateFormat('yyyy-MM-dd').parse(event['date']);
              return isSameDay(eventDate, day);
            } catch (e) {
              return false;
            }
          }).toList();
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color(0xff613089),
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
          markersMaxCount: 3, 
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  bool isPastEventByDayTime(DateTime selectedDay, String eventTime) {
    var now = DateTime.now();
    if (eventTime.isEmpty) return false;

    try {
      var eventTimeParsed = DateFormat("HH:mm").parse(eventTime);
      var eventDateTime = DateTime(
        selectedDay.year, 
        selectedDay.month, 
        selectedDay.day, 
        eventTimeParsed.hour, 
        eventTimeParsed.minute,
      );
      return eventDateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  String formatEventTime(String time) {
    try {
      var parsedTime = DateFormat("HH:mm").parse(time);
      return DateFormat.jm().format(parsedTime); 
    } catch (e) {
      return "Invalid time";
    }
  }

  Widget _buildEventList() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff613089),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 5),
          if (_events.isEmpty)
            const Center(
              child: Text(
                "No events for this day.",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final slotDetails = _events[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xff613089).withOpacity(0.2),
                      child: const Icon(Icons.event, color: Color(0xff613089)),
                    ),
                    title: Text(
                      "Time: ${formatEventTime(slotDetails['time'])}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff613089),
                      ),
                    ),
                    subtitle: Text(
                      "Patient: ${slotDetails['patientName']}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: isPastEventByDayTime(_selectedDay!, slotDetails['time'])
                        ? const Text(
                            "Completed",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
 onPressed: () {
    _cancelEvent(index);
  },                          ),
                    onTap: () {
                      double dialogWidth = MediaQuery.of(context).size.width > 600
                          ? 600
                          : MediaQuery.of(context).size.width * 0.9;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              width: dialogWidth, 
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Time: ${formatEventTime(slotDetails['time'])}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff613089),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Patient Name: ${slotDetails['patientName']}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Notes: ${slotDetails['notes']?.isEmpty ?? true ? 'no notes.' : slotDetails['notes']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xff613089),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        "Close",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

 void _cancelEvent(int index) async {
  final String appointmentId = _events[index]['appointmentId'];
  final String apiUrl = "${constants.ApiConstants.baseUrl}/appointment/$appointmentId/cancel";

  try {
    final response = await http.patch(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        _events.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment canceled successfully.")),
      );
    } else {
      final errorMessage = json.decode(response.body)['message'] ?? 'Failed to cancel appointment.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $errorMessage")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $e")),
    );
  }
 _sendNotification(_events[index]['patientId']['_id'], "MediCardia",
              "Dr.${await storage.read(key: 'username')} has canceld your appointment, you can check your celender page for more details");

  
}

  void _sendNotification(
      String receiverId, String title, String message) async {
    final DatabaseReference usersRef =
        FirebaseDatabase.instance.ref('users/$receiverId');
    final DataSnapshot snapshot = await usersRef.get();

    if (snapshot.exists) {
      final String? fcmToken = snapshot.child('fcmToken').value as String?;

      if (fcmToken != null) {
        try {
          await sendNotifications(
              fcmToken: fcmToken,
              title: title,
              body: message,
              userId: receiverId,
              type: 'appointment');
          print('Notification sent successfully');
        } catch (error) {
          print('Error sending notification: $error');
        }
      } else {
        print('FCM token not found for the user.');
      }
    } else {
      print('User not found in the database.');
    }
  }
  Future<void> _fetchBookedSlots() async {
    final String apiUrl = '${constants.ApiConstants.baseUrl}/appointment/schedules/$doctorid/booked';

    if (_selectedDay == null) return;

    final selectedDate = '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';
    String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(selectedDate));

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'date': formattedDate}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _events = List<Map<String, dynamic>>.from(data['slots']);
      });
    } else {
      setState(() {
        _events = [];
      });
    }
  }
}
