import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/views/loading/splash_screen.dart';
import 'package:smart_bus/views/pages/home/recent_activity.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';

import '../../../models/User.dart';
import '../map_page.dart';
import '../profile/profile_page.dart';
import 'bottom_nav.dart';
import 'card_menu.dart';
import 'home_header.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Widget _getSelectedPage(User? user) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(user);
      case 1:
        return MapPage();
      case 2:
        return TicketPage();
      case 3:
        return ProfilePage();
      default:
        return _buildHomeContent(user);
    }
  }

  Widget _buildHomeContent(User? user){
    return Column(
      children: [
        HomeHeader(currentUser: user),
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
                _buildGrid(user),
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
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc,AuthState>(
      builder: (context, state) {
        User? currentUser;
        if (state is AuthAuthenticated) {
          currentUser = state.user;
        } else if (state is AuthUnauthenticated) {
          currentUser = null; // mode invité
        } else {
          return const Scaffold(
            body: SplashScreen(),
          );
        }
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FB),
            body: _getSelectedPage(currentUser),
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

  Widget _buildGrid(User? user) {
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
            if(user == null){
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
