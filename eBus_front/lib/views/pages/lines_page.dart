import 'package:flutter/material.dart';
import 'line_details_page.dart';

class LinesPage extends StatelessWidget {
  const LinesPage({super.key});

  // Données pour la démonstration
  final List<Map<String, String>> stopsLine12 = const [
    {"name": "Gare Centrale", "time": "08:00"},
    {"name": "Avenue des Lilas", "time": "08:05"},
    {"name": "Rue du Commerce", "time": "08:10"},
    {"name": "Place Victor Hugo", "time": "08:15"},
    {"name": "Campus Universitaire", "time": "08:30"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A367C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Lignes de bus",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildLineCard(context, "12", "Centre-Ville", "Gare Centrale", "Campus", "10 min", const Color(0xFF1A367C)),
                _buildLineCard(context, "5", "Quartier Ouest", "Place Rép.", "Zone Ind.", "15 min", const Color(0xFF8DC63F)),
                _buildLineCard(context, "8", "Ligne Express", "Aéroport", "Centre Com.", "20 min", const Color(0xFF1A367C)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF1A367C),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Rechercher une ligne...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildLineCard(BuildContext context, String number, String name, String start, String end, String freq, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // FORCE la détection du clic sur toute la carte
        onTap: () {
          debugPrint("Clic sur la ligne $number");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LineDetailsPage(
                lineName: name,
                lineNumber: number,
                themeColor: color,
                stops: stopsLine12,
              ),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                ),
                child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A367C))),
                      const SizedBox(height: 5),
                      Text("$start → $end", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
