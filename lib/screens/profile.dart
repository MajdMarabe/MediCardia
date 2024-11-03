import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image; // Variable to hold the selected image

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update the state with the selected image
      });
    }
  }

  // Function to handle log out
  void _logOut() {
    // Add your logout logic here (e.g., clearing user session, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logged out successfully!")),
    );
  }

  // Widget to create profile items
  Widget _itemProfile(String title, String subtitle, IconData iconData, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: Color(0xff613089).withOpacity(.2),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          leading: Icon(iconData, color: Color(0xff613089)),
          trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        ),
      ),
    );
  }

Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
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
                backgroundImage: _image != null
                    ? FileImage(_image!) // Use selected image if available
                    : null,
                child: _image == null
                    ? const Icon(Icons.person, size: 70, color: Colors.white) // Placeholder icon if no image
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 30),
            // Edit Profile Button Styled as a Profile Item
            _itemProfile('Edit Profile', 'Update your profile information', Icons.edit, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            }),
            const SizedBox(height: 10),
            _itemProfile('About Us', 'Learn more about us', CupertinoIcons.info, onTap: () {
              // Navigate to About Us page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              );
            }),
            const SizedBox(height: 10),
            _itemProfile('Information', 'Get more information', CupertinoIcons.news, onTap: () {
              // Navigate to Information page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InformationPage()),
              );
            }),
            const SizedBox(height: 10),
            _itemProfile('Log Out', 'Exit your account', Icons.logout, onTap: _logOut),
          ],
        ),
      ),
    );
  }
}



class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formEditKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _obscureText = true; // To manage password visibility
  File? _image; // Variable to hold the selected image

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update the state with the selected image
      });
    }
  }

  // Toggle visibility for password field
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'), 
        backgroundColor: const Color(0xff613089), // Set the same color as SignInScreen
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formEditKey,
          child: Column(
            children: [
         
              const SizedBox(height: 20),

              // Profile image with edit option
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage, // Allow user to tap on the image to edit
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null
                          ? FileImage(_image!) // Use selected image if available
                          : null,
                      child: _image == null // Show edit icon if no image is selected
                          ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage, // Allow user to tap on the edit icon to change the photo
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0xff613089), // Change color to your preference
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit, // Edit icon
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: const TextStyle(color: Color(0xff613089)), // Matching color
                  hintText: 'Edit your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(CupertinoIcons.person, color: Color(0xff613089)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  hintText: 'Edit your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(CupertinoIcons.mail, color: Color(0xff613089)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                obscuringCharacter: '•',
                decoration: InputDecoration(
                  labelText: 'Your Password',
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  hintText: 'Edit your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(CupertinoIcons.lock, color: Color(0xff613089)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xff613089),
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Your Location',
                  labelStyle: const TextStyle(color: Color(0xff613089)),
                  hintText: 'Edit your location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(CupertinoIcons.location, color: Color(0xff613089)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xffb41391), width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formEditKey.currentState!.validate()) {
                      // Logic to save profile changes
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully!')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    backgroundColor: const Color(0xff613089), // Button color
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder pages for navigation (implement these in your project)
class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: Center(child: Text('About Us Content')),
    );
  }
}

class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Information')),
      body: Center(child: Text('Information Content')),
    );
  }
}
