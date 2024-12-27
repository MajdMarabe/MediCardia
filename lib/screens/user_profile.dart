import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_3/screens/welcome_screen.dart';
import 'constants.dart';

import 'package:http/http.dart' as http;
const storage = FlutterSecureStorage();


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;

  // Function to handle log out
  Future<void> _logOut() async {
    // Add your logout logic here (e.g., clearing user session, etc.)
    try {
      await storage.deleteAll(); // Clears all stored keys and values
      print('Storage cleared successfully.');
      await FirebaseMessaging.instance.deleteToken();

      // Navigate the user back to the welcome or login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } catch (e) {
      print('Error clearing storage: $e');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully!")),
    );
  }


  // Widget to create profile items
  Widget _itemProfile(String title, String subtitle, IconData iconData,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: const Color(0xff613089).withOpacity(.2),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          leading: Icon(iconData, color: const Color(0xff613089)),
          trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        ),
      ),
    );
  }




  //////////////////////////////////////////


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double maxWidth = screenWidth > 600 ? 1000 : double.infinity;
        return Scaffold(
          backgroundColor: const Color(0xFFF2F5FF),
          body: Center(
            child: SizedBox(
              width: maxWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? const Icon(Icons.person,
                                  size: 70, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _itemProfile(
                      'Edit Profile',
                      'Update your profile information',
                      Icons.edit,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()),
                        );
                      },
                    ),
                                        const SizedBox(height: 10),

                                _itemProfile(
                      'Settings',
                      'Go to set Settings',
                      CupertinoIcons.settings,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationSettingsPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _itemProfile(
                      'About Us',
                      'Learn more about us',
                      CupertinoIcons.info,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutUsPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _itemProfile(
                      'Information',
                      'Get more information',
                      CupertinoIcons.news,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InformationPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _itemProfile('Log Out', 'Exit your account', Icons.logout,
                        onTap: _logOut),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}





//////////////////////////// Edit Profile Page ///////////////////////////



class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: "John Smith");
  final TextEditingController _emailController = TextEditingController(text: "JohSmith@gmail.com");
  final TextEditingController _passwordController = TextEditingController(text: "123456");
  final TextEditingController _locationController = TextEditingController(text: "Kanada");

  final _formProfileKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  XFile? _imageFile;

  final fullNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final locationFocusNode = FocusNode();


  Future<String?> encodeImageToBase64(XFile? imageFile) async {
    if (imageFile == null) return null;

    try {
      // Use XFile's bytes property to get the file's data as Uint8List
      final Uint8List bytes = await imageFile.readAsBytes();

      // Return the Base64-encoded string
      return base64Encode(bytes);
    } catch (e) {
      print('Error encoding image to Base64: $e');
      return null;
    }
  }


  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }



/////////////////////////////////////////////////



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F5FF),
        title: const Text(
          "Patient Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff613089),
            letterSpacing: 1.5,
          ),
        ),
        automaticallyImplyLeading: false,
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
              constraints.maxWidth > 600 ? 600 : double.infinity;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: pageWidth,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selectImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            child: _imageFile != null
                                ? kIsWeb
                                    ? ClipOval(
                                        child: Image.network(
                                          _imageFile!.path,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipOval(
                                        child: Image.file(
                                          File(_imageFile!.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                : const SizedBox.shrink(),
                          ),
                          if (_imageFile == null) ...[
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage(
                                      'assets/images/default_person.jpg'),
                                  backgroundColor: Colors.grey,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _selectImage,
                                    child: const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Color(0xff613089),
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formProfileKey,
                      child: Column(
                        children: [
                          _buildEditableField(
                            controller: _nameController,
                            label: "Full Name",
                            icon: Icons.person,
                            focusNode: fullNameFocusNode,
                          ),
                          const SizedBox(height: 15),
                          _buildEditableField(
                            controller: _emailController,
                            label: "Email",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            focusNode: emailFocusNode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildEditableField(
                            controller: _locationController,
                            label: "Location",
                            icon: Icons.phone,
                            focusNode: locationFocusNode,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),
            
                          _buildPasswordField(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff613089),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _saveProfile,
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(color: Colors.white),
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



 Widget _buildPasswordField() {
  return Row(
    children: [
      Expanded(
        child: TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          focusNode: passwordFocusNode,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password cannot be empty';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: const TextStyle(color: Color(0xff613089)),
            hintText: 'Enter Password',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            prefixIcon: const Icon(Icons.lock, color: Color(0xff613089)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xffb41391),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xff613089),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      IconButton(
        icon: const Icon(Icons.edit, color: Color(0xff613089)),
        onPressed: () {
          setState(() {
            _passwordController.clear();
            passwordFocusNode.requestFocus();
          });
        },
      ),
    ],
  );
}


  void _saveProfile() {
    if (_formProfileKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            validator: validator ?? (value) => value == null || value.isEmpty
                ? 'Please enter $label'
                : null,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xff613089)),
              hintText: 'Enter $label',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              prefixIcon: Icon(icon, color: const Color(0xff613089)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xffb41391),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xff613089)),
          onPressed: () {
            setState(() {
              controller.clear();
              focusNode.requestFocus();
            });
          },
        ),
      ],
    );
  }
}



////////////////////////////////////////////////////////////


class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: const Center(child: Text('About Us Content')),
    );
  }
}




///////////////////////////////////////////////



class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Information')),
      body: const Center(child: Text('Information Content')),
    );
  }
}

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool remindersEnabled = true;
  bool messagesEnabled = true;
  bool requestsEnabled = true;
  bool donationEnabled = true;

  final storage = FlutterSecureStorage(); // For storing the user ID

  // Method to fetch settings from the backend API
  Future<void> fetchSettings() async {
    final userId = await storage.read(key: 'userid');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/setting'), // Replace with your API URL and user ID
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          remindersEnabled = data['reminders'] ?? true;
          messagesEnabled = data['messages'] ?? true;
          requestsEnabled = data['requests'] ?? true;
          donationEnabled =  data['donation'] ?? true;
        });
      } else {
        print('Failed to load settings');
      }
    } catch (e) {
      print('Error fetching settings: $e');
    }
  }

  // Method to save the updated settings to the backend
  Future<void> updateSettings() async {
    final userId = await storage.read(key: 'userid');
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/setsetting'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'reminderNotifications': remindersEnabled,
          'messageNotifications': messagesEnabled,
          'requestNotifications': requestsEnabled,
           'donationNotifications': donationEnabled,

        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Settings updated successfully: ${data['notificationSettings']}');
        // Optionally show a success message to the user
      } else {
        print('Failed to update settings');
      }
    } catch (e) {
      print('Error updating settings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSettings(); // Fetch the settings when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification settings'),
        backgroundColor: Color(0xff613089),
        elevation: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 194, 120, 211).withOpacity(0.2),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNotificationCard(
              icon: Icons.notifications_active,
              title: 'reminders ',
              description: 'Enable or disable notifications for reminders',
              value: remindersEnabled,
              onChanged: (value) {
                setState(() {
                  remindersEnabled = value;
                });
                updateSettings(); // Update the settings when the user changes it
              },
            ),
            _buildNotificationCard(
              icon: Icons.message,
              title: 'Messages',
              description: 'Enable or disable notifications for Messages ',
              value: messagesEnabled,
              onChanged: (value) {
                setState(() {
                  messagesEnabled = value;
                });
                updateSettings(); // Update the settings when the user changes it
              },
            ),
            _buildNotificationCard(
              icon: Icons.assignment_turned_in,
              title: 'permission requests',
              description: 'Enable or disable notifications for permission requests',
              value: requestsEnabled,
              onChanged: (value) {
                setState(() {
                  requestsEnabled = value;
                });
                updateSettings(); // Update the settings when the user changes it
              },
            ),
             _buildNotificationCard(
              icon: Icons.assignment_turned_in,
              title: 'blood donation requests ',
              description: 'Enable or disable notifications for blood donation requests',
              value: donationEnabled,
              onChanged: (value) {
                setState(() {
                  donationEnabled = value;
                });
                updateSettings(); // Update the settings when the user changes it
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Color.fromARGB(255, 109, 8, 137),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Color.fromARGB(255, 137, 19, 180),
            ),
          ],
        ),
      ),
    );
  }
}