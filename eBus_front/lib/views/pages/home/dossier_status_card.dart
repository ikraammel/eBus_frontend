import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';

class DossierStatusCard extends StatelessWidget {
  final String? status;
  final String? rejectionReason;
  const DossierStatusCard({super.key, this.status, this.rejectionReason});

  String getDossierMessage(String? status) {
    final s = status?.toUpperCase().trim() ?? "";
    switch (s) {
      case "EN_ATTENTE":
        return "Votre dossier est en cours de traitement.";
      case "EN_COURS":
        return "Votre dossier est en cours de vérification par l'administration.";
      case "VALIDE":
      case "VALIDÉ":
      case "ACTIF":
        return "Dossier validé 🎉 Vous pouvez maintenant souscrire à un abonnement.";
      case "REJETE":
        if (rejectionReason == null || rejectionReason!.isEmpty) {
          return "Votre dossier a été rejeté. Veuillez contacter l'administration.";
        }
        return "Votre dossier a été rejeté.\nMotif : $rejectionReason";
      default:
        return "Statut du dossier : $status";
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    final s = status?.toUpperCase().trim() ?? "";

    if (s == "VALIDE" || s == "VALIDÉ" || s == "ACTIF") {
      color = AppColors.green;
      icon = Icons.check_circle_rounded;
    } else if (s == "REJETE" || s == "REJETÉ") {
      color = Colors.red;
      icon = Icons.cancel_rounded;
    } else if (s == "EN_COURS") {
      color = Colors.orange;
      icon = Icons.hourglass_bottom;
    } else {
      color = Colors.blue;
      icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getDossierMessage(status),
                      style: TextStyle(
                        color: color.darken(0.15),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    // Affichage du motif si le dossier est rejeté
                    if ((s == "REJETE" || s == "REJETÉ") && rejectionReason != null && rejectionReason!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Motif du rejet : $rejectionReason",
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (s == "VALIDE" || s == "VALIDÉ") ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TicketPage(openAbonnementsTab: true),
                    ),
                  );
                },
                icon: const Icon(Icons.card_membership_rounded, size: 18),
                label: const Text(
                  "Procéder au paiement",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ],

          if (s == "REJETE") ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                 onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/personalInfos',
                    arguments: rejectionReason,
                  );
                },
                icon: const Icon(Icons.edit_document, size: 18),
                label: const Text(
                  "Modifier mes informations",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
