import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Accès rapide",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A367C)),
                  ),
                  const SizedBox(height: 15),
                  _buildGrid(),
                  const SizedBox(height: 25),
                  const Text(
                    "Activité récente",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A367C)),
                  ),
                  const SizedBox(height: 15),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1A367C),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bonjour,", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Jean Dupont", style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
              Container(
                height: 50, width: 50,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.directions_bus, color: Color(0xFF8DC63F)),
              )
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
            child: const Row(
              children: [
                Icon(Icons.bus_alert, color: Colors.white),
                SizedBox(width: 10),
                Text("Prochain bus dans ", style: TextStyle(color: Colors.white)),
                Text("5 min", style: TextStyle(color: Color(0xFF8DC63F), fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _buildMenuCard("Lignes", Icons.directions_bus_filled, const Color(0xFF1A367C)),
        _buildMenuCard("Suivi du bus", Icons.map, const Color(0xFF8DC63F)),
        _buildMenuCard("Paiement", Icons.credit_card, const Color(0xFF1A367C)),
        _buildMenuCard("Réclamations", Icons.chat_bubble_outline, const Color(0xFF8DC63F)),
        _buildMenuCard("Objets perdus", Icons.inventory_2_outlined, const Color(0xFF1A367C)),
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 35),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF8DC63F).withOpacity(0.1),
            child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF8DC63F)),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ticket acheté", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Ligne 12 • Il y a 2h", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Text("2.50€", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A367C))),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index){
        setState(() => _selectedIndex = index);
        if(index == 0){
          Navigator.pushReplacementNamed(context, '/homePage');
        }
        if(index == 1){
          Navigator.pushReplacementNamed(context, '/mapPage');
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1A367C),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Accueil"),
        BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: "Carte"),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: "Tickets"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
      ],
    );
  }
}
