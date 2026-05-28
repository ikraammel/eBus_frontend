import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/services/dossier_service.dart';
import 'package:smart_bus/views/pages/home/recent_activity.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';

import '../../../models/dossier.dart';
import '../../../models/user.dart';
import '../../UI/card_menu.dart';
import '../../UI/splash_screen.dart';
import '../map_page.dart';
import '../profile/profile_page.dart';
import 'bottom_nav.dart';
import 'home_header.dart';
import 'dossier_status_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final DossierService _dossierService = DossierService();

  Widget _getSelectedPage(User? user) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(user);
      case 1:
        return const MapPage();
      case 2:
        return const TicketPage();
      case 3:
        return const ProfilePage(showBackButton: false);
      default:
        return _buildHomeContent(user);
    }
  }

  Widget _buildHomeContent(User? user) {
    return Column(
      children: [
        HomeHeader(currentUser: user),
        if (user != null)
          FutureBuilder<Dossier?>(
            future: _dossierService.getMyDossier(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator())
                );
              }
              if (snapshot.hasData && snapshot.data != null) {
                final dossier = snapshot.data!;
                // Toujours afficher la carte (VALIDE, REJETE, EN_ATTENTE)
                // userId permet de charger le statut abonnement réel
                return DossierStatusCard(
                  status: dossier.statusDossier,
                  rejectionReason: dossier.rejectionReason,
                  userId: user.id,
                  onOpenTickets: () => setState(() => _selectedIndex = 2),
                );
              }
              return const SizedBox.shrink();
            },
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Accès rapide",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                ),
                const SizedBox(height: 15),
                _buildGrid(user),
                
                // On n'affiche l'activité récente QUE si l'utilisateur est connecté
                if (user != null) ...[
                  const SizedBox(height: 25),
                  const Text(
                    "Activité récente",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                  ),
                  const SizedBox(height: 15),
                  const RecentActivity(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        User? currentUser;
        if (state is AuthAuthenticated) {
          currentUser = state.user;
        } else if (state is AuthProfileUpdated) {
          currentUser = state.user;
        } else if (state is AuthUnauthenticated || state is AuthGuest) {
          currentUser = null;
        } else if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(body: SplashScreen());
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: _getSelectedPage(currentUser),
          bottomNavigationBar: BottomNav(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              if (index == 3 && currentUser == null) {
                _showLoginRequiredDialog();
                return;
              }
              setState(() => _selectedIndex = index);
            },
          ),
        );
      },
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Connexion requise"),
        content: const Text("Vous devez vous connecter pour accéder à cette page."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/loginPage');
            },
            child: const Text("Se Connecter", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
          ),
        ],
      ),
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
        CardMenu(title: 'Lignes', icon: Icons.directions_bus_filled, color: AppColors.darkBlue, onTap: () => Navigator.pushNamed(context, '/linesPage')),
        CardMenu(title: 'Suivi du bus', icon: Icons.map, color: AppColors.green, onTap: () => setState(() => _selectedIndex = 1)),
        CardMenu(
          title: 'Paiement',
          icon: Icons.credit_card,
          color: AppColors.darkBlue,
          onTap: () {
            if (user == null) {
              _showLoginRequiredDialog();
            } else {
              setState(() => _selectedIndex = 2);
            }
          },
        ),
        CardMenu(title: 'Réclamations', icon: Icons.chat_bubble_outline, color: AppColors.green, onTap: () => Navigator.pushNamed(context, '/claimsPage')),
        CardMenu(title: 'Objets perdus', icon: Icons.inventory_2_outlined, color: AppColors.darkBlue, onTap: () => Navigator.pushNamed(context, '/lostObjectsPage')),
      ],
    );
  }
}
