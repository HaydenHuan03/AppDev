import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking History")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Court 1 - 31/12/2024"),
            subtitle: Text("Status: Upcoming"),
          ),
          ListTile(
            title: Text("Court 1 - 1/12/2025"),
            subtitle: Text("Status: Upcoming"),
          ),
          // Add more entries as needed
        ],
      ),
    );
  }
}
