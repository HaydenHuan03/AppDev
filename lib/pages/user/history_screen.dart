import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking History")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Badminton Court - 12/10/2024"),
            subtitle: Text("Status: Completed"),
          ),
          ListTile(
            title: Text("Tennis Court - 10/11/2024"),
            subtitle: Text("Status: Cancelled"),
          ),
          // Add more entries as needed
        ],
      ),
    );
  }
}
