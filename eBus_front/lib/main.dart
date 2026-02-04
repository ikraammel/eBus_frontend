import 'package:flutter/material.dart';
import 'package:smart_bus/views/pages/home_page.dart';
import 'package:smart_bus/views/pages/loading/splash_screen.dart';
import 'package:smart_bus/views/pages/login_page.dart';
import 'package:smart_bus/views/pages/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/" : (context) => SplashScreen(),
        "/loginPage": (context) => LoginPage(),
        "/homePage": (context) => HomePage(),
        "/mapPage": (context) => MapPage(),
      },
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
    );
  }
}
