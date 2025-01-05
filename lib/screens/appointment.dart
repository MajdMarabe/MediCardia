import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert'; // For JSON decoding
import 'package:table_calendar/table_calendar.dart';

class AppointmentPage extends StatefulWidget {
    final String doctorid;
        final String name;

  const AppointmentPage({Key? key, required this.doctorid, required this.name}) : super(key: key);
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  List<String> availableTimes = [];
  bool isLoading = false;
  String? doctorid;
@override
  /*void initState() {
    super.initState();
    _fetchDoctorId();
  }*/

  Future<void> _fetchDoctorId() async {
    doctorid = await storage.read(key: 'userid');
    if (doctorid != null) {
     // _fetchSchedule(selectedDay); // Fetch the schedule for the current day
    }
  }

  Future<void> fetchAvailableTimes(DateTime date) async {
        doctorid = await storage.read(key: 'userid');
String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    setState(() {
      isLoading = true;
      availableTimes = [];
    });

    try {
      // Replace with your API URL
       String apiUrl = "${ApiConstants.baseUrl}/appointment/schedules/${widget.doctorid}/slots";
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"date": formattedDate}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // تحويل البيانات إلى قائمة النصوص المطلوبة
availableTimes = (data['slots'] as List<dynamic>)
    .map((slot) => slot['time'] as String)
    .toList();

        });
      } else {
        // Handle error
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    fetchAvailableTimes(selectedDate); // Fetch times for initial date
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
          final double pageWidth =
              constraints.maxWidth > 600 ? 900 : double.infinity;

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
                          selectedDayPredicate: (day) =>
                              isSameDay(selectedDate, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              selectedDate = selectedDay;
                              selectedTime = null;
                            });
                            fetchAvailableTimes(selectedDay);
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
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : availableTimes.isNotEmpty
                                ? Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: availableTimes
                                        .map(
                                          (time) => ChoiceChip(
                                            label: Text(time),
                                            selected: selectedTime == time,
                                            onSelected: (selected) {
                                              setState(() {
                                                selectedTime =
                                                    selected ? time : null;
                                              });
                                            },
                                            selectedColor:
                                                const Color(0xFF613089),
                                            labelStyle: TextStyle(
                                              color: selectedTime == time
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  )
                                : const Center(
                                    child: Text(
                                      "No available times for this day.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                      ),
                      const SizedBox(height: 30),
                     Center(
  child: ElevatedButton(
    onPressed: selectedTime != null
        ? () {
            // استدعاء دالة حجز الموعد
            bookAppointment(context, selectedTime!, selectedDate);
          }
        : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF613089),
      disabledForegroundColor: const Color(0xFF613089),
      disabledBackgroundColor: const Color(0xFF613089),
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

Future<void> bookAppointment(
  BuildContext context,
  String selectedTime,
  DateTime selectedDate,
) async {
  // اسم اليوم
  String dayName = _getDayName(selectedDate);
  String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
  final String? token = await storage.read(key: 'token');
  
  // طباعة المعلومات
  print("Appointment booked on $dayName at $selectedTime");

  // عرض نافذة حوارية للمريض لكتابة ملاحظات
  TextEditingController notesController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Add Notes (Optional)"),
      content: TextField(
        controller: notesController,
        decoration: InputDecoration(hintText: "Enter notes here..."),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);  // Close the dialog
            _proceedToBookAppointment(
              context,
              selectedTime,
              selectedDate,
              notesController.text,
              formattedDate,
              token,
            );
          },
          child: Text("Submit"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);  // Close the dialog without notes
            _proceedToBookAppointment(
              context,
              selectedTime,
              selectedDate,
              '',  // No notes
              formattedDate,
              token,
            );
          },
          child: Text("Skip"),
        ),
      ],
    ),
  );
}

Future<void> _proceedToBookAppointment(
  BuildContext context,
  String selectedTime,
  DateTime selectedDate,
  String notes,
  String formattedDate,
  String? token,
) async {
  try {
    String apiUrl = "${ApiConstants.baseUrl}/appointment/schedules/${widget.doctorid}/book";
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        'token': token ?? '',
      },
      body: jsonEncode({
        "date": formattedDate, 
        "time": selectedTime, 
        "notes": notes, 
      }),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print("Booking successful: ${responseBody['message']}");
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 50,
                  color: Colors.green,
                ),
                SizedBox(height: 16),
                Text(
                  "Appointment Booked",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "with Dr. ${widget.name}",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 12),
                Text(
                  "Date: , ${formattedDate}",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  "Time: $selectedTime",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                if (notes.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(height: 12),
                      Text(
                        "Notes: $notes",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);  
                    Navigator.pop(context);  
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      var errorBody = jsonDecode(response.body);
      print("Error: ${errorBody['message']}");

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  "Error",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  errorBody['message'],
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);  
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  } catch (error) {
    print("Error booking appointment: $error");

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                "Error",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Failed to book the appointment.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  String _getDayName(DateTime date) {
    return [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ][date.weekday - 1];
  }
}
