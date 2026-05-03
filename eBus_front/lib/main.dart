import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Blocs
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/bloc/bus/bus_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_event.dart'; // Import ajouté
import 'package:smart_bus/bloc/claims/claims_bloc.dart';
import 'package:smart_bus/bloc/claims/claims_event.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';

// Services
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/bus_service.dart';
import 'package:smart_bus/services/ligne_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/services/reclamation_service.dart';

// Views
import 'package:smart_bus/views/UI/splash_screen.dart';
import 'package:smart_bus/views/pages/admin/admin_home_page/admin_home_page.dart';
import 'package:smart_bus/views/pages/claims/claims_page.dart';
import 'package:smart_bus/views/pages/home/home_page.dart';
import 'package:smart_bus/views/pages/login/login_page.dart';
import 'package:smart_bus/views/pages/login/forgot_password/reset_success.dart';
import 'package:smart_bus/views/pages/map_page.dart';
import 'package:smart_bus/views/pages/profile/profile_page.dart';
import 'package:smart_bus/views/pages/register/register_page.dart';
import 'package:smart_bus/views/pages/lines/lines_page.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/views/pages/lost_objects/lost_objects_page.dart';
import 'package:smart_bus/views/pages/lost_objects/declare_lost_object_page.dart';
import 'package:smart_bus/views/pages/lost_objects/user_objet_detail_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_objet_perdu/admin_list_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_objet_perdu/admin_objet_detail_page.dart';

final getIt = GetIt.instance;

Future<void> initialDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<LocalStorageService>(
    LocalStorageService(prefs: getIt<SharedPreferences>()),
  );
  getIt.registerSingleton<AuthService>(AuthService());
}

Future<void> main() async {
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
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => LigneBloc(LigneService())..add(LoadLignes())),
        BlocProvider(create: (_) => BusBloc(BusService())..add(LoadBuses())),
        BlocProvider(create: (_) => ObjetPerduBloc()..add(const LoadObjetsPerdus())),
        BlocProvider(create: (_) => ClaimsBloc(ReclamationService())..add(LoadClaims())),
      ],
      child: MaterialApp(
        title: 'Smart Bus',
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          "/lostObjectsPage": (context) => const LostObjectsPage(),
          "/declare-objet": (context) => const DeclareObjetPage(),
          "/adminListPage": (context) => const AdminListPage(),
          "/loginPage": (context) => const LoginPage(),
          "/homePage": (context) => const HomePage(),
          "/mapPage": (context) => const MapPage(),
          "/profilePage": (context) => const ProfilePage(),
          "/registerPage": (context) => const RegisterPage(),
          "/ticketsPage": (context) => const TicketPage(),
          "/linesPage": (context) => const LinesPage(),
          "/resetSuccess": (context) => const ResetSuccess(),
          "/claimsPage": (context) => const ClaimsPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/admin-detail') {
            if (settings.arguments is ObjetPerdu) {
              return MaterialPageRoute(
                builder: (context) => AdminObjetDetailPage(
                  objetId: (settings.arguments as ObjetPerdu).id!,
                ),
              );
            } else if (settings.arguments is int) {
              return MaterialPageRoute(
                builder: (context) => AdminObjetDetailPage(objetId: settings.arguments as int),
              );
            }
          }

          if (settings.name == '/detail') {
            if (settings.arguments is ObjetPerdu) {
              return MaterialPageRoute(
                builder: (context) => UserObjetDetailPage(objet: settings.arguments as ObjetPerdu),
              );
            } else if (settings.arguments is int) {
              return MaterialPageRoute(
                builder: (context) => UserObjetDetailPage(objetId: settings.arguments as int),
              );
            }
          }
          return null;
        },
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) return const SplashScreen();
            if (state is AuthAuthenticated) {
              return state.user.role == Role.ADMIN ? const AdminHomePage() : const HomePage();
            }
            return const LoginPage();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
