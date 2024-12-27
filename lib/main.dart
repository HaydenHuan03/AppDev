import 'package:flutter/material.dart';
import 'package:utm_courtify/pages/user/login_screen.dart';
import 'package:utm_courtify/pages/promotion/promotion_main_page.dart';
import 'package:utm_courtify/pages/shopping/shopping.dart';
import 'package:utm_courtify/pages/booking/show_available_court.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/home_screen.dart';
import 'pages/user/password_reset_screen.dart';
import 'pages/user/profile_screen.dart';
import 'pages/user/register_screen.dart';

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

      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/shopping': (context) => SalePage(),
        '/profile': (context) => ProfileScreen(),
        '/promotion' : (context) => PromotionMainPage(),
        '/passwordReset': (context) => PasswordResetScreen(resetCode: '',),
        '/booking': (context) => ShowAvailableCourt(),
      },

    );
  }
}

