import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_info_update_screen.dart';
import 'patient_info_screen.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String role = '';
  String tierName = '';
  String startDate = '';
  String endDate = '';
  String gender = '';
  String errorMessage = '';
  bool isLoading = true; // Track loading state

  // Patient data
  String dob = '';
  String genderPrefix = '';
  String bloodGroup = '';
  String address = '';
  String phoneNumber = '';
  String emergencyContactName = '';
  String emergencyContactNumber = '';
  String vitiligoOnsetDate = '';
  String vitiligoType = '';
  String affectedBodyAreas = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token == null) {
      setState(() {
        errorMessage = 'Authorization token not found. Please login again.';
        isLoading = false; // Stop loading
      });
      return;
    }

    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/user-info/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userInfo = jsonDecode(response.body);
      setState(() {
        // User Information
        firstName = userInfo['user']['first_name'] ?? '';
        lastName = userInfo['user']['last_name'] ?? '';
        email = userInfo['user']['email'] ?? '';
        role = userInfo['user']['role'] ?? '';
        gender = userInfo['patient']['gender'] ?? '';
        tierName = userInfo['subscription']['tier_name'] ?? '';
        startDate = _formatDate(userInfo['subscription']['start_date']);
        endDate = _formatDate(userInfo['subscription']['end_date']);

        // Patient Information
        dob = _formatDate(userInfo['patient']['date_of_birth']);
        genderPrefix = gender == 'F' ? 'Mrs.' : 'Mr.';
        bloodGroup = userInfo['patient']['blood_group'] ?? '';
        address = userInfo['patient']['address'] ?? '';
        phoneNumber = userInfo['patient']['phone_number'] ?? '';
        emergencyContactName = userInfo['patient']['emergency_contact_name'] ?? '';
        emergencyContactNumber = userInfo['patient']['emergency_contact_number'] ?? '';
        vitiligoOnsetDate = _formatDate(userInfo['patient']['vitiligo_onset_date']);
        vitiligoType = userInfo['patient']['vitiligo_type'] ?? '';
        affectedBodyAreas = userInfo['patient']['affected_body_areas'] ?? '';
        isLoading = false; // Stop loading
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load user info. Please try again.';
        isLoading = false; // Stop loading
      });
    }
  }

  // Function to format the date
  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(), // Updated welcome section
            SizedBox(height: 20),
            _buildUserInfoCard(
              'Personal Information',
              [
                _buildInfoRow(Icons.person, 'First Name:', firstName),
                _buildInfoRow(Icons.person_outline, 'Last Name:', lastName),
                _buildInfoRow(Icons.email, 'Email:', email),
                _buildInfoRow(Icons.assignment_ind, 'Role:', role), // Displaying role value
              ],
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserInfoUpdateScreen(
                        onUpdate: _fetchUserInfo,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            _buildUserInfoCard(
              'Patient Information',
              [
                _buildInfoRow(Icons.cake, 'Date of Birth:', dob),
                _buildInfoRow(Icons.bloodtype, 'Blood Group:', bloodGroup),
                _buildInfoRow(Icons.location_on, 'Address:', address),
                _buildInfoRow(Icons.phone, 'Phone Number:', phoneNumber),
                _buildInfoRow(Icons.contact_phone, 'Emergency Contact:', '$emergencyContactName ($emergencyContactNumber)'),
                _buildInfoRow(Icons.access_time, 'Vitiligo Onset Date:', vitiligoOnsetDate),
                _buildInfoRow(Icons.medical_services, 'Vitiligo Type:', vitiligoType),
                _buildInfoRow(Icons.map, 'Affected Areas:', affectedBodyAreas),
              ],
              IconButton(
                icon: Icon(Icons.arrow_forward, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientInfoScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            _buildUserInfoCard(
              'Subscription Info',
              [
                _buildInfoRow(Icons.star, 'Tier Name:', tierName),
                _buildInfoRow(Icons.calendar_today, 'Start Date:', startDate),
                _buildInfoRow(Icons.calendar_today_outlined, 'End Date:', endDate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // New welcome section
  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/dummy_profile_pic.png'), // Dummy profile picture
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$genderPrefix $firstName $lastName',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis, // Avoid overflow
                ),
                SizedBox(height: 8),
                Text(
                  role, // Only show the value of role
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis, // Avoid overflow
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(String title, List<Widget> infoRows, [Widget? trailing]) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (trailing != null) trailing,
              ],
            ),
            Divider(color: Colors.grey[300], thickness: 1.5, height: 20),
            SizedBox(height: 10),
            ...infoRows,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                isLoading // Show shimmer effect for loading state
                    ? _buildShimmer() // Show shimmer effect when loading
                    : Text(value.isNotEmpty ? value : 'Not available', style: TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 16.0,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}
