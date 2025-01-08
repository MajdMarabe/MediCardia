import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageAccountsPage extends StatefulWidget {
  const ManageAccountsPage({Key? key}) : super(key: key);

  @override
  _ManageAccountsPageState createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage> {
  List<Map<String, String>> accounts = [
    {'name': 'Anwar Aqraa', 'email': 'anwaraqraa@gmail.com', 'role': 'Doctor'},
    {'name': 'Majd Marabe', 'email': 'majdMarabe@gmail.com', 'role': 'Patient'},
    {'name': 'Ahmad Yasin', 'email': 'ahmadyasin@gmail.com', 'role': 'Patient'},
  ];

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F5FF),
    appBar: AppBar(
      title: const Text(
        'User Management',
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
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xff6A1B9A),
                        child: Text(
                          account['name']![0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        account['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account['email']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            account['role']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff613089),
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xff6A1B9A),
                        ),
                        onSelected: (value) {
                          if (value == 'Edit') {
                            if (account['role'] == 'Doctor') {
                              _showEditDoctorDialog(context, account);
                            } else {
                              _showEditPatientDialog(context, account);
                            }
                          } else if (value == 'Delete') {
                            setState(() {
                              accounts.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${account['name']} deleted'),
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
        _showAddAccountDialog(context);
      },
      child: const Icon(Icons.add),
    ),
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







void _showEditDoctorDialog(BuildContext context, Map<String, String> account) {
  final TextEditingController fullNameController = TextEditingController(text: account['name']);
  final TextEditingController emailController = TextEditingController(text: account['email']);
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController workplaceNameController = TextEditingController();
  final TextEditingController workplaceAddressController = TextEditingController();

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
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Account updated for ${fullNameController.text}')),
                        );
                      },
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




void _showEditPatientDialog(BuildContext context, Map<String, String> account) {
  final TextEditingController fullNameController = TextEditingController(text: account['name']);
  final TextEditingController emailController = TextEditingController(text: account['email']);
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

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
                _buildTextField(controller: fullNameController, label: 'Full Name',hint: 'Please enter full name'),
                const SizedBox(height: 10),
                _buildTextField(controller: emailController, label: 'Email',hint: 'Please enter email'),
                const SizedBox(height: 10),
                _buildTextField(controller: passwordController, label: 'Password', obscureText: true,hint: 'Please enter password'),
                const SizedBox(height: 10),
                _buildTextField(controller: locationController, label: 'Location',hint: 'Please enter location'),
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
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Patient information updated for ${fullNameController.text}')),
                        );
                      },
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
                            child: Row(
                              children: [
                                Icon(
                                  value == 'Doctor'
                                      ? FontAwesomeIcons.userMd
                                      : Icons.person,
                                  color: const Color(0xff6A1B9A),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff6A1B9A),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (selectedRole == 'Doctor') ...[
                      _buildTextField(controller: fullNameController, label: 'Full Name',hint: 'Please enter full name'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: emailController, label: 'Email', hint: 'Please enter email'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: passwordController, label: 'Password', obscureText: true, hint: 'Please enter password'),
                      const SizedBox(height: 10),
                      _buildTextField(controller: phoneController, label: 'Phone Number', hint: 'Please enter phone number',keyboardType: TextInputType.phone),
                      const SizedBox(height: 10),
                      _buildTextField(controller: specializationController, label: 'Specialization', hint: 'Please enter spacialization'),
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
                            if (selectedRole == 'Doctor') {
                              setState(() {
                                accounts.add({
                                  'name': fullNameController.text.isEmpty ? 'New Doctor' : fullNameController.text,
                                  'email': emailController.text.isEmpty ? 'newdoctor@example.com' : emailController.text,
                                  'role': selectedRole,
                                });
                              });
                            } else {
                              setState(() {
                                accounts.add({
                                  'name': fullNameController.text.isEmpty ? 'New Patient' : fullNameController.text,
                                  'email': emailController.text.isEmpty ? 'newpatient@example.com' : emailController.text,
                                  'role': selectedRole,
                                });
                              });
                            }

                            Navigator.pop(context);  
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Account added as $selectedRole')),
                            );
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


