import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PatientAppointment extends StatefulWidget {
  @override
  _AppointmentFilterUIState createState() => _AppointmentFilterUIState();
}

class _AppointmentFilterUIState extends State<PatientAppointment> {
  final List<Map<String, dynamic>> _appointments = [
    {
      "date": "2025-01-15",
      "time": "10:00 AM",
      "doctor": "Dr. Smith",
      "canceledByDoctor": false
    },
    {
      "date": "2025-01-16",
      "time": "11:00 AM",
      "doctor": "Dr. Lee",
      "canceledByDoctor": true
    },
    {
      "date": "2025-01-17",
      "time": "12:00 PM",
      "doctor": "Dr. Johnson",
      "canceledByDoctor": false
    },
    {
      "date": "2025-01-17",
      "time": "02:00 PM",
      "doctor": "Dr. Smith",
      "canceledByDoctor": true
    },
  ];

  final List<Map<String, dynamic>> availableSlots = [
    {"date": "2025-01-18", "time": "09:00 AM", "doctor": "Dr. Smith"},
    {"date": "2025-01-18", "time": "02:00 PM", "doctor": "Dr. Smith"},
    {"date": "2025-01-19", "time": "11:00 AM", "doctor": "Dr. Lee"},
  ];

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _sectionTitle("Current Appointments"),
            Expanded(child: _buildCurrentAppointmentsTable()),

            _sectionTitle("Appointments Canceled by Doctor"),
            Expanded(child: _buildDoctorCanceledAppointments()),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF613089)),
        ),
      ),
    );
  }

Widget _buildCurrentAppointmentsTable() {
  List<Map<String, dynamic>> currentAppointments = _appointments.where((appointment) {
    return !appointment["canceledByDoctor"];
  }).toList();

  return currentAppointments.isNotEmpty
      ? Card(
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
                  rows: currentAppointments.map((appointment) {
                    return DataRow(cells: [
                      DataCell(Text(appointment['doctor'])),
                      DataCell(Text(appointment['date'])),
                      DataCell(Text(appointment['time'])),
                      DataCell(
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.black54),
                          onSelected: (String value) {
                            if (value == 'edit') {
                              _editAppointment(appointment);
                            } else if (value == 'delete') {
                              _deleteAppointment(appointment);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 10),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 10),
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
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        )
      : const Center(
          child: Text(
            "No current appointments available.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        );
}



  Widget _buildDoctorCanceledAppointments() {
    List<Map<String, dynamic>> canceledByDoctorAppointments = _appointments
        .where((appointment) => appointment["canceledByDoctor"])
        .toList();

    return canceledByDoctorAppointments.isNotEmpty
        ? ListView.builder(
            itemCount: canceledByDoctorAppointments.length,
            itemBuilder: (context, index) {
              final appointment = canceledByDoctorAppointments[index];
              return _appointmentCard(appointment, isCanceledByDoctor: true);
            },
          )
        : const Center(
            child: Text("No appointments canceled by doctor.",
                style: TextStyle(color: Colors.grey)),
          );
  }

  Widget _appointmentCard(Map<String, dynamic> appointment,
      {bool isCanceledByDoctor = false}) {
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
              leading: Icon(
                isCanceledByDoctor ? Icons.cancel : Icons.calendar_today,
                color: isCanceledByDoctor ? Colors.red : Colors.blue,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Doctor: ${appointment['doctor']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (isCanceledByDoctor) ...[
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.green),
                          onPressed: () {
                            _chooseNewAppointment(appointment);
                          },
                          iconSize: 26,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () {
                            _deleteAppointment(appointment);
                          },
                          iconSize: 26,
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _editAppointment(appointment);
                          },
                          iconSize: 24,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteAppointment(appointment);
                          },
                          iconSize: 24,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                  "Date: ${appointment['date']}\nTime: ${appointment['time']}"),
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

  void _deleteAppointment(Map<String, dynamic> appointment) {
    setState(() {
      _appointments.remove(appointment);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment deleted.")));
  }

  void _chooseNewAppointment(Map<String, dynamic> canceledAppointment) {
    final doctorAppointments = availableSlots.where((slot) {
      return slot['doctor'] == canceledAppointment['doctor'] &&
          !_appointments.any((appointment) =>
              appointment['date'] == slot['date'] &&
              appointment['time'] == slot['time']);
    }).toList();

    if (doctorAppointments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No available slots for the selected doctor.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose a New Appointment for ${canceledAppointment['doctor']}"),
          content: doctorAppointments.isNotEmpty
              ? ListView.builder(
                  itemCount: doctorAppointments.length,
                  itemBuilder: (context, index) {
                    final slot = doctorAppointments[index];
                    return ListTile(
                      title: Text("${slot['date']} at ${slot['time']}"),
                      onTap: () {
                        setState(() {
                          _appointments.add({
                            "date": slot['date'],
                            "time": slot['time'],
                            "doctor": slot['doctor'],
                            "canceledByDoctor": false,
                          });
                          _appointments.remove(canceledAppointment);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("New appointment selected.")),
                        );
                      },
                    );
                  },
                )
              : const Center(child: Text("No available slots")),
        );
      },
    );
  }
}
