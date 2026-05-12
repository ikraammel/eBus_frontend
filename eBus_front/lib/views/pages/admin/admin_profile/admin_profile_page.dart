import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/views/pages/login/login_page.dart';
import 'package:smart_bus/views/pages/profile/contact_card.dart';
import 'package:smart_bus/views/pages/profile/parametres/parametres_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/notifications/notifications_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/personal_infos/personal_infos.dart';

import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../bloc/auth/auth_event.dart';
import '../../../../bloc/auth/auth_state.dart';
import '../../../UI/splash_screen.dart';
import '../../profile/header_page.dart';
import '../../profile/parametres/change_password/change_password_page.dart';

class AdminProfilePage extends StatefulWidget {
  final bool showBackButton;
  const AdminProfilePage({super.key, this.showBackButton = true});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  HeaderPage(
                    currentUser: user,
                    showBackButton: widget.showBackButton,
                    allowEditAvatar: true, // Autorise la modification de l'avatar
                  ),
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
                          value: user.cin,
                          icon: Icons.badge,
                          label: 'CIN',
                        ),
                        ContactCard(
                          value: user.tel,
                          icon: Icons.phone,
                          label: 'Téléphone',
                        ),
                        ContactCard(
                          value: user.adresse,
                          icon: Icons.location_on,
                          label: 'Adresse',
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Paramètres & Sécurité",
                          style: TextStyle(
                            color: Colors.blueGrey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ParametresPage(
                          icon: Icons.person_outline,
                          label: 'Modifier mes informations',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PersonalInfos()),
                          ),
                        ),
                        ParametresPage(
                          icon: Icons.notifications_none,
                          label: 'Notifications',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsPage()),
                          ),
                        ),
                        ParametresPage(
                          icon: Icons.lock_outline,
                          label: 'Changer le mot de passe',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordPage(),
                            ),
                          ),
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
        return const Scaffold(body: SplashScreen());
      },
    );
  }
}