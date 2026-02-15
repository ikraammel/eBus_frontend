import 'package:flutter/material.dart';
import 'package:smart_bus/main.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/home/bottom_nav.dart';
import 'package:smart_bus/views/home/card_menu.dart';
import 'package:smart_bus/views/home/home_header.dart';
import 'package:smart_bus/views/home/recent_activity.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';

import '../../models/User.dart';
import '../pages/map_page.dart';
import '../pages/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  final User? currentUser;
  const HomePage({super.key, this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? currentUser;
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return MapPage();
      case 2:
        return TicketPage();
      case 3:
        return ProfilePage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent(){
    return Column(
      children: [
        HomeHeader(currentUser: currentUser),
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
                RecentActivity(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    if(widget.currentUser != null){
      currentUser = widget.currentUser;
    }else{
      loadUser();
    }
  }

  final storage = getIt<LocalStorageService>();

  void loadUser() async{
    User? user = storage.getUser();
    setState(() {
      currentUser = user;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          if (index == 3) {
            if (currentUser == null) {
              _showLoginRequiredDialog();
            } else {
              // Push la page Profile et NE PAS changer _selectedIndex
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            }
            return;
          }

          // Pour les autres onglets, reste avec setState
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

    );
  }

  void _showLoginRequiredDialog(){
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Connexion requise"),
          content: Text("Vous devez vous connecter pour accéder à cette page."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler")
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/loginPage');
                },
                  child: Text("Se Connecter")
            ),
          ],
        )
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
        CardMenu(
          title: 'Lignes',
          icon: Icons.directions_bus_filled,
          color: Color(0xFF1A367C),
          onTap: () {
            Navigator.pushNamed(context, '/linesPage');
          },
        ),
        CardMenu(
          title: 'Suivi du bus',
          icon: Icons.map,
          color: Color(0xFF8DC63F),
          onTap: () {
            Navigator.pushNamed(context, '/busTrackingPage');
          },
        ),
        CardMenu(
          title: 'Paiement',
          icon: Icons.credit_card,
          color: Color(0xFF1A367C),
          onTap: () {
            if(currentUser == null){
              _showLoginRequiredDialog();
            }else{
              Navigator.pushNamed(context, '/paymentPage');
            }
          },
        ),
        CardMenu(
          title: 'Réclamations',
          icon: Icons.chat_bubble_outline,
          color: Color(0xFF8DC63F),
          onTap: () {
            Navigator.pushNamed(context, '/claimsPage');
          },
        ),
        CardMenu(
          title: 'Objets perdus',
          icon: Icons.inventory_2_outlined,
          color: Color(0xFF1A367C),
          onTap: () {
            Navigator.pushNamed(context, '/lostObjectsPage');
          },
        ),
      ],
    );
  }
}
