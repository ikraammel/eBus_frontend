import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/bloc/login/login_bloc.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/lines/lines_page.dart';
import 'package:smart_bus/views/loading/splash_screen.dart';
import 'package:smart_bus/views/home/home_page.dart';
import 'package:smart_bus/views/pages/login/login_page.dart';
import 'package:smart_bus/views/pages/lost_objects/lost_objects_page.dart';
import 'package:smart_bus/views/pages/map_page.dart';
import 'package:smart_bus/views/pages/profile/profile_page.dart';
import 'package:smart_bus/views/pages/register/register_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';


final getIt = GetIt.instance;
Future<void> initialDependencies() async{
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<LocalStorageService>(
      LocalStorageService(prefs: getIt<SharedPreferences>())
  );
  getIt.registerSingleton<AuthService>(AuthService());
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initialDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc())
      ],
      child: MaterialApp(
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
          "/lostObjectsPage": (context) => LostObjectsPage(),
          "/ticketsPage": (context) =>  TicketPage(),
          "/linesPage": (context) =>  LinesPage(),
        },
        initialRoute: "/homePage",
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
