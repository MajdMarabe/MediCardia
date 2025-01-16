import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_3/screens/constants.dart';
import 'package:flutter_application_3/screens/user_profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_3/screens/welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  File? _image;

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

  Future<void> _logOut() async {
    try {
      await storage.deleteAll();
      print('Storage cleared successfully.');
      await FirebaseMessaging.instance.deleteToken();

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

///////////////////////////

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
              child: ScrollConfiguration(
                behavior: kIsWeb
                    ? TransparentScrollbarBehavior()
                    : const ScrollBehavior(),
                child: SingleChildScrollView(
                  physics: kIsWeb
                      ? const AlwaysScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/appLogo.png',
                            height: 90,
                            color: const Color(0xff613089),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'MediCardia',
                            style: TextStyle(
                              fontSize: 35.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BAUHS93',
                              color: Color(0xff613089),
                            ),
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
                              builder: (context) => DoctorEditProfilePage(),
                            ),
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
                              builder: (context) => NotificationSettingsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _itemProfile(
                        'Change Password',
                        'Change your password',
                        CupertinoIcons.lock,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePasswordPage(),
                            ),
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
                              builder: (context) => AboutUsPage(),
                            ),
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
                              builder: (context) => InformationPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _itemProfile(
                        'Log Out',
                        'Exit your account',
                        Icons.logout,
                        onTap: _logOut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

///////////////////////////////////////// Edit Profile Page ///////////////////////////////////////////

class DoctorEditProfilePage extends StatefulWidget {
  @override
  _DoctorEditProfilePageState createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends State<DoctorEditProfilePage> {
  final _formProfileKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _workplaceNameController = TextEditingController();
  final _workplaceAddressController = TextEditingController();
  final _aboutController = TextEditingController();

  String? base64Image = '';

  // Add focus nodes for all fields
  final fullNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final specializationFocusNode = FocusNode();
  final licenseFocusNode = FocusNode();
  final workplaceNameFocusNode = FocusNode();
  final workplaceAddressFocusNode = FocusNode();
  final aboutFocusNode = FocusNode();
  String? doctorid;

  @override
  void initState() {
    super.initState();
    //_loadDoctorId();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorId() async {
    doctorid = await storage.read(key: 'userid');
  }

  Future<void> _loadDoctorProfile() async {
    doctorid = await storage.read(key: 'userid');

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/doctors/profile/$doctorid'),
      headers: {
        'Content-Type': 'application/json',
        //'token': token ??'',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final doctor = data['doctor'];

      setState(() {
        _fullNameController.text = doctor['fullName'] ?? '';
        _emailController.text = doctor['email'] ?? '';
        _passwordController.text = '';
        _phoneController.text = doctor['phone'] ?? '';
        _specializationController.text = doctor['specialization'] ?? '';
        _licenseNumberController.text = doctor['licenseNumber'] ?? '';
        _workplaceNameController.text = doctor['workplace']['name'] ?? '';
        _workplaceAddressController.text = doctor['workplace']['address'] ?? '';
        _aboutController.text = doctor['about'] ?? '';
        base64Image = doctor['image'] ?? '';
      });
    } else {
      print('Failed to load doctor profile: ${response.statusCode}');
    }
  }

  Image buildImageFromBase64(String? base64Image) {
    try {
      if (base64Image == null || base64Image.isEmpty) {
        return Image.asset('assets/images/default_person.jpg');
      }

      final bytes = base64Decode(base64Image);
      print("Decoded bytes length: ${bytes.length}");

      return Image.memory(bytes);
    } catch (e) {
      print("Error decoding image: $e");
      return Image.asset('assets/images/default_person.jpg');
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      setState(() {});

      final bytes = await pickedFile.readAsBytes();
      base64Image = base64Encode(bytes);
    }
  }

  Widget _buildUserAvatar() {
    ImageProvider backgroundImage;
    try {
      backgroundImage = buildImageFromBase64(base64Image).image;
    } catch (e) {
      backgroundImage = const AssetImage('assets/images/default_person.jpg');
    }

    return GestureDetector(
      onTap: _selectImage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            backgroundImage: backgroundImage,
          ),
          Positioned(
            bottom: -5,
            right: -5,
            child: GestureDetector(
              onTap: _selectImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  color: Color(0xff613089),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            validator: validator ??
                (value) => value == null || value.isEmpty
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

  void _saveProfile() async {
    if (_formProfileKey.currentState!.validate()) {
      final String fullName = _fullNameController.text;
      final String email = _emailController.text;
      final String phone = _phoneController.text;
      final String specialization = _specializationController.text;
      final String licenseNumber = _licenseNumberController.text;
      final String workplaceName = _workplaceNameController.text;
      final String workplaceAddress = _workplaceAddressController.text;
      final String about = _aboutController.text;

      final Map<String, dynamic> requestData = {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'specialization': specialization,
        'licenseNumber': licenseNumber,
        'workplaceName': workplaceName,
        'workplaceAddress': workplaceAddress,
        'about': about,
        'image': base64Image,
      };

      try {
        doctorid = await storage.read(key: 'userid');
        final response = await http.put(
          Uri.parse('${ApiConstants.baseUrl}/doctors/update/$doctorid'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
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
              content:
                  Text(responseData['message'] ?? 'Error updating profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        print('Error updating profile: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error updating profile. Please try again later."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildAboutField({
    required TextEditingController controller,
    required FocusNode focusNode,
    String label = "About",
    int maxLines = 4,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.multiline,
            maxLines: maxLines,
            validator: validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide some information about yourself';
                  }
                  return null;
                },
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xff613089)),
              hintText: 'Write a brief description about yourself',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              prefixIcon: const Icon(Icons.info, color: Color(0xff613089)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F5FF),
        title: const Text(
          "Doctor Profile",
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

          return ScrollConfiguration(
            behavior: kIsWeb
                ? TransparentScrollbarBehavior()
                : const ScrollBehavior(),
            child: Center(
              child: Container(
                width: pageWidth,
                padding: const EdgeInsets.all(17.0),
                child: SingleChildScrollView(
                  // إضافة SingleChildScrollView لتمكين التمرير
                  child: Column(
                    children: [
                      // توسيط الصورة الشخصية في المنتصف
                      Center(child: _buildUserAvatar()),

                      const SizedBox(height: 20),
                      Form(
                        key: _formProfileKey,
                        child: Column(
                          children: [
                            _buildEditableField(
                              controller: _fullNameController,
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
                              controller: _phoneController,
                              label: "Phone",
                              icon: Icons.phone,
                              focusNode: phoneFocusNode,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 15),
                            _buildEditableField(
                              controller: _specializationController,
                              label: "Specialization",
                              icon: Icons.work,
                              focusNode: specializationFocusNode,
                            ),
                            const SizedBox(height: 15),
                            _buildEditableField(
                              controller: _licenseNumberController,
                              label: "License Number",
                              icon: Icons.badge,
                              focusNode: licenseFocusNode,
                            ),
                            const SizedBox(height: 15),
                            _buildEditableField(
                              controller: _workplaceNameController,
                              label: "Workplace Name",
                              icon: Icons.business,
                              focusNode: workplaceNameFocusNode,
                            ),
                            const SizedBox(height: 15),
                            _buildEditableField(
                              controller: _workplaceAddressController,
                              label: "Workplace Address",
                              icon: Icons.location_on,
                              focusNode: workplaceAddressFocusNode,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildAboutField(
                        controller: _aboutController,
                        focusNode: aboutFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide some information about yourself';
                          }
                          return null;
                        },
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
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _changePassword() async {
    final String? token = await storage.read(key: 'token');

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String oldPassword = _oldPasswordController.text;
      final String newPassword = _newPasswordController.text;
      final String confirmPassword = _confirmPasswordController.text;

      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("New passwords do not match!"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final url =
            Uri.parse('${ApiConstants.baseUrl}/doctors/change-password');

        final headers = {
          'Content-Type': 'application/json',
          'token': token ?? '',
        };

        final body = jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        });

        final response = await http.put(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          Navigator.pop(context);
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(responseData['message'] ?? 'Error changing password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("\n$e\n\n\n");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double pageWidth =
            constraints.maxWidth > 600 ? 600 : constraints.maxWidth;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F5FF),
          appBar: kIsWeb
              ? AppBar(
                  backgroundColor: const Color(0xFFF2F5FF),
                  elevation: 0,
                  centerTitle: true,
                  title: const Text(
                    'Update Password',
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
                    'Update Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff613089),
                      letterSpacing: 1.5,
                    ),
                  ),
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF613089)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: pageWidth),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildPasswordField(
                              controller: _oldPasswordController,
                              label: "Old Password",
                              icon: Icons.lock,
                            ),
                            const SizedBox(height: 15),
                            _buildPasswordField(
                              controller: _newPasswordController,
                              label: "New Password",
                              icon: Icons.lock_outline,
                            ),
                            const SizedBox(height: 15),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: "Confirm New Password",
                              icon: Icons.lock_outline,
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
                                onPressed: _changePassword,
                                child: const Text(
                                  'Change Password',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label cannot be empty';
        }
        if (value.length < 6) {
          return '$label must be at least 6 characters long';
        }
        return null;
      },
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
    );
  }
}

////////////////////////////////////////////

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  //bool remindersEnabled = true;
  bool messagesEnabled = true;
  bool requestsEnabled = true;

  final storage = const FlutterSecureStorage();

  // Method to fetch settings from the backend API
  Future<void> fetchSettings() async {
    final userId = await storage.read(key: 'userid');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/doctors/$userId/setting'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          // remindersEnabled = data['reminders'] ?? true;
          messagesEnabled = data['messages'] ?? true;
          requestsEnabled = data['requests'] ?? true;
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
        Uri.parse('${ApiConstants.baseUrl}/doctors/$userId/setsetting'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          //'reminderNotifications': remindersEnabled,
          'messageNotifications': messagesEnabled,
          'requestNotifications': requestsEnabled,
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

///////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F5FF),
        title: const Text(
          'Notification Settings',
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
              constraints.maxWidth > 600 ? 900 : double.infinity;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: pageWidth,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /*_buildNotificationCard(
              icon: Icons.notifications_active,
              title: 'إشعارات التذكيرات',
              description: 'تحكم بإشعارات التذكيرات اليومية.',
              value: remindersEnabled,
              onChanged: (value) {
                setState(() {
                  remindersEnabled = value;
                });
                updateSettings(); // Update the settings when the user changes it
              },
            ),*/
                    _buildNotificationCard(
                      leadingWidget: const Icon(
                        Icons.message,
                        size: 40,
                        color: Color(0xff613089),
                      ),
                      title: 'Messages',
                      description:
                          'Enable or disable notifications for messages',
                      value: messagesEnabled,
                      onChanged: (value) {
                        setState(() {
                          messagesEnabled = value;
                        });
                        updateSettings();
                      },
                    ),
                    _buildNotificationCard(
                      leadingWidget: Image.asset(
                        'assets/images/permission_request.png',
                        width: 45,
                        height: 50,
                        color: const Color(0xff613089),
                      ),
                      title: 'Permission requests',
                      description:
                          'Enable or disable notifications for permission requests',
                      value: requestsEnabled,
                      onChanged: (value) {
                        setState(() {
                          requestsEnabled = value;
                        });
                        updateSettings();
                      },
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

  Widget _buildNotificationCard({
    required Widget leadingWidget,
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            leadingWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
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
              activeColor: const Color(0xff613089),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////

class TransparentScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const AlwaysScrollableScrollPhysics();
  }
}
