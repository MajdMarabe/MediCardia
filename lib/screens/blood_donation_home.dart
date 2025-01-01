import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'donation_requests.dart';

class BloodDonationHome extends StatefulWidget {
  @override
  _BloodDonationHomeState createState() => _BloodDonationHomeState();
}

class _BloodDonationHomeState extends State<BloodDonationHome> {
  List<DateTime> donationDates = [
    DateTime(2023, 5, 10),
    DateTime(2024, 1, 1),
    DateTime(2024, 7, 25),
    DateTime(2024, 10, 15),
    DateTime(2025, 2, 14),
  ];

  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: kIsWeb
          ? AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Text(
                'Blood Donation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                  letterSpacing: 1.5,
                ),
              ),
            )
          : AppBar(
              backgroundColor: const Color(0xFFF2F5FF),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff613089)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              centerTitle: true,
              title: const Text(
                'Blood Donation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff613089),
                  letterSpacing: 1.5,
                ),
              ),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          if (kIsWeb && width > 600) {
            width = 1000;
          }

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Your Donation History",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff613089),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    donationDates.isEmpty
                        ? const Center(
                            child: Text(
                              'No donation records available.',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white70),
                            ),
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              ...donationDates.reversed
                                  .take(showAll ? donationDates.length : 3)
                                  .map((date) => _buildDonationCard(
                                      date, date == donationDates.last))
                                  .toList(),
                              if (donationDates.length > 3)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showAll = !showAll;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      showAll ? 'Show Less' : 'Show All',
                                      style: const TextStyle(
                                        color: Color(0xff613089),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonationRequestsPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/blood-donation-request.png',
                          width: 22,
                          height: 22,
                          color: const Color(0xff613089),
                        ),
                        label: const Text(
                          'Go to Blood Donation Requests',
                          style: TextStyle(
                              color: Color(0xff613089),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonationCard(DateTime date, bool isLatest) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLatest ? const Color(0xFFE9D9FF) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xff8E44AD),
            child: Icon(Icons.calendar_month, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Donation Date: ${formatDate(date)}     ',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Days since last donation: ${_daysSinceLastDonation(date)}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          if (isLatest)
            IconButton(
              icon: const Icon(
                Icons.edit_calendar_sharp,
                color: Color(0xff613089),
              ),
              onPressed: () {
                _selectDate(context, TextEditingController(), (newDate) {
                  setState(() {
                    // Update the donation date in the list
                    int index = donationDates.indexOf(date);
                    if (index != -1) {
                      donationDates[index] = DateTime.parse(newDate);
                    }
                  });
                });
              },
            ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context,
      TextEditingController controller, Function(String) onSave) async {
    DateTime initialDate = DateTime.now();
    DateTime? selectedDate = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Last Donation Date',
              style: TextStyle(color: Color(0xff613089))),
          content: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: initialDate,
                    onDaySelected: (selectedDay, focusedDay) {
                      controller.text = "${selectedDay.toLocal()}"
                          .split(' ')[0]; // Format the date
                      onSave(controller.text);
                      Navigator.of(context).pop();
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xffb41391),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color(0xff613089),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleTextStyle:
                          TextStyle(color: Color(0xff613089), fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDate != null) {
      controller.text = "${selectedDate.toLocal()}".split(' ')[0];
      onSave(controller.text);
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  int _daysSinceLastDonation(DateTime date) {
    final now = DateTime.now();
    return now.difference(date).inDays;
  }
}
