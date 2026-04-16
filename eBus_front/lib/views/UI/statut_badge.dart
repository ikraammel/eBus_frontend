import 'package:flutter/material.dart';
import 'package:smart_bus/models/statut_objet.dart';

class StatutBadge extends StatelessWidget {
  final StatutObjet statut;
  const StatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;


    switch (statut) {
      case StatutObjet.DISPONIBLE:
        color = const Color(0xFF2E7D32);
        label = "Disponible";
        break;
      case StatutObjet.EN_ATTENTE:
        color = const Color(0xFFE67E22);
        label = "Signalé";
        break;
      case StatutObjet.EN_ATTENTE_RECUPERATION:
        color = const Color(0xFF1976D2); // Bleu Info
        label = "En attente";
        break;
      case StatutObjet.RECUPERE:
        color = const Color(0xFF607D8B); // Gris Bleu
        label = "Récupéré";
        break;
      default:
        color = Colors.grey;
        label = "Inconnu";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), // Fond pastel très léger
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
