import 'package:flutter/material.dart';
import 'package:utm_courtify/pages/user/profile_screen.dart';
import 'package:utm_courtify/pages/booking/show_available_court.dart';
import 'package:utm_courtify/widgets/navigation_bar.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Start with Home selected (index 2)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to UTM-Courtify!", 
              style: TextStyle(fontSize: 24, color: Colors.white)
            ),
            SizedBox(height: 20),
            Text(
              "Navigate to different subsystems", 
              style: TextStyle(color: Colors.white)
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        initialIndex: _currentIndex,
      ),
    );
  }
}