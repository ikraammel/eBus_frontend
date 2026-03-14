import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class LineDetailsPage extends StatelessWidget {
  final String lineNumber;
  final Color themeColor;
  final List<Map<String, String>> stops;

  const LineDetailsPage({
    super.key,
    required this.lineNumber,
    required this.themeColor,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            // Petit badge avec le numéro de la ligne
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lineNumber,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 15),
            // Nom de la destination
            Expanded(
              child: Text(
                'Station',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Section Header sous l'AppBar avec le bouton Carte
          Container(
            width: double.infinity,
            color: themeColor,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: Column(
              children: [
                const Text(
                  "Fréquence : 10 - 15 min",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Action pour ouvrir la carte ici
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("Voir sur la carte"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Titre de la section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Arrêts de la ligne",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Liste des arrêts (Timeline)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              itemCount: stops.length,
              itemBuilder: (context, index) {
                // On simule l'état : les arrêts avant l'index 2 sont "passés"
                return _buildStopItem(
                  name: stops[index]['name'] ?? "Arrêt inconnu",
                  time: stops[index]['time'] ?? "--:--",
                  isPassed: index < 2,
                  isCurrent: index == 2,
                  isLast: index == stops.length - 1,
                  themeColor: themeColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour un élément de la timeline
  Widget _buildStopItem({
    required String name,
    required String time,
    bool isPassed = false,
    bool isCurrent = false,
    bool isLast = false,
    required Color themeColor,
  }) {
    // Logique de couleur
    Color dotColor = isCurrent ? themeColor : (isPassed ? Colors.grey[300]! : Colors.white);
    Color textColor = isCurrent ? themeColor : (isPassed ? Colors.grey : AppColors.darkBlue);

    return IntrinsicHeight(
      child: Row(
        children: [
          // Partie gauche : La ligne et le point
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent ? themeColor : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
              ),
              // Ligne verticale (ne pas afficher si c'est le dernier arrêt)
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[200],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // Partie droite : Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Bus en approche",
                      style: TextStyle(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const SizedBox(height: 35), // Espace constant entre les arrêts
              ],
            ),
          ),
        ],
      ),
    );
  }
}

