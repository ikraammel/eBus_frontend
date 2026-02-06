import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/views/loading/splash_screen.dart';
import 'package:smart_bus/views/pages/home_page.dart';
import 'package:smart_bus/views/pages/login_page.dart';
import 'package:smart_bus/views/pages/map_page.dart';
import 'package:smart_bus/views/pages/profile/profile_page.dart';

  final getIt = GetIt.instance;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
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
        "/profilePage": (context) => ProfilePage(),
      },
      initialRoute: "/homePage",
      debugShowCheckedModeBanner: false,
    );
  }
}
