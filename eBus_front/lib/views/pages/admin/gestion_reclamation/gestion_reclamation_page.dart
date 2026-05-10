import 'package:flutter/material.dart';
import 'package:smart_bus/enums/claims_sort_type.dart';
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

  ClaimsSortType _sortType = ClaimsSortType.defaultOrder;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Gestion des réclamations",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton<ClaimsSortType>(
              icon: const Icon(Icons.sort, color: Colors.white),
              onSelected: (type) => setState(() => _sortType = type),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ClaimsSortType.latest,
                  child: Text("Plus récentes"),
                ),
                const PopupMenuItem(
                  value: ClaimsSortType.defaultOrder,
                  child: Text("Par défaut"),
                ),
              ],
            )
          ],
          bottom: TabBar(
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            indicator: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) {
            return ClaimsList(
              statusFilter: statusMap[tab],
              sortType: _sortType,
            );
          }).toList(),
        ),
      ),
    );
  }
}
