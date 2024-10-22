import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PatientInfoScreen extends StatefulWidget {
  @override
  _PatientInfoScreenState createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  Map<String, dynamic>? patientInfo;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPatientInfo();
  }

  Future<void> _fetchPatientInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token == null) {
      setState(() {
        errorMessage = 'Authorization token not found. Please login again.';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/patient-info/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Print the response status and body for debugging
    print('Patient Info Response status: ${response.statusCode}');
    print('Patient Info Response body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        patientInfo = jsonDecode(response.body);
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load patient info. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Info'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100], // Set background color
      body: errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : patientInfo == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Patient Details', Icons.person, Colors.blue, [
              _buildDetailItem('Date of Birth', patientInfo!['patient']['date_of_birth']),
              _buildDetailItem('Gender', patientInfo!['patient']['gender']),
              _buildDetailItem('Blood Group', patientInfo!['patient']['blood_group']),
              _buildDetailItem('Address', patientInfo!['patient']['address']),
              _buildDetailItem('Phone Number', patientInfo!['patient']['phone_number']),
              _buildDetailItem('Emergency Contact', patientInfo!['patient']['emergency_contact_name']),
              _buildDetailItem('Emergency Contact Number', patientInfo!['patient']['emergency_contact_number']),
              _buildDetailItem('Vitiligo Onset Date', patientInfo!['patient']['vitiligo_onset_date']),
              _buildDetailItem('Vitiligo Type', patientInfo!['patient']['vitiligo_type']),
              _buildDetailItem('Affected Body Areas', patientInfo!['patient']['affected_body_areas']),
            ]),
            SizedBox(height: 20), // Space between heading and card
            _buildSection('Medical History', Icons.history, Colors.green, [
              _buildDetailItem('Allergies', patientInfo!['medical_history']['allergies']),
              _buildDetailItem('Chronic Conditions', patientInfo!['medical_history']['chronic_conditions']),
              _buildDetailItem('Past Surgeries', patientInfo!['medical_history']['past_surgeries']),
              _buildDetailItem('Family History', patientInfo!['medical_history']['family_history']),
            ]),
            SizedBox(height: 20), // Space between heading and card
            _buildSection('Medications', Icons.medication, Colors.orange, _buildMedicationsList(patientInfo!['medications'])),
            SizedBox(height: 20), // Space between heading and card
            _buildSection('Vitiligo Assessments', Icons.assessment, Colors.purple, _buildAssessmentsList(patientInfo!['vitiligo_assessments'])),
            SizedBox(height: 20), // Space between heading and card
            _buildSection('Treatment Plans', Icons.local_hospital, Colors.red, _buildTreatmentPlans(patientInfo!['treatment_plans'])),
          ],
        ),
      ),
    );
  }

  // Widget to build section with icon and color
  Widget _buildSection(String title, IconData icon, Color color, List<Widget> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        SizedBox(height: 8), // Space between heading and card
        _buildInfoCard(details, color.withOpacity(0.7)), // Lighter card color
      ],
    );
  }

  // Widget to build key-value detail items
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3, // Key part width
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            flex: 5, // Value part width
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.visible, // Allow text to wrap
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the list of medications with numbering and separator after each entry
  List<Widget> _buildMedicationsList(List<dynamic> medications) {
    return List<Widget>.generate(medications.length, (index) {
      final medication = medications[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubsectionHeading('${index + 1}. ${medication['name']}'), // Numbering and medication name
          _buildDetailItem('Dosage', medication['dosage']),
          _buildDetailItem('Frequency', medication['frequency']),
          _buildDetailItem('Prescribed By', medication['prescribed_by']['full_name']),
          Divider(color: Colors.white, thickness: 1), // Separator after each entry
          SizedBox(height: 10),
        ],
      );
    });
  }

  // Widget to build the list of assessments with numbering and separator after each entry
  List<Widget> _buildAssessmentsList(List<dynamic> assessments) {
    return List<Widget>.generate(assessments.length, (index) {
      final assessment = assessments[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubsectionHeading('${index + 1}. ${assessment['assessment_date']}'), // Numbering and assessment date
          _buildDetailItem('Body Surface Area Affected', assessment['body_surface_area_affected'].toString()),
          _buildDetailItem('VASI Score', assessment['vasi_score'].toString()),
          _buildDetailItem('Treatment Response', assessment['treatment_response']),
          _buildDetailItem('Assessed By', assessment['assessed_by']['full_name']),
          Divider(color: Colors.white, thickness: 1), // Separator after each entry
          SizedBox(height: 10),
        ],
      );
    });
  }

  // Widget to build the list of treatment plans with numbering and separator after each entry
  List<Widget> _buildTreatmentPlans(List<dynamic> treatmentPlans) {
    return List<Widget>.generate(treatmentPlans.length, (index) {
      final plan = treatmentPlans[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubsectionHeading('${index + 1}. ${plan['treatment_goals']}'), // Numbering and treatment goals
          _buildDetailItem('Created Date', plan['created_date']),
          _buildDetailItem('Phototherapy Details', plan['phototherapy_details']),
          _buildDetailItem('Lifestyle Recommendations', plan['lifestyle_recommendations']),
          _buildDetailItem('Follow-up Frequency', plan['follow_up_frequency']),
          Divider(color: Colors.white, thickness: 1), // Separator after each entry
          SizedBox(height: 10),
        ],
      );
    });
  }

  // Widget to create a heading for each subsection
  Widget _buildSubsectionHeading(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }


    // Widget to create a card-like container for information
  Widget _buildInfoCard(List<Widget> children, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardColor, // Card background color based on heading color with 70% opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
