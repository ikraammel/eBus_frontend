import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/main.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/pages/login/login_page.dart';
import 'package:smart_bus/views/pages/profile/contact_card.dart';
import 'package:smart_bus/views/pages/profile/header_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/confidentiality/confidentiality_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/help_and_support_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/notifications/notifications_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/parametres_page.dart';
import 'package:smart_bus/views/pages/profile/parametres/personal_infos/personal_infos.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../UI/splash_screen.dart';

class ProfilePage extends StatelessWidget {
  final bool showBackButton;
  const ProfilePage({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          
          // Vérification si l'utilisateur est étudiant/scolaire
          final bool isScolaire = user.cne != null && user.cne!.isNotEmpty;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  HeaderPage(currentUser: user, showBackButton: showBackButton),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            ContactCard(
                                value: user.email,
                                icon: Icons.email,
                                label: 'Email'
                            ),
                            ContactCard(
                                value: user.cin,
                                icon: Icons.account_box,
                                label: 'CIN'
                            ),
                            
                            // Affichage conditionnel de la carte scolaire (CNE)
                            if (isScolaire)
                              ContactCard(
                                  value: user.cne!,
                                  icon: Icons.badge,
                                  label: 'Carte Scolaire (CNE)'
                              ),

                            ContactCard(
                                value: user.tel,
                                icon: Icons.phone,
                                label: 'Téléphone'
                            ),
                            ContactCard(
                                value: user.adresse,
                                icon: Icons.location_on,
                                label: 'Adresse'
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "PARAMÈTRES",
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ParametresPage(
                          icon: Icons.person,
                          label: 'Informations personnelles',
                          onTap: () =>
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const PersonalInfos())
                              ),
                        ),
                        const ParametresPage(
                            icon: Icons.credit_card_sharp,
                            label: 'Moyens de paiement'
                        ),
                        ParametresPage(
                            icon: Icons.notifications,
                            label: 'Notifications',
                            onTap: () =>
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const NotificationsPage())
                              ),
                        ),
                        ParametresPage(
                            icon: Icons.shield_outlined,
                            label: 'Confidentialité',
                          onTap: () =>
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ConfidentialityPage())
                              ),
                        ),
                        ParametresPage(
                            icon: Icons.help,
                            label: 'Aide & Support',
                            onTap:() => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HelpAndSupportPage()
                              )
                            ),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                                    (route) => false,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.3)),
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
                      ],
                    ),
                  )
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
