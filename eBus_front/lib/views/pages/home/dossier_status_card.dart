import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';

class DossierStatusCard extends StatelessWidget {
  final String? status;

  const DossierStatusCard({super.key, this.status});

  String getDossierMessage(String? status) {
    switch (status) {
      case "EN_ATTENTE":
        return "Votre dossier est en cours de traitement.";
      case "EN_COURS":
        return "Votre dossier est en cours de vérification par l'administration.";
      case "VALIDE":
        return "Dossier validé 🎉 Vous pouvez maintenant souscrire à un abonnement.";
      case "REJETE":
        return "Votre dossier a été rejeté. Veuillez contacter l'administration.";
      default:
        return "Statut du dossier en cours de récupération...";
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case "VALIDE":
        color = AppColors.green;
        icon = Icons.check_circle_rounded;
        break;
      case "REJETE":
        color = Colors.red;
        icon = Icons.cancel_rounded;
        break;
      case "EN_COURS":
        color = Colors.orange;
        icon = Icons.hourglass_bottom_rounded;
        break;
      case "EN_ATTENTE":
        color = Colors.blue;
        icon = Icons.info_rounded;
        break;
      default:
        color = Colors.blueGrey;
        icon = Icons.help_outline_rounded;
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
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  getDossierMessage(status),
                  style: TextStyle(
                    color: color.darken(0.15),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          // ── Bouton "Passer au paiement" visible uniquement si VALIDE ──────
          if (status == "VALIDE") ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigation directe vers la page Tickets/Abonnements
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
