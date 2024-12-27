import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

const storage = FlutterSecureStorage();

class DonationRequestsPage extends StatefulWidget {
  @override
  _DonationRequestsPageState createState() => _DonationRequestsPageState();
}

class _DonationRequestsPageState extends State<DonationRequestsPage> {
  List<dynamic> _donationRequests = [];
  double latitude = 32.22111;
  double longitude = 35.25444;
  String hospitalCity = '';
  String? userId;

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchDonationRequests();
  }

  Future<void> _fetchDonationRequests() async {
    try {
      userId = await storage.read(key: 'userid');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/donationrequest/getRequest/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['donationRequests'] != null) {
          setState(() {
            _donationRequests = data['donationRequests'];
          });
        }
      } else {
        print("Failed to fetch donation requests: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching donation requests: $e");
    }
  }

  Future<void> _getHospitalCoordinates(String hospitalName) async {
    try {
      List<Location> locations = await locationFromAddress(hospitalName);
      if (locations.isNotEmpty) {
        final double lat = locations.first.latitude;
        final double lng = locations.first.longitude;

        setState(() {
          latitude = lat;
          longitude = lng;
        });

        mapController.move(LatLng(lat, lng), 13.0);

        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final city = placemarks.first.locality;
          print("City: $city");
          setState(() {
            hospitalCity = city!;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found')),
        );
      }
    }
  }

  String formatDate(String isoDate) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate);
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      print("Error parsing date: $e");
      return isoDate;
    }
  }



/////////////////////////////////////////////////////////////



@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F5FF),
    appBar: kIsWeb
        ? AppBar(
            backgroundColor: const Color(0xFFF2F5FF),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Blood Donation Requests',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff613089),
                letterSpacing: 1.5,
              ),
            ),
            automaticallyImplyLeading: false,
          )
        : AppBar(
            backgroundColor: const Color(0xFFF2F5FF),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Blood Donation Requests',
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
    body: _donationRequests.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: Container(
              width: MediaQuery.of(context).size.width > 600
                  ? 900
                  : MediaQuery.of(context).size.width * 1,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: ListView.builder(
                itemCount: _donationRequests.length,
                itemBuilder: (context, index) {
                  final request = _donationRequests[index];
                  final hospital = request['hospital'];
                  final hospitalNameArabic = hospital['nameArabic'] ?? 'Unknown Hospital';
                  final hospitalName = hospital['name'] ?? 'Unknown Hospital';

                  _getHospitalCoordinates(hospitalNameArabic);

                  return Container(
                    width: double.infinity, 
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  hospitalName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff613089),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    request['bloodType'] ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xff613089),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.location_city, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  'City: ${hospital['city'] ?? 'Unknown'}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Icon(Icons.water_drop, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  'Units: ${request['units'] ?? 'Unknown'}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  'Phone: ${hospital['phone'] ?? 'Unknown'}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  'Date: ${formatDate(request['createdAt'] ?? 'Unknown')}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                height: 200,
                                child: FlutterMap(
                                  mapController: mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(latitude, longitude),
                                    initialZoom: 13.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(latitude, longitude),
                                          width: 80.0,
                                          height: 80.0,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),
          ),
  );
}



}
