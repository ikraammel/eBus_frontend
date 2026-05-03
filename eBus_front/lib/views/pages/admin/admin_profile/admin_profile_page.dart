import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/views/pages/login/login_page.dart';
import 'package:smart_bus/views/pages/profile/contact_card.dart';
import 'package:smart_bus/views/pages/profile/parametres/parametres_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/notifications/notifications_page.dart';

import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../bloc/auth/auth_event.dart';
import '../../../../bloc/auth/auth_state.dart';
import '../../../../main.dart';
import '../../../../services/local_storage_service.dart';
import '../../../UI/splash_screen.dart';
import '../../profile/header_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  @override
  Widget build(BuildContext context) {
    final storage = getIt<LocalStorageService>();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  HeaderPage(currentUser: user),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Informations personnelles",
                          style: TextStyle(
                            color: Colors.blueGrey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ContactCard(
                          value: user.email,
                          icon: Icons.email,
                          label: 'Email',
                        ),
                        ContactCard(
                          value: user.tel,
                          icon: Icons.phone,
                          label: 'Téléphone',
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Paramètres",
                          style: TextStyle(
                            color: Colors.blueGrey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ParametresPage(
                          icon: Icons.notifications,
                          label: 'Notifications',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsPage()),
                          ),
                        ),
                        const ParametresPage(
                          icon: Icons.security,
                          label: 'Sécurité',
                        ),
                        const ParametresPage(
                          icon: Icons.settings,
                          label: 'Préférences',
                        ),
                        const SizedBox(height: 30),
                        InkWell(
                          onTap: () async {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                                (route) => false,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.red),
                                SizedBox(width: 10),
                                Text(
                                  "Se déconnecter",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SplashScreen();
      },
    );
  }
}
