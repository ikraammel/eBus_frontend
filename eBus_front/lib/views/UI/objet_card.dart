import 'package:flutter/material.dart';
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'statut_badge.dart';

class ObjetCard extends StatelessWidget {
  final ObjetPerdu objet;
  final bool isAdmin;
  final bool isOwner;
  final VoidCallback? onTap;
  final VoidCallback? onMarquerRecupere;
  final VoidCallback? onMarquerDisponible;
  final VoidCallback? onCestMonObjet;

  const ObjetCard({
    super.key,
    required this.objet,
    required this.isAdmin,
    this.isOwner = false,
    this.onTap,
    this.onMarquerRecupere,
    this.onMarquerDisponible,
    this.onCestMonObjet,
  });

  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFFE67E22);
  static const Color textMain = Color(0xFF1A1A1A);
  static const Color textSub = Color(0xFF607D8B);

  @override
  Widget build(BuildContext context) {
    final bool isPerte = objet.type == TypeAnnonce.PERTE;
    final StatutObjet statut = objet.statut;
    final Color themeColor = isPerte ? accentColor : primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _typeBadge(isPerte),
                    StatutBadge(statut: statut),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        isPerte
                            ? Icons.search_rounded
                            : Icons.inventory_2_outlined,
                        color: themeColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            objet.nom ?? 'Objet sans nom',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: textMain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            objet.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textSub,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _infoIcon(Icons.directions_bus_outlined,
                        'Ligne ${objet.ligne ?? "N/A"}'),
                    const SizedBox(width: 20),
                    _infoIcon(
                      Icons.calendar_today_rounded,
                      '${objet.dateDeclaration.day}/${objet.dateDeclaration.month}/${objet.dateDeclaration.year}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),


                if (isAdmin)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (objet.userNom != null)
                        _info('Signalé par: ${objet.userNom}'),
                      if (objet.contact != null)
                        _info('Contact: ${objet.contact}',
                            color: Colors.blue),
                    ],
                  ),

                const SizedBox(height: 18),
                _buildActions(isPerte, statut),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(bool isPerte, StatutObjet statut) {
    Widget details = Expanded(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.info_outline, size: 18, color: primaryColor),
        label: const Text('Détails',
            style: TextStyle(
                color: primaryColor, fontWeight: FontWeight.bold)),
        onPressed: onTap,
      ),
    );

    if (isAdmin) {
      return Row(
        children: [
          details,
          const SizedBox(width: 12),
          if (statut == StatutObjet.EN_ATTENTE)
            Expanded(
              child: ElevatedButton(
                onPressed: onMarquerDisponible,
                child: const Text("VALIDER"),
              ),
            )
          else if (statut == StatutObjet.DISPONIBLE ||
              statut == StatutObjet.EN_ATTENTE_RECUPERATION)
            Expanded(
              child: ElevatedButton(
                onPressed: onMarquerRecupere,
                child: const Text("RÉCUPÉRÉ"),
              ),
            ),
        ],
      );
    }

    return Row(children: [details]);
  }

  Widget _typeBadge(bool isPerte) {
    final color = isPerte ? accentColor : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPerte ? "PERDU" : "TROUVÉ",
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _infoIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSub),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: textSub)),
      ],
    );
  }

  Widget _info(String text, {Color color = textSub}) {
    return Text(text, style: TextStyle(fontSize: 12, color: color));
  }
}
