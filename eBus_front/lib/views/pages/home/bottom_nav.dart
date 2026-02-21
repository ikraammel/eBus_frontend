import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNav({super.key,required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index){
        onItemSelected(index);
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
