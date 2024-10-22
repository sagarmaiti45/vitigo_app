import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoUpdateScreen extends StatefulWidget {
  final Function onUpdate; // Callback function for refreshing user info

  UserInfoUpdateScreen({required this.onUpdate}); // Constructor

  @override
  _UserInfoUpdateScreenState createState() => _UserInfoUpdateScreenState();
}

class _UserInfoUpdateScreenState extends State<UserInfoUpdateScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // Fetch current user info on initialization
  }

  Future<void> _fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/user-info/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userInfo = jsonDecode(response.body);
      // Populate the controllers with fetched data
      _firstNameController.text = userInfo['user']['first_name'] ?? '';
      _lastNameController.text = userInfo['user']['last_name'] ?? '';
      _emailController.text = userInfo['user']['email'] ?? '';
    } else {
      print('Failed to fetch user info: ${response.body}');
    }
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token == null) {
      setState(() {
        errorMessage = 'Authorization token not found. Please login again.';
      });
      return;
    }

    // Prepare the update request body
    final Map<String, dynamic> updateData = {};
    if (_firstNameController.text.isNotEmpty) {
      updateData['first_name'] = _firstNameController.text;
    }
    if (_lastNameController.text.isNotEmpty) {
      updateData['last_name'] = _lastNameController.text;
    }
    if (_emailController.text.isNotEmpty) {
      updateData['email'] = _emailController.text; // Include email if provided
    }
    if (_passwordController.text.isNotEmpty) {
      updateData['password'] = _passwordController.text; // Only include if provided
    }

    // Print the update data for debugging
    print('Update data: $updateData');

    setState(() {
      _isLoading = true; // Start loading
    });

    final response = await http.put(
      Uri.parse('https://vitigo.learnknowdigital.com/api/basic-user-info/update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updateData), // Use the constructed update data
    );

    // Print the response status and body for debugging
    print('Profile Update Response status: ${response.statusCode}');
    print('Profile Update Response body: ${response.body}');

    setState(() {
      _isLoading = false; // Stop loading
    });

    if (response.statusCode == 200) {
      // Notify the UserInfoScreen to refresh
      widget.onUpdate(); // Call the passed function to refresh user info
      _showSnackbar('Profile updated successfully!', Colors.green); // Show success message
      Navigator.pop(context); // Go back to the UserInfoScreen
    } else {
      _showSnackbar('Failed to update the profile. Please try again.', Colors.red); // Show failure message
    }
  }

  void _showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(errorMessage, style: TextStyle(color: Colors.red)),
                ),
              _buildTextField(_firstNameController, 'First Name', Icons.person),
              _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
              _buildTextField(_emailController, 'Email', Icons.email),
              _buildTextField(_passwordController, 'New Password', Icons.lock, obscureText: true),
              SizedBox(height: 20),
              Center( // Center the button
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile, // Disable button if loading
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white) // Show loading indicator
                      : Text('Update', style: TextStyle(fontSize: 16, color: Colors.white)), // Increased font size
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set background color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Increased padding for a bigger button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildGuidelinesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners for text fields
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildGuidelinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Update Guidelines:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 10),
        _buildBulletPoint('Make sure to enter your correct first and last name.'),
        _buildBulletPoint('Use a valid email address to ensure you receive notifications.'),
        _buildBulletPoint('You can update your password if needed.'),
        _buildBulletPoint('All fields are optional; however, it\'s recommended to provide as much information as possible.'),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.blueAccent), // Bullet point icon
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
