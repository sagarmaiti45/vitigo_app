import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'appointment_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/appointments/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          appointments = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } else {
      print('Token not found');
    }
  }

  // Function to format the date in a human-readable format
  String _formatDate(String dateStr) {
    final DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('MMMM d, yyyy').format(dateTime); // Example: 22 Oct 2024
  }

  // Function to format the time in a human-readable format
  String _formatTime(String timeStr) {
    final DateTime time = DateFormat('HH:mm:ss').parse(timeStr);
    return DateFormat('h:mm a').format(time); // Example: 10:00 AM
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.blue;
      case 'SCHEDULED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Widget buildAppointmentCard(Map appointment) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dr. ${appointment['doctor']['first_name']} ${appointment['doctor']['last_name']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(appointment['status']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey[300], thickness: 1.5, height: 20), // Stylish divider added
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blueAccent),
                SizedBox(width: 10),
                Text(
                  'Date: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_formatDate(appointment['date'])),  // Updated date format
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  'Time: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${_formatTime(appointment['time_slot']['start_time'])} - ${_formatTime(appointment['time_slot']['end_time'])}'),  // Updated time format
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  'Type: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(appointment['appointment_type']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 15,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 15,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? buildShimmerEffect()
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsScreen(
                    appointmentId: appointment['id'],
                  ),
                ),
              );
            },
            child: buildAppointmentCard(appointment),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new appointment functionality
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        tooltip: 'Add New Appointment',
      ),
    );
  }
}
