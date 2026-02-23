import 'package:flutter/material.dart';
import 'package:smart_bus/utils/contact_support.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/app_infos.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/expansion_tile_items.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/help_banner.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/quick_actions.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Aide & Support",
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        ),
        backgroundColor: const Color(0xFF1A367C),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpBanner(),
              SizedBox(height: 15,),
              Text(
                "Questions fréquentes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700
                ),
              ),
              SizedBox(height: 15,),
              ExpansionTileItems(
                  title: "Comment acheter un ticket ?",
                  subtitle: "Rendez-vous dans la section Paiement et choisissez le type de ticket souhaité."
              ),
              ExpansionTileItems(
                  title: "Comment suivre mon bus en temps réel ?",
                  subtitle: "Utilisez la carte interactive pour voir la position de votre bus."
              ),
              ExpansionTileItems(
                  title: "Que faire si j'ai perdu un objet ?",
                  subtitle: "Consultez la section Objets Perdus et déclarez votre objet."
              ),
              ExpansionTileItems(
                  title: "Comment soumettre une réclamation ?",
                  subtitle: "Allez dans Réclamations et remplissez le formulaire détaillé."
              ),
              SizedBox(height: 15,),
              Text(
                "Actions rapides",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700
                ),
              ),
              SizedBox(height: 15,),
              QuickActions(
                text: "Envoyer un email",
                icon: Icons.email,
                color: Color(0xFF1A367C),
                onTap: () => ContactSupport.sendEmail(),
              ),
              QuickActions(
                text: "Appeler le support",
                icon: Icons.phone,
                color: Color(0xFF76BC41),
                onTap: () => ContactSupport.callSupport(),
              ),
              AppInfos(),
            ],
          ),
        ),
      ),
    );
  }
}
