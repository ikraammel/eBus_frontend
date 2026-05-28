import 'package:flutter/material.dart';
import 'package:smart_bus/utils/contact_support.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/app_infos.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/expansion_tile_items.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/help_banner.dart';
import 'package:smart_bus/views/pages/profile/parametres/help_and_support/quick_actions.dart';

import '../../../../../constants/app_colors.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Aide & Support",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.darkBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HelpBanner(),
              const SizedBox(height: 15),
              const Text(
                "Questions frequentes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              const ExpansionTileItems(
                title: "Comment acheter un ticket ?",
                subtitle:
                    "Rendez-vous dans la section Paiement et choisissez le type de ticket souhaite.",
              ),
              const ExpansionTileItems(
                title: "Ou consulter les horaires des bus a Safi ?",
                subtitle:
                    "Les horaires peuvent varier selon la ligne, le jour et les conditions de circulation. Consultez les informations affichees aux arrets et les canaux officiels ou contactez le support pour etre oriente vers la ligne qui vous concerne.",
              ),
              const ExpansionTileItems(
                title: "Comment suivre mon bus en temps reel ?",
                subtitle:
                    "Utilisez la carte interactive pour voir la position de votre bus lorsque le suivi est disponible.",
              ),
              const ExpansionTileItems(
                title: "Quand puis-je souscrire a un abonnement ?",
                subtitle:
                    "Vous pouvez proceder a l'abonnement uniquement lorsque votre dossier est accepte par l'administration. Si votre dossier est en attente, vous devez patienter jusqu'a sa validation.",
              ),
              const ExpansionTileItems(
                title: "Quels documents sont demandes pour un abonnement scolaire ?",
                subtitle:
                    "Pour un abonnement scolaire ou etudiant, preparez une photo, la CIN ou celle du tuteur pour les mineurs, la carte scolaire et l'attestation de scolarite. eBus demande aussi le CNE ou code MASSAR pour les dossiers etudiants.",
              ),
              const ExpansionTileItems(
                title: "Mon dossier est rejete, que dois-je faire ?",
                subtitle:
                    "Ouvrez vos informations personnelles, corrigez les champs ou documents signales, puis enregistrez et re-soumettez le dossier. Il repassera en verification par l'administration.",
              ),
              const ExpansionTileItems(
                title: "Je veux changer mon dossier apres validation, est-ce possible ?",
                subtitle:
                    "Si votre dossier est deja accepte et que vous devez modifier une information sensible ou un document, contactez le support. Une demande de modification doit etre traitee par l'equipe avant tout changement.",
              ),
              const ExpansionTileItems(
                title: "Pourquoi je ne peux pas payer mon abonnement ?",
                subtitle:
                    "Le paiement est bloque tant que le dossier n'est pas accepte. Verifiez le statut de votre dossier depuis l'accueil ou vos informations personnelles.",
              ),
              const ExpansionTileItems(
                title: "Que faire si j'ai perdu un objet ?",
                subtitle:
                    "Consultez la section Objets Perdus et declarez votre objet avec le plus de details possible.",
              ),
              const ExpansionTileItems(
                title: "Comment soumettre une reclamation ?",
                subtitle:
                    "Utilisez les actions rapides pour envoyer un email ou appeler le support. Vous pouvez aussi decrire clairement le probleme rencontre, la ligne concernee et la date.",
              ),
              const SizedBox(height: 15),
              const Text(
                "Actions rapides",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              QuickActions(
                text: "Envoyer un email",
                icon: Icons.email,
                color: AppColors.darkBlue,
                onTap: () => ContactSupport.sendEmail(),
              ),
              QuickActions(
                text: "Appeler le support",
                icon: Icons.phone,
                color: AppColors.green,
                onTap: () => ContactSupport.callSupport(),
              ),
              const AppInfos(),
            ],
          ),
        ),
      ),
    );
  }
}
