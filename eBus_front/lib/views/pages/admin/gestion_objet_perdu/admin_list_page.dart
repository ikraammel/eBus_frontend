import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_state.dart';
import 'package:smart_bus/enums/claims_sort_type.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/views/UI/objet_card.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  ClaimsSortType _sortType = ClaimsSortType.defaultOrder;

  static const Color primaryColor = AppColors.green;
  static const Color secondaryColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _refreshData();
  }

  void _refreshData() {
    context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }


  List<ObjetPerdu> _applySort(List<ObjetPerdu> objets) {
    final list = List<ObjetPerdu>.from(objets);
    if (_sortType == ClaimsSortType.latest) {
      list.sort((a, b) => b.dateDeclaration.compareTo(a.dateDeclaration));
    }
    return list;
  }

  List<ObjetPerdu> _filterByStatus(List<ObjetPerdu> objets, StatutObjet status) {
    return objets.where((o) => o.statut == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Gestion Objets Perdus",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<ClaimsSortType>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (type) => setState(() => _sortType = type),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ClaimsSortType.latest,
                child: Text("Plus récents"),
              ),
              const PopupMenuItem(
                value: ClaimsSortType.defaultOrder,
                child: Text("Par défaut"),
              ),
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: BlocBuilder<ObjetPerduBloc, ObjetPerduState>(
            builder: (context, state) {
              int total = 0, enAttente = 0, dispo = 0, demande = 0;

              if (state is ObjetPerduLoadSuccess) {
                total = state.objets.length;
                enAttente = state.objets.where((o) => o.statut == StatutObjet.EN_ATTENTE).length;
                dispo = state.objets.where((o) => o.statut == StatutObjet.DISPONIBLE).length;
                demande = state.objets.where((o) => o.statut == StatutObjet.EN_ATTENTE_RECUPERATION).length;
              }

              return TabBar(
                controller: _tabs,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Tous ($total)'),
                  Tab(text: 'À Valider ($enAttente)'),
                  Tab(text: 'Dispos ($dispo)'),
                  Tab(text: 'Demandes ($demande)'),
                ],
              );
            },
          ),
        ),
      ),
      body: BlocBuilder<ObjetPerduBloc, ObjetPerduState>(
        builder: (context, state) {
          if (state is ObjetPerduLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (state is ObjetPerduLoadSuccess) {
            final allItems = _applySort(state.objets);
            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildList(allItems),
                  _buildList(_filterByStatus(allItems, StatutObjet.EN_ATTENTE)),
                  _buildList(_filterByStatus(allItems, StatutObjet.DISPONIBLE)),
                  _buildList(_filterByStatus(allItems, StatutObjet.EN_ATTENTE_RECUPERATION)),
                ],
              ),
            );
          }

          if (state is ObjetPerduFailure) {
            return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(List<ObjetPerdu> items) {
    if (items.isEmpty) {

      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(child: Text("Aucun objet dans cette catégorie")),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        return ObjetCard(
          objet: item,
          isAdmin: true,
          onMarquerDisponible: item.statut == StatutObjet.EN_ATTENTE
              ? () => _updateStatus(item, StatutObjet.DISPONIBLE, "Valider cette annonce et la rendre disponible ?")
              : null,
          onMarquerRecupere: (item.statut == StatutObjet.DISPONIBLE || item.statut == StatutObjet.EN_ATTENTE_RECUPERATION)
              ? () => _updateStatus(item, StatutObjet.RECUPERE, "Confirmer que l'objet a été remis au propriétaire ?")
              : null,
          onDelete: () => _confirmDelete(item.id!),
          onTap: () {
            if (item.id == null) return;
            Navigator.pushNamed(context, '/admin-detail', arguments: item).then((_) => _refreshData());
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Supprimer l\'annonce'),
        content: const Text('Voulez-vous supprimer définitivement cet objet ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<ObjetPerduBloc>().add(DeleteObjetPerdu(id: id));
      AppSnackBar.showSuccess(context, "Objet supprimé");
    }
  }

  Future<void> _updateStatus(ObjetPerdu objet, StatutObjet nouveauStatut, String message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Action Admin'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );

    if (confirm == true && objet.id != null) {

      context.read<ObjetPerduBloc>().add(
        UpdateObjetPerduStatus(id: objet.id!, newStatus: nouveauStatut.name),
      );


      Future.delayed(const Duration(milliseconds: 300), () => _refreshData());
    }
  }
}
