import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_3/screens/user_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  File? _image;

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
                              builder: (context) => DoctorEditProfilePage()),
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
                    _itemProfile('Log Out', 'Exit your account', Icons.logout),
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






///////////////////////////////////////// Edit Profile Page ///////////////////////////////////////////





class DoctorEditProfilePage extends StatefulWidget {
  @override
  _DoctorEditProfilePageState createState() => _DoctorEditProfilePageState();
}

class _DoctorEditProfilePageState extends State<DoctorEditProfilePage> {
  final _formProfileKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController(text: "Dr. John Smith");
  final _emailController = TextEditingController(text: "johnsmith@example.com");
  final _phoneController = TextEditingController(text: "+1 234 567 8901");
  final _specializationController = TextEditingController(text: "Cardiologist");
  final _licenseNumberController = TextEditingController(text: "LIC12345678");
  final _workplaceNameController = TextEditingController(text: "City Hospital");
  final _workplaceAddressController =
      TextEditingController(text: "123 Main St, Springfield");
  XFile? _imageFile;

  final fullNameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final specializationFocusNode = FocusNode();
  final licenseFocusNode = FocusNode();
  final workplaceNameFocusNode = FocusNode();
  final workplaceAddressFocusNode = FocusNode();

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

///////////////////////////////


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

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _workplaceNameController.dispose();
    _workplaceAddressController.dispose();
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    specializationFocusNode.dispose();
    licenseFocusNode.dispose();
    workplaceNameFocusNode.dispose();
    workplaceAddressFocusNode.dispose();
    super.dispose();
  }
}
