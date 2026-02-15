import 'package:flutter/material.dart';
import 'package:smart_bus/main.dart';
import 'package:smart_bus/models/User.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/pages/login/login_page.dart';
import 'package:smart_bus/views/pages/profile/contact_card.dart';
import 'package:smart_bus/views/pages/profile/header_page.dart';
import 'package:smart_bus/views/pages/profile/parametres_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;
  final storage = getIt<LocalStorageService>();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser(){
    setState(() {
      currentUser = storage.getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderPage(currentUser: currentUser),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
                children: [
                  Column(
                      children: [
                        ContactCard(
                            value: currentUser?.email ?? "email@exemple.com",
                            icon: Icons.email,
                            label: 'Email'
                        ),
                        ContactCard(
                            value: currentUser!.cin,
                            icon: Icons.account_box,
                            label: 'CIN'
                        ),
                        ContactCard(
                            value: currentUser!.cne,
                            icon: Icons.badge,
                            label: 'Carte Scolaire'
                        ),
                        ContactCard(
                            value: currentUser?.tel ?? "0600000000",
                            icon: Icons.phone,
                            label: 'Téléphone'
                        ),
                        ContactCard(
                            value: currentUser?.adresse ?? "Adresse",
                            icon: Icons.location_on,
                            label: 'Adresse'
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
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
                  const SizedBox(height: 15), // Un peu d'espace avant la liste
                  ParametresPage(icon: Icons.person, label: 'Informations personnelles'),
                  ParametresPage(icon: Icons.credit_card_sharp, label: 'Moyens de paiement'),
                  ParametresPage(icon: Icons.notifications, label: 'Notifications'),
                  ParametresPage(icon: Icons.shield_outlined, label: 'Confidentialité'),
                  ParametresPage(icon: Icons.help, label: 'Aide & Support'),
                  // À ajouter à la fin de votre Column de paramètres
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      await storage.logout();
                      if (mounted) {
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
