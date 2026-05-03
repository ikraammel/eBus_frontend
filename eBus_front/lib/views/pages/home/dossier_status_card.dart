import 'package:flutter/material.dart';

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
        return "Dossier validé 🎉 Vous pouvez maintenant passer au paiement.";
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
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case "REJETE":
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case "EN_COURS":
        color = Colors.orange;
        icon = Icons.hourglass_bottom;
        break;
      case "EN_ATTENTE":
        color = Colors.blue;
        icon = Icons.info;
        break;
      default:
        color = Colors.blueGrey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                    color: color.darken(0.2), // Utilisation du helper corrigé
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (status == "VALIDE") ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/paymentPage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text("Procéder au paiement", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    // Correction ici : HSLColor utilise 'lightness' et non 'brightness'
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
