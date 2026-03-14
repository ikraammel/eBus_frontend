import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  Widget _buildSmallCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.green,
        elevation: 0,
        title: const Text('Statistiques 📊', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.1,
          children: [
            _buildSmallCard("Revenus du jour", "4,250€", Icons.euro, Colors.green),
            _buildSmallCard("Tickets vendus", "1,847", Icons.show_chart, Colors.blue),
            _buildSmallCard("Temps moyen", "22 min", Icons.access_time, Colors.orange),
            _buildSmallCard("Incidents", "3", Icons.error_outline, Colors.red),
          ],
        ),
      ),
    );
  }
}
