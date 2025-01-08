import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageHospitalsPage extends StatefulWidget {
  const ManageHospitalsPage({Key? key}) : super(key: key);

  @override
  _ManageHospitalsPageState createState() => _ManageHospitalsPageState();
}

class _ManageHospitalsPageState extends State<ManageHospitalsPage> {
  List<Map<String, String>> hospitals = [
    {
      'name': 'City Hospital',
      'nameArabic': 'مستشفى المدينة',
      'city': 'New York',
      'phone': '+1 234 567 890',
      'latitude': '40.7128',
      'longitude': '-74.0060',
    },
    {
      'name': 'Sunrise Medical Center',
      'nameArabic': 'مركز صن رايز الطبي',
      'city': 'Los Angeles',
      'phone': '+1 987 654 321',
      'latitude': '34.0522',
      'longitude': '-118.2437',
    },
  ];

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F5FF),
    appBar: AppBar(
      title: const Text(
        'Hospital Management',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(35),
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff9C27B0), Color(0xff6A1B9A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Search functionality
          },
        ),
      ],
      automaticallyImplyLeading: !kIsWeb,
        leading: kIsWeb
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final double pageWidth = constraints.maxWidth > 600 ? 1000 : double.infinity;

        return Center(
          child: SizedBox(
            width: pageWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = hospitals[index];

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      leading: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xff613089),
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(
                            FontAwesomeIcons.hospital,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        hospital['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                      ),
                      subtitle: Text(
                        'City: ${hospital['city']}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Color(0xff6A1B9A)),
                            onPressed: () {
                              _showHospitalDetailsDialog(context, hospital);
                            },
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Color(0xff6A1B9A)),
                            onSelected: (value) {
                              if (value == 'Edit') {
                                _showEditHospitalDialog(context, hospital, index);
                              } else if (value == 'Delete') {
                                setState(() {
                                  hospitals.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${hospital['name']} deleted'),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Color(0xff6A1B9A)),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'Delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Color(0xff6A1B9A)),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: const Color(0xff6A1B9A),
      onPressed: () {
        _showAddHospitalDialog(context);
      },
      child: const Icon(Icons.add),
    ),
  );
}


void _showHospitalDetailsDialog(BuildContext context, Map<String, String> hospital) {
  showDialog(
    context: context,
    builder: (context) {
      double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9; 

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        child: Container(
          width: dialogWidth, 
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${hospital['name']} Details',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6A1B9A),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Arabic Name:', hospital['nameArabic'] ?? 'N/A'),
              _buildDetailRow('City:', hospital['city'] ?? 'N/A'),
              _buildDetailRow('Phone:', hospital['phone'] ?? 'N/A'),
              _buildDetailRow('Latitude:', hospital['latitude'] ?? 'N/A'),
              _buildDetailRow('Longitude:', hospital['longitude'] ?? 'N/A'),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6A1B9A),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff6A1B9A),
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditHospitalDialog(BuildContext context, Map<String, String> hospital, int index) {
  final TextEditingController nameController = TextEditingController(text: hospital['name']);
  final TextEditingController nameArabicController = TextEditingController(text: hospital['nameArabic']);
  final TextEditingController cityController = TextEditingController(text: hospital['city']);
  final TextEditingController phoneController = TextEditingController(text: hospital['phone']);
  final TextEditingController latitudeController = TextEditingController(text: hospital['latitude']);
  final TextEditingController longitudeController = TextEditingController(text: hospital['longitude']);

  showDialog(
    context: context,
    builder: (context) {
      double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9; 

      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Hospital',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff6A1B9A),
          ),
        ),
        content: SizedBox(
          width: dialogWidth, 
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(controller: nameController, label: 'Hospital Name', hint: 'Please enter hospital name'),
                const SizedBox(height: 10),
                _buildTextField(controller: nameArabicController, label: 'Arabic Name', hint: 'Please enter arabic name'),
                const SizedBox(height: 10),
                _buildTextField(controller: cityController, label: 'City', hint: 'Please enter city'),
                const SizedBox(height: 10),
                _buildTextField(controller: phoneController, label: 'Phone', hint: 'Please enter phone', keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _buildTextField(controller: latitudeController, label: 'Latitude', hint: 'Please enter latitude', keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField(controller: longitudeController, label: 'Longitude', hint: 'Please enter longitude', keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                hospitals[index] = {
                  'name': nameController.text,
                  'nameArabic': nameArabicController.text,
                  'city': cityController.text,
                  'phone': phoneController.text,
                  'latitude': latitudeController.text,
                  'longitude': longitudeController.text,
                };
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Hospital updated: ${nameController.text}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6A1B9A),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


  void _showAddHospitalDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController nameArabicController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController latitudeController = TextEditingController();
    final TextEditingController longitudeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
                double dialogWidth = MediaQuery.of(context).size.width > 600
            ? 600
            : MediaQuery.of(context).size.width * 0.9;
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Add New Hospital',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff6A1B9A),
            ),
          ),
              content: SizedBox(
          width: dialogWidth, 
         child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(controller: nameController, label: 'Hospital Name', hint: 'Please enter hospital name'),
                const SizedBox(height: 10),
                _buildTextField(controller: nameArabicController, label: 'Arabic Name', hint: 'Please enter arabic name'),
                const SizedBox(height: 10),
                _buildTextField(controller: cityController, label: 'City', hint: 'Please enter city'),
                const SizedBox(height: 10),
                _buildTextField(controller: phoneController, label: 'Phone', hint: 'Please enter phone', keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _buildTextField(controller: latitudeController, label: 'Latitude', hint: 'Please enter latitude', keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildTextField(controller: longitudeController, label: 'Longitude', hint: 'Please enter langitude',keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hospitals.add({
                    'name': nameController.text,
                    'nameArabic': nameArabicController.text,
                    'city': cityController.text,
                    'phone': phoneController.text,
                    'latitude': latitudeController.text,
                    'longitude': longitudeController.text,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hospital added: ${nameController.text}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6A1B9A),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Add'),
            ),
        ],
      );
    },
  );
}

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
     String? hint, 
     TextInputType keyboardType = TextInputType.text, 
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400, 
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
        labelStyle: const TextStyle(color: Color(0xff6A1B9A)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }
}
