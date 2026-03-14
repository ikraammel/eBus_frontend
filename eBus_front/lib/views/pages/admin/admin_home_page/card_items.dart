import 'package:flutter/material.dart';

class CardItems extends StatelessWidget {
  const CardItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.9,
          children: [
            _buildMainCard(
              title: "Utilisateurs",
              value: "2,547",
              trend: "+12%",
              icon: Icons.people_outline,
              color: const Color(0xFF3F51B5),
              trendColor: Colors.green,
            ),
            _buildMainCard(
              title: "Bus actifs",
              value: "45",
              trend: "+3",
              icon: Icons.directions_bus_filled_outlined,
              color: const Color(0xFF8DC63F),
              trendColor: Colors.teal,
            ),
            _buildMainCard(
              title: "Réclamations",
              value: "18",
              trend: "-5%",
              icon: Icons.chat_bubble_outline,
              color: const Color(0xFF3F51B5),
              trendColor: Colors.red,
            ),
            _buildMainCard(
              title: "Objets trouvés",
              value: "12",
              trend: "+2",
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFF8DC63F),
              trendColor: Colors.teal,
            ),
          ],
        ),

      ],
    );
  }

  // Widget interne pour les grandes cartes du haut
  Widget _buildMainCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(trend, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }


}