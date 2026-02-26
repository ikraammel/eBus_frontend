import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'declare_lost_object_page.dart';

class LostObjectsPage extends StatelessWidget {
  const LostObjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const Text("Objets trouvés"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeclareLostObjectPage())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard("Portefeuille noir", "Disponible", AppColors.green),
          _buildCard("Téléphone Samsung", "Récupéré", Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String status, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.inventory_2, color: color),
        title: Text(title),
        trailing: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}