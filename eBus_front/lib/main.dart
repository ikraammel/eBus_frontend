import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/views/loading/splash_screen.dart';
import 'package:smart_bus/views/pages/home_page.dart';
import 'package:smart_bus/views/pages/login/login_page.dart';
import 'package:smart_bus/views/pages/map_page.dart';
import 'package:smart_bus/views/pages/profile/profile_page.dart';
import 'package:smart_bus/views/pages/register/register_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


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
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        "/" : (context) => SplashScreen(),
        "/loginPage": (context) => LoginPage(),
        "/homePage": (context) => HomePage(),
        "/mapPage": (context) => MapPage(),
        "/profilePage": (context) => ProfilePage(),
        "/registerPage": (context) => RegisterPage(),
      },
      initialRoute: "/loginPage",
      debugShowCheckedModeBanner: false,
    );
  }
}
