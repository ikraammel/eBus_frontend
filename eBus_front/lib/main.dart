import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_database/firebase_database.dart';
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
import 'package:smart_bus/bloc/bus/bus_event.dart';
import 'package:smart_bus/bloc/claims/claims_bloc.dart';
import 'package:smart_bus/bloc/claims/claims_event.dart';
import 'package:smart_bus/bloc/dashboard/dashboard_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';

// Services
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/bus_service.dart';
import 'package:smart_bus/services/horaire_service.dart';
import 'package:smart_bus/services/ligne_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/services/reclamation_service.dart';

// Views
import 'package:smart_bus/views/UI/splash_screen.dart';
import 'package:smart_bus/views/pages/admin/admin_home_page/admin_home_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_bus/admin_bus_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_horaire/gestion_horaires_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_lignes_stations/admin_lignes_page.dart';
import 'package:smart_bus/views/pages/claims/claims_page.dart';
import 'package:smart_bus/views/pages/home/home_page.dart';
import 'package:smart_bus/views/pages/login/login_page.dart';
import 'package:smart_bus/views/pages/login/forgot_password/reset_success.dart';
import 'package:smart_bus/views/pages/map_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/personal_infos/personal_infos.dart';
import 'package:smart_bus/views/pages/profile/profile_page.dart';
import 'package:smart_bus/views/pages/register/register_page.dart';
import 'package:smart_bus/views/pages/lines/lines_page.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';
import 'package:smart_bus/views/pages/tickets/payment_success_page.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/views/pages/lost_objects/lost_objects_page.dart';
import 'package:smart_bus/views/pages/lost_objects/declare_lost_object_page.dart';
import 'package:smart_bus/views/pages/lost_objects/user_objet_detail_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_objet_perdu/admin_list_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_objet_perdu/admin_objet_detail_page.dart';

import 'bloc/dashboard/dashboard_event.dart';

import 'package:firebase_core/firebase_core.dart';

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

  await Firebase.initializeApp();

  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://ebus-6311b-default-rtdb.firebaseio.com",
  );

  getIt.registerSingleton<FirebaseDatabase>(db);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  String? _lastHandledLink;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print("[DeepLink] Erreur lien initial: $e");
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (error) {
        print("[DeepLink] Erreur stream: $error");
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (_lastHandledLink == uri.toString()) return;
    _lastHandledLink = uri.toString();

    print("[DeepLink] Recu: $uri");
    if (uri.scheme == 'gestionbus' && uri.host == 'payment-success') {
      final sessionId = uri.queryParameters['session_id'];
      print("[DeepLink] payment-success session_id=$sessionId");

      _openPaymentSuccess(sessionId);
    }
  }

  void _openPaymentSuccess(String? sessionId) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openPaymentSuccess(sessionId);
      });
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(sessionId: sessionId),
      ),
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => LigneBloc(LigneService())..add(LoadLignes())),
        BlocProvider(create: (_) => BusBloc(BusService())..add(LoadBuses())),
        BlocProvider(create: (_) => ObjetPerduBloc()..add(const LoadObjetsPerdus())),
        BlocProvider(create: (_) => ClaimsBloc(ReclamationService())..add(LoadClaims())),
        BlocProvider(create: (_) => DashboardBloc()..add(LoadDashboard())),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
          "/horaireAdminPage": (context) => const GestionHorairesPage(),
          "/adminLignesPage": (context) => const AdminLignesPage(),
          "/adminBusPage": (context) => const AdminBusPage(),
          '/personalInfos': (context) => PersonalInfos(
            rejectionReason: ModalRoute.of(context)?.settings.arguments as String?,
          ),

        },
        onGenerateRoute: (settings) {
          // Retour de Stripe : /#/payment-success?session_id=cs_xxx
          if (settings.name != null &&
              settings.name!.startsWith('/payment-success')) {
            final uri = Uri.tryParse(settings.name!);
            final sessionId = uri?.queryParameters['session_id'];
            return MaterialPageRoute(
              builder: (_) => PaymentSuccessPage(
                sessionId: sessionId,
              ),
            );
          }

          if (settings.name == '/admin-detail') {
            if (settings.arguments is ObjetPerdu) {
              return MaterialPageRoute(
                builder: (context) => AdminObjetDetailPage(
                  objetId: (settings.arguments as ObjetPerdu).id!,
                ),
              );
            } else if (settings.arguments is int) {
              return MaterialPageRoute(
                builder: (context) => AdminObjetDetailPage(
                    objetId: settings.arguments as int),
              );
            }
          }

          if (settings.name == '/detail') {
            if (settings.arguments is ObjetPerdu) {
              return MaterialPageRoute(
                builder: (context) => UserObjetDetailPage(
                    objet: settings.arguments as ObjetPerdu),
              );
            } else if (settings.arguments is int) {
              return MaterialPageRoute(
                builder: (context) =>
                    UserObjetDetailPage(objetId: settings.arguments as int),
              );
            }
          }

          return null;
        },
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) return const SplashScreen();
            if (state is AuthAuthenticated) {
              return state.user.role == Role.ADMIN
                  ? const AdminHomePage()
                  : const HomePage();
            }
            // AJOUT : mode invité → HomePage sans utilisateur connecté
            if (state is AuthGuest) return const HomePage();
            return const LoginPage();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
