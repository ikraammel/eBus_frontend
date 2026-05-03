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
        label = "En attente";
        break;
      case StatutObjet.EN_ATTENTE_RECUPERATION:
        color = const Color(0xFF1976D2);
        label = "À récupérer";
        break;
      case StatutObjet.RECUPERE:
        color = const Color(0xFF607D8B);
        label = "Clôturé";
        break;
      default:
        color = Colors.grey;
        label = "Inconnu";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), // Fond un peu plus prononcé
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color, // Couleur vive sur fond pastel
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
