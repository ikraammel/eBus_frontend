import 'package:flutter/material.dart';
import 'package:smart_bus/views/pages/admin/admin_profile/admin_profile_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_reclamation/gestion_reclamation_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_objet_perdu/admin_list_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_tickets/gestion_tickets_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_dossiers/admin_dossiers_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_abonnements/admin_abonnements_page.dart';

import '../../../../constants/app_colors.dart';
import '../../../../models/user.dart';
import '../../../UI/card_menu.dart';
import '../../home/recent_activity.dart';
import '../dashboard_admin/admin_dashboard_page.dart';
import '../gestion_lignes_stations/gestion_lignes_page.dart';
import 'admin_header.dart';
import 'bottom_nav_admin.dart';
import 'card_items.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  Widget _getSelectedPage(User? user) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const AdminDashboardPage();
      case 2:
        return const GestionTicketsPage();
      case 3:
        return const AdminProfilePage();
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F26),
      bottomNavigationBar: BottomNavAdmin(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminProfilePage()),
            );
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _getSelectedPage(null),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const AdminHeader(),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardItems(),
                  const SizedBox(height: 20),
                  const Text(
                    "Gestion rapide",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F26),
                    ),
                  ),
                  _buildGrid(context, null),
                  const SizedBox(height: 20),
                  const Text(
                    "Activité récente",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const RecentActivity(isAdmin: true,),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, User? user) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        CardMenu(
          title: 'Gestion des dossiers',
          icon: Icons.folder_shared,
          color: AppColors.darkBlue,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDossiersPage())
            );
          },
        ),
        CardMenu(
          title: 'Gestion Abonnements',
          icon: Icons.card_membership,
          color: AppColors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAbonnementsPage())
            );
          },
        ),
        CardMenu(
          title: 'Réclamations',
          icon: Icons.chat_bubble_outline,
          color: AppColors.green,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GestionReclamationPage())
            );
          },
        ),
        CardMenu(
          title: 'Objets perdus',
          icon: Icons.inventory_2_outlined,
          color: AppColors.darkBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminListPage()),
            );
          },
        ),
      ],
    );
  }
}
