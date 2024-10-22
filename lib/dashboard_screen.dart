import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_info_screen.dart';
import 'appointments_screen.dart';  // Import the AppointmentsScreen

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // List of widgets for different screens, including AppointmentsScreen
  List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Home Page', style: TextStyle(fontSize: 24, color: Colors.white))),
    AppointmentsScreen(),  // Navigate to the Appointments Screen
    UserInfoScreen(),
    Center(child: Text('Logout', style: TextStyle(fontSize: 24))),
  ];

  // Function to handle logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('bearer_token');  // Remove token from SharedPreferences

    // Navigate to the login screen
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Function to show confirmation dialog
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout();  // Proceed with logout
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      // Show confirmation dialog for logout
      _showLogoutConfirmationDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue.shade800,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,  // Set selected item color to white
        unselectedItemColor: Colors.white60, // Set unselected item color
        onTap: _onItemTapped,
      ),
    );
  }
}
