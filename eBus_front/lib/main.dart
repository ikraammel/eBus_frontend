import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:smart_bus/views/pages/home_page.dart';
import 'package:smart_bus/views/pages/loading/splash_screen.dart';
import 'package:smart_bus/views/pages/login_page.dart';
import 'package:smart_bus/views/pages/map_page.dart';
=======
import 'package:smart_bus/views/pages/login_page.dart';
>>>>>>> 800a0802795f4d344de8d35ca93efbc9cb54ae05

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      routes: {
        "/" : (context) => SplashScreen(),
        "/loginPage": (context) => LoginPage(),
        "/homePage": (context) => HomePage(),
        "/mapPage": (context) => MapPage(),

      },
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
=======
      debugShowCheckedModeBanner: false,
      home:LoginPage(),
>>>>>>> 800a0802795f4d344de8d35ca93efbc9cb54ae05
    );
  }
}

