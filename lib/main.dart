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



/* Wei Sian's Version
import 'package:flutter/material.dart';
import 'promotion_main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Promotion App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFB2626),
        scaffoldBackgroundColor: Color(0xFF000000),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Roboto',
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Roboto',
            fontSize: 14.0,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFB2626),
          titleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFB2626),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 3; // Default index for Home

  final List<Widget> _screens = [
    Placeholder(color: Colors.blue), // Booking Placeholder
    Placeholder(color: Colors.green), // Shopping Placeholder
    Placeholder(color: Colors.orange), // Home Placeholder
    PromotionMainPage(), // The new PromotionMainPage
    Placeholder(color: Colors.purple), // Profile Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFB2626),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('assets/appointment.png', height: 32),
                Text("Booking", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('assets/shopping-cart.png', height: 32),
                Text("Shopping", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('assets/home.png', height: 32),
                Text("Home", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('assets/promo-code.png', height: 32),
                Text("Promotion", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Image.asset('assets/user.png', height: 32),
                Text("Profile", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
*/


//Qing Yee's version
/*
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';
import 'password_reset_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Add this line
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFFB2626),
        scaffoldBackgroundColor: Color(0xFF000000),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/passwordReset': (context) => PasswordResetScreen(resetCode: '',),
      },
    );
  }
}

*/
