import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  Future<void> fetchPatientDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token'); // Retrieve the token

      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/patient-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          patientData = data['patient'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load patient details');
      }
    } catch (e) {
      print('Error fetching patient details: $e');
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String capitalize(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        foregroundColor: Colors.white, // Text color changed to white
        backgroundColor: Colors.blue, // AppBar color changed to blue
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Teal changed to blue
                  ),
                ),
                const Divider(thickness: 1.5),
                ..._buildPatientInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPatientInfo() {
    final List<IconData> icons = [
      Icons.cake, // Date of birth
      Icons.female, // Gender
      Icons.bloodtype, // Blood group
      Icons.home, // Address
      Icons.phone, // Phone number
      Icons.person_outline, // Emergency contact name
      Icons.phone_forwarded, // Emergency contact number
      Icons.calendar_today, // Vitiligo onset date
      Icons.info_outline, // Vitiligo type
      Icons.area_chart, // Affected body areas
    ];

    final fields = [
      'date_of_birth',
      'gender',
      'blood_group',
      'address',
      'phone_number',
      'emergency_contact_name',
      'emergency_contact_number',
      'vitiligo_onset_date',
      'vitiligo_type',
      'affected_body_areas',
    ];

    return List.generate(fields.length, (index) {
      String key = fields[index];
      String value = patientData![key]?.toString() ?? 'N/A';

      // Format date fields to human-readable format
      if (key.contains('date')) {
        value = formatDate(value);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icons[index], color: Colors.blue, size: 24), // Icon color changed to blue
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalize(key.replaceAll('_', ' ')), // Capitalize the key with spaces
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
