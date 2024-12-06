import 'package:flutter/material.dart';
import 'package:utm_courtify/pages/show_available_court.dart'; //Hayden
import 'frontend/sale.dart'; //Eddy
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTM Courtify',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: ShowAvailableCourt(),
      /* Eddy Version
      home: const HomePage(), initialRoute: '/', 
      */
    );
  }
}

// Eddy Version
/*
  class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Shopping selected by default

  // List of pages
  final List<Widget> _pages = [
    const Center(
        child: Text(
      'Booking Page',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    )),
    const SalePage(), // Our sale page
    const Center(
        child: Text(
      'Home Page',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    )),
    const Center(
        child: Text(
      'Promotion Page',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    )),
    const Center(
        child: Text(
      'Profile Page',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    )),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFFFB2626),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('icons/NavigationBar/appointment.png',
                    height: 32), // Increase icon size
              ],
            ),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('icons/NavigationBar/shopping-cart.png',
                    height: 32), // Increase icon size
              ],
            ),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('icons/NavigationBar/home.png',
                    height: 32), // Increase icon size
              ],
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('icons/NavigationBar/promo-code.png',
                    height: 32), // Increase icon size
              ],
            ),
            label: 'Promotion',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('icons/NavigationBar/user.png',
                    height: 32), // Increase icon size
              ],
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
*/

