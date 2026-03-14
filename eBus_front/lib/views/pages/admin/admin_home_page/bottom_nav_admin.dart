import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class BottomNavAdmin extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomNavAdmin({super.key,required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index){
        onItemSelected(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.darkBlue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Accueil"),
        BottomNavigationBarItem(icon: Icon(Icons.query_stats), label: "Stats"),
        BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: "Gestion"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
      ],
    );
  }
}
