import 'dart:convert';  
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';  
import 'package:flutter_application_3/screens/admin_home.dart';

class ManageAccountsPage1 extends StatefulWidget {
  const ManageAccountsPage1({Key? key}) : super(key: key);

  @override
  _ManageAccountsPageState createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage1> {
  bool isLoading = true;
  List<Map<String, String>> accounts = [];

  @override
  void initState() {
    super.initState();
    _fetchAccounts();  
  }

  Future<void> _fetchAccounts() async {
    final url = '${ApiConstants.baseUrl}/users';  
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Map<String, String>> users = [];

        for (var user in data['data']['users']) {
          users.add({
            'id': user['_id'],

            'name': user['username'],
            'phone': user['medicalCard']['publicData']['phoneNumber']??'',
            'location': user['location'],
            'email': user['email'],
            'role': 'User',
          });
        }

        for (var doctor in data['data']['doctors']) {
          users.add({
                        'id': doctor['_id'],

            'name': doctor['fullName'],
            'email': doctor['email'],
            'phone': doctor['phone'] ?? '', 
            'specialization': doctor['specialization'] ?? '', 
            'licenseNumber': doctor['licenseNumber'] ?? '',
            'workplaceName': doctor['workplace']?['name'] ?? '', 
            'workplaceAddress': doctor['workplace']?['address'] ?? '', 
            'role': 'Doctor',
          });
        }

        setState(() {
          accounts = users;
          isLoading = false; 
        });
      } else {
        throw Exception('Failed to load accounts');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Manage Accounts",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
          _showAddAccountDialog(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff613089)),
                          child: Text("Add New Account"),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AccountsList(accounts: accounts),
                  ],
                ),
              ),
            ),
          ),
          SidePanel(onDateRangeSelected: (startDate, endDate) {}),
        ],
      ),
    );
  }
void _showAddAccountDialog(BuildContext context) {
  String selectedRole = 'Doctor';
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController workplaceNameController = TextEditingController();
  final TextEditingController workplaceAddressController = TextEditingController();

  Future<void> _addAccount(String role) async {
    try {
      final String apiUrl = role == 'Doctor'
          ? '${ApiConstants.baseUrl}/doctors/addDoctor/admin'
          : '${ApiConstants.baseUrl}/users/addUser/admin';

      // Prepare data based on the role
      final Map<String, dynamic> requestData = role == 'Doctor'
          ? {
              "fullName": fullNameController.text,
              "email": emailController.text,
              "password_hash": passwordController.text,
              "phone": phoneController.text,
              "specialization": specializationController.text,
              "licenseNumber": licenseNumberController.text,
              "workplaceName": workplaceNameController.text,
              "workplaceAddress": workplaceAddressController.text,
            }
          : {
              "username": fullNameController.text,
              "email": emailController.text,
              "password_hash": passwordController.text,
              "location": locationController.text,
            };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // Include a token here if the API requires it
          'Authorization': 'Bearer <YOUR_ACCESS_TOKEN>',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 201) {
        // Success
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account created successfully: ${responseData['message'] ?? ''}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Error
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Failed to create account"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again later."),
          backgroundColor: Colors.red,
        ),
      );
      print("Error adding account: $error");
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9;
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5,
            backgroundColor: Colors.white,
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add New Account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xffb41391), width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButton<String>(
                        value: selectedRole,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRole = newValue!;
                          });
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: const Color(0xff6A1B9A),
                        items: <String>['Doctor', 'Patient']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff6A1B9A),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (selectedRole == 'Doctor') ...[
                      _buildTextField(controller: fullNameController, label: 'Full Name', hint: 'Please enter full name'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: emailController, label: 'Email', hint: 'Please enter email'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: passwordController, label: 'Password', obscureText: true, hint: 'Please enter password'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: phoneController, label: 'Phone', hint: 'Please enter phone'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: specializationController, label: 'Specialization', hint: 'Please enter specialization'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: licenseNumberController, label: 'License Number', hint: 'Please enter license number'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: workplaceNameController, label: 'Workplace Name', hint: 'Please enter workplace name'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: workplaceAddressController, label: 'Workplace Address', hint: 'Please enter workplace address'),
                    ],
                    if (selectedRole == 'Patient') ...[
                      _buildTextField(controller: fullNameController, label: 'Full Name', hint: 'Please enter full name'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: emailController, label: 'Email', hint: 'Please enter email'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: passwordController, label: 'Password', obscureText: true, hint: 'Please enter password'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: locationController, label: 'Location', hint: 'Please enter location'),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _addAccount(selectedRole);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6A1B9A),
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text('Add Account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}



}

class AccountsList extends StatelessWidget {
  final List<Map<String, String>> accounts;

  const AccountsList({required this.accounts});
Future<void> deleteDoctor(BuildContext context, String userId) async {
  final String apiUrl = '${ApiConstants.baseUrl}/doctors/$userId';

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer <YOUR_ACCESS_TOKEN>',
      },
    );

    if (response.statusCode == 200) {
      // User successfully deleted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("doctor has been deleted successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } else if (response.statusCode == 404) {
      // User not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("doctor not found."),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Other errors
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message'] ?? 'Failed to delete user.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (error) {
    // Handle network errors
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("An error occurred. Please try again later."),
        backgroundColor: Colors.red,
      ),
    );
    print("Error deleting user: $error");
  }
}
Future<void> deleteUser(BuildContext context, String userId) async {
  final String apiUrl = '${ApiConstants.baseUrl}/users/$userId';

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer <YOUR_ACCESS_TOKEN>',
      },
    );

    if (response.statusCode == 200) {
      // User successfully deleted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User has been deleted successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } else if (response.statusCode == 404) {
      // User not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not found."),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Other errors
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message'] ?? 'Failed to delete user.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (error) {
    // Handle network errors
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("An error occurred. Please try again later."),
        backgroundColor: Colors.red,
      ),
    );
    print("Error deleting user: $error");
  }
}

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Phone')),
        DataColumn(label: Text('Role')),
        DataColumn(label: Text('Actions')),
      ],
      rows: accounts.asMap().entries.map(
        (entry) {
          int index = entry.key;
          Map<String, String> account = entry.value;
          return DataRow(
            cells: [
              DataCell(Text(account['name'] ?? '')),
              DataCell(Text(account['email'] ?? '')),
              DataCell(Text(account['phone'] ?? '')),
              DataCell(Text(account['role'] ?? '')),
              DataCell(
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xff6A1B9A)),
                  onSelected: (value) {
                    if (value == 'Edit') {
                      if (account['role'] == 'Doctor') {
                        _showEditDoctorDialog(context, account);
                      } else {
                        _showEditPatientDialog(context, account);
                      }
                    } else if (value == 'Delete') {
                      if (account['role'] == 'User') {
                        deleteUser( context, account['id']!);
                        }else  if (account['role'] == 'Doctor'){

                         deleteDoctor( context, account['id']!);
                        }
                      accounts.removeAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${account['name']} deleted')),
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
              ),
            ],
          );
        },
      ).toList(),
    );
  }
}
  



void _showEditDoctorDialog(BuildContext context, Map<String, String> account) {
  final TextEditingController fullNameController = TextEditingController(text: account['name']);
  final TextEditingController emailController = TextEditingController(text: account['email']);
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(text: account['phone']);
  final TextEditingController specializationController = TextEditingController(text: account['specialization']);
  final TextEditingController licenseNumberController = TextEditingController(text: account['licenseNumber']);
  final TextEditingController workplaceNameController = TextEditingController(text: account['workplaceName']);
  final TextEditingController workplaceAddressController = TextEditingController(text: account['workplaceAddress']);
    void _saveProfile() async {
    final String username = fullNameController.text;
    final String email = emailController.text;
    final String phone = phoneController.text;
    final String workplaceName = workplaceNameController.text;
    final String licenseNumber = licenseNumberController.text;

    final String specialization = specializationController.text;

    final String workplaceAddress = workplaceAddressController.text;
    final String password = passwordController.text;
    final Map<String, dynamic> requestData = {
      'fullName': username,
      'email': email,
      'phone': phone,
      'password': password,
      'specialization':specialization,
      'licenseNumber':licenseNumber,
      'workplacename':workplaceName,
      'workplaceadress':workplaceAddress
    };

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/doctors/admin/update/${account['id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Error updating profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating profile. Please try again later."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  showDialog(
    context: context,
          builder: (context) {
        double dialogWidth = MediaQuery.of(context).size.width > 600
            ? 600
            : MediaQuery.of(context).size.width * 0.9;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        backgroundColor: Colors.white,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff6A1B9A),
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField(controller: fullNameController, label: 'Full Name', hint: 'Please enter full name'),
                const SizedBox(height: 10),
                _buildTextField(controller: emailController, label: 'Email',hint: 'Please enter email'),
                const SizedBox(height: 10),
                _buildTextField(controller: passwordController, label: 'Password', obscureText: true, hint: 'Please enter password'),
                const SizedBox(height: 10),
                _buildTextField(controller: phoneController, label: 'Phone Number', hint: 'Please enter phone number', keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _buildTextField(controller: specializationController, label: 'Specialization',hint: 'Please enter specialization'),
                const SizedBox(height: 10),
                _buildTextField(controller: licenseNumberController, label: 'License Number',hint: 'Please enter license number'),
                const SizedBox(height: 10),
                _buildTextField(controller: workplaceNameController, label: 'Workplace Name',hint: 'Please enter workplace name'),
                const SizedBox(height: 10),
                _buildTextField(controller: workplaceAddressController, label: 'Workplace Address',hint: 'Please enter workplace address'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6A1B9A),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}



Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  bool obscureText = false,
  String? hint, 
  TextInputType keyboardType = TextInputType.text, 
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
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
void _showEditPatientDialog(BuildContext context, Map<String, String> account) {
  final TextEditingController fullNameController = TextEditingController(text: account['name']);
  final TextEditingController emailController = TextEditingController(text: account['email']);
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController(text: account['location']);
  final TextEditingController phoneController = TextEditingController(text: account['phone']);

  void _saveProfile() async {
    final String username = fullNameController.text;
    final String email = emailController.text;
    final String phoneNumber = phoneController.text;
    final String location = locationController.text;
    final String password = passwordController.text;

    final Map<String, dynamic> requestData = {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'password': password,
    };

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/update/${account['id']}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // Successfully updated the profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Error updating profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating profile. Please try again later."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      double dialogWidth = MediaQuery.of(context).size.width > 600
          ? 600
          : MediaQuery.of(context).size.width * 0.9;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        backgroundColor: Colors.white,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Patient Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff6A1B9A),
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField(controller: fullNameController, label: 'Full Name', hint: 'Please enter full name'),
                const SizedBox(height: 10),
                _buildTextField(controller: emailController, label: 'Email', hint: 'Please enter email'),
                const SizedBox(height: 10),
                _buildTextField(controller: passwordController, label: 'Password', obscureText: true, hint: 'Please enter password'),
                const SizedBox(height: 10),
                _buildTextField(controller: locationController, label: 'Location', hint: 'Please enter location'),
                const SizedBox(height: 20),
                _buildTextField(controller: phoneController, label: 'Phone', hint: 'Please enter phone number'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6A1B9A),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}



class SidePanel extends StatelessWidget {
  final Function(String startDate, String endDate) onDateRangeSelected;

  const SidePanel({Key? key, required this.onDateRangeSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: const Color.fromARGB(255, 233, 218, 239),
      child: Column(
        children: [
         // CalendarWidget(onDateRangeSelected: onDateRangeSelected),
          Expanded(
            child: ListView(
             
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  final Function(String startDate, String endDate) onDateRangeSelected;

  const CalendarWidget({Key? key, required this.onDateRangeSelected}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Date Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: DateTime.now(),
            rangeSelectionMode: RangeSelectionMode.enforced,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_startDate == null || (_endDate != null && selectedDay.isBefore(_startDate!))) {
                  _startDate = selectedDay;
                  _endDate = null;
                } else if (_endDate == null) {
                  _endDate = selectedDay;
                } else {
                  _startDate = selectedDay;
                  _endDate = null;
                }
                widget.onDateRangeSelected(
                  _startDate?.toIso8601String() ?? '',
                  _endDate?.toIso8601String() ?? '',
                );
              });
            },
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text("Selected Range: ${_startDate!.toLocal()} - ${_endDate!.toLocal()}"),
            ),
          ElevatedButton(
            onPressed: () {
              widget.onDateRangeSelected('', ''); // Get all time data
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff613089)),
            child: Text('Get All Time Data'),
          ),
        ],
      ),
    );
  }
}
