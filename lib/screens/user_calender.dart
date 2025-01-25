
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';




class PatientAppointment extends StatefulWidget {
  @override
  _AppointmentFilterUIState createState() => _AppointmentFilterUIState();
}



class _AppointmentFilterUIState extends State<PatientAppointment> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
    List<String> availableTimes = [];

List<Map<String, dynamic>> CanceledSlots = [];
  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    _fetchCanceledSlots();
  }



  Future<void> _fetchCanceledSlots() async {
    String userId =  await storage.read(key: 'userid') ?? '';
     String apiUrl = "${ApiConstants.baseUrl}/appointment/$userId/cancelled";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          CanceledSlots = (data['appointments'] as List).map((item) {
            return {
              "id":item['_id'],
              "date": item['date'],
              "time": item['time'],
              "doctorId":item['doctorId']['_id'],
              "doctor": item['doctorId']['fullName'],
              "specialization": item['doctorId']['specialization'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = json.decode(response.body)['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load canceled appointments. Please try again later.";
        _isLoading = false;
      });
    }
  }




  Future<void> _fetchAppointments() async {
    String userId =  await storage.read(key: 'userid') ?? '';
     String apiUrl = "${ApiConstants.baseUrl}/appointment/$userId/booked";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = (data['appointments'] as List).map((item) {
            return {
              "id":item['_id'],
              "date": item['date'],
              "time": item['time'],
              "doctor": item['doctorId']['fullName'],
              "specialization": item['doctorId']['specialization'],
              "canceledByDoctor": false, 
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = json.decode(response.body)['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load your appointments. Please try again later.";
        _isLoading = false;
      });
    }
  }



//////////////////////////////



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Appointments",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
            fontSize: 24,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                       if (_appointments.isNotEmpty) _sectionTitle("Current Appointments"),
    _appointments.isEmpty
        ? Center(
            child: Text(
              'No booked appointments found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          )
        : Expanded(child: _buildCurrentAppointmentsTable()),

                    
                    CanceledSlots.isEmpty
                        ? Center(child: Text('No canceled appointments found.',
                         style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[500]),
                                    ))
                        : Expanded(child: _buildDoctorCanceledAppointments()),
                    ],
                  ),
                ),
    );
  }

  
  String formatEventTime(String time) {
    try {
      var parsedTime = DateFormat("HH:mm").parse(time);
      return DateFormat.jm().format(parsedTime); 
    } catch (e) {
      return "Invalid time";
    }
  }


  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF613089),
          ),
        ),
      ),
    );
  }

  
Widget _buildCurrentAppointmentsTable() {
  List<Map<String, dynamic>> currentAppointments = _appointments.where((appointment) {
    return !appointment["canceledByDoctor"];
  }).toList();

  return Card(
    color: Colors.white,
    margin: const EdgeInsets.all(16.0),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF3E5F5)),
            dataRowColor: MaterialStateProperty.all(Colors.white),
            columnSpacing: 20.0,
            horizontalMargin: 20.0,
            headingTextStyle: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            dataTextStyle: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
            border: TableBorder(
              borderRadius: BorderRadius.circular(16.0),
              horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            columns: const [
              DataColumn(label: Text("Doctor")),
              DataColumn(label: Text("Date")),
              DataColumn(label: Text("Time")),
              DataColumn(label: Text("Actions")),
            ],
            rows: currentAppointments.isNotEmpty
                ? currentAppointments.map((appointment) {
                    return DataRow(cells: [
                      DataCell(Text(appointment['doctor'])),
                      DataCell(Text(appointment['date'])),
                      DataCell(Text(formatEventTime(appointment['time']))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFF928794)),
                          onPressed: () {
                            _deleteAppointment(appointment);
                          },
                        ),
                      ),
                    ]);
                  }).toList()
                : [
                    const DataRow(cells: [
                      DataCell(Text("No appointments available", style: TextStyle(color: Colors.grey))),
                      DataCell(Text("")),
                      DataCell(Text("")),
                      DataCell(Text("")),
                    ]),
                  ],
          ),
        ),
      ],
    ),
  );
}




Widget _buildDoctorCanceledAppointments() {
  print(CanceledSlots);
  const Padding(
      padding: EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Appointments Canceled By Doctor",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF613089),
          ),
        ),
      ),
    );
  return Card(
    color: Colors.white,
    margin: const EdgeInsets.all(16.0),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const Padding(
            padding: EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Appointments Canceled By Doctor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF613089),
                ),
              ),
            ),
          ),
          CanceledSlots.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  itemCount: CanceledSlots.length,
                  itemBuilder: (context, index) {
                    final appointment = CanceledSlots[index];
                    return _appointmentCard(appointment);
                  },
                )
              : const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No appointments canceled.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ],
      ),
    ),
  );
}


Widget _appointmentCard(Map<String, dynamic> appointment) {
  return Card(
    color: Colors.white,
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.cancel,
              color: Color(0xff613089),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Dr ${appointment['doctor']} (${appointment['specialization']})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                 
                  ),
                ),
            Row(
  mainAxisAlignment: MainAxisAlignment.end, 
  children: [
    PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert), 
      onSelected: (String value) {
        if (value == 'Choose New Slot') {
          _chooseNewAppointment(appointment);
           
        } else if (value == 'delete') {
          _deleteAppointment(appointment);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Choose New Slot',
          child: Row(
            children: [
              Icon(Icons.refresh, color: Color(0xff613089)),
              SizedBox(width: 8),
              Text('Choose New Slot'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_forever, color: Color(0xff613089)),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
        
      ],
      color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
      ),
    ),
    
  ],
)

              ],
            ),
            subtitle: Text(
              "Date: ${appointment['date']}\nTime: ${formatEventTime(appointment['time'])}",

            ),
          ),
        ],
      ),
    ),
  );
}



  void _editAppointment(Map<String, dynamic> appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit appointment functionality coming soon!")),
    );



  }



  void _deleteAppointment(Map<String, dynamic> appointment) async {
  final String apiUrl =
      "${ApiConstants.baseUrl}/appointment/${appointment['id']}"; // Replace with the correct endpoint

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Add authorization token if required
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _appointments.remove(appointment);
      });
     /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment deleted successfully.")),
      );*/
   //     _fetchAppointments();
    _fetchCanceledSlots();
    } else {
     /* final error = json.decode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $error")),
      );*/
    }
  } catch (e) {
    /*ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("An error occurred. Please try again.")),
    );*/
  }
}

/*
  void _deleteAppointment(Map<String, dynamic> appointment) {
    setState(() {
      _appointments.remove(appointment);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment deleted.")));
  }*/
  
  
 Future<void> _fetchAvailableTimes(String doctorId, DateTime date) async {
  String apiUrl = "${ApiConstants.baseUrl}/appointment/schedules/$doctorId/slots";
  String formattedDate = DateFormat('dd-MM-yyyy').format(date);
print(date);
  setState(() {
    availableTimes = [];
    _isLoading = true;
  });

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "date": formattedDate, // Use the formatted date directly without extra encoding
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        availableTimes = (data['slots'] as List<dynamic>)
            .map((slot) => slot['time'] as String)
            .toList();
      });
      print(availableTimes);
    } else {
      print("Error fetching available slots: ${response.body}");
      setState(() {
        _errorMessage = "Failed to fetch available slots. Please try again.";
      });
    }
  } catch (e) {
    print("Error: $e");
    setState(() {
      _errorMessage = "Error: Unable to fetch available slots.";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}



void _chooseNewAppointment(Map<String, dynamic> canceledAppointment) async {
  if (_isLoading) {
    print("Loading in progress. Please wait.");
    return;
  }
print(canceledAppointment['date']);
await _fetchAvailableTimes(
  canceledAppointment['doctorId'],
  DateFormat('dd-MM-yyyy').parse(canceledAppointment['date']),
);
  if (availableTimes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No available slots for the selected doctor."),
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      String? selectedTime; 
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              "Choose a new appointment for Dr. ${canceledAppointment['doctor']}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF613089),
              ),
            ),
            content: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        child: availableTimes.isNotEmpty
                            ? SizedBox(
                                height: 240, 
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: availableTimes.map((slot) {
                                      return ChoiceChip(
                                        backgroundColor: Colors.white,
                                        label: Text(
                                          "${canceledAppointment['date']} at ${formatEventTime(slot)}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        selected: selectedTime == slot,
                                        onSelected: (selected) {
                                          setState(() {
                                            selectedTime = selected ? slot : null;
                                          });
                                        },
                                        selectedColor: const Color(0xFF613089),
                                        labelStyle: TextStyle(
                                          color: selectedTime == slot
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "No available slots",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: selectedTime != null
                            ? () async {
                                await _proceedToBookAppointment(
                                  context,
                                  canceledAppointment['doctorId'],
                                  canceledAppointment['doctor'],
                                  selectedTime!,
                                  DateFormat('dd-MM-yyyy').parse(canceledAppointment['date']),
                                  "No notes",
                                  canceledAppointment['date'],
                                  await storage.read(key: 'token'),
                                );
                                Navigator.pop(context);
                                  _deleteAppointment(canceledAppointment);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF613089),
                          disabledForegroundColor: Colors.black.withOpacity(0.7),
                          disabledBackgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Book Appointment",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      );
    },
  );
}




Future<void> _proceedToBookAppointment(
  BuildContext context,
  String doctorId,
    String doctorname,

  String selectedTime,
  DateTime selectedDate,
  String notes,
  String formattedDate,
  String? token,
) async {
  try {
    print('innnnnnn');
    String apiUrl = "${ApiConstants.baseUrl}/appointment/schedules/$doctorId/book";
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
      
      if (!mounted) return;
      showDialog(
        
        context: context,
        builder: (context) => Dialog(
           backgroundColor: const Color(0xffF0E5FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 50,
                  color:Color(0xff613089),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Appointment Booked",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff613089),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "with Dr. $doctorname",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Text(
                  "Date: $formattedDate",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  "Time: $selectedTime",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                if (notes.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        "Notes: $notes",
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);  
                    Navigator.pop(context);  
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff613089),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
          Navigator.pop(context); 
          _fetchAppointments();
    _fetchCanceledSlots();

    } else {
      var errorBody = jsonDecode(response.body);
      print("Error: ${errorBody['message']}");
if (!mounted) return;
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
                const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Error",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  errorBody['message'],
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);  
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
          Navigator.pop(context);
          _fetchAppointments();
    _fetchCanceledSlots(); 

    }
  } catch (error) {
    print("Error booking appointment: $error");
if (!mounted) return;
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
              const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                "Error",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Failed to book the appointment.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);  
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
        Navigator.pop(context); 
        _fetchAppointments();
    _fetchCanceledSlots();

  }
}

}
