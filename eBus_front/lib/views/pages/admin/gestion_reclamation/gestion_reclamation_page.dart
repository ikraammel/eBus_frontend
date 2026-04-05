import 'package:flutter/material.dart';
import 'package:smart_bus/enums/reclamation_status.dart';
import 'package:smart_bus/views/pages/claims/claims_list.dart';

import '../../../../constants/app_colors.dart';

class GestionReclamationPage extends StatefulWidget {
  const GestionReclamationPage({super.key});

  @override
  State<GestionReclamationPage> createState() => _GestionReclamationPageState();
}

class _GestionReclamationPageState extends State<GestionReclamationPage> {
  final List<String> tabs = ["Toutes", "En attente", "Traitées"];
  final Map<String, ReclamationStatus?> statusMap = {
    "Toutes": null,
    "En attente": ReclamationStatus.EN_ATTENTE,
    "Traitées": ReclamationStatus.TRAITEE,
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue,
          title: const Text(
            "Gestion des réclamations",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            indicator: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: AppColors.darkBlue, // texte onglet actif
            unselectedLabelColor: Colors.white, // texte onglet inactif
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) {
            return ClaimsList(statusFilter: statusMap[tab]);
          }).toList(),
        ),
      ),
    );
  }
}