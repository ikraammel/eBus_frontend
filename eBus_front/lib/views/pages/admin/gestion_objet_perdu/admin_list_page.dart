import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_state.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/views/UI/objet_card.dart';

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  State<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const Color primaryColor = Color(0xFF2E7D32);
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


  List<ObjetPerdu> _filterByStatus(List<ObjetPerdu> objets, StatutObjet status) {
    return objets.where((o) => o.statut == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        // ... design AppBar identique
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
                indicatorWeight: 3,
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
            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildList(state.objets),
                  _buildList(_filterByStatus(state.objets, StatutObjet.EN_ATTENTE)),
                  _buildList(_filterByStatus(state.objets, StatutObjet.DISPONIBLE)),
                  _buildList(_filterByStatus(state.objets, StatutObjet.EN_ATTENTE_RECUPERATION)),
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
              ? () => _updateStatus(item, StatutObjet.DISPONIBLE, "Valider cette annonce et la rendre visible ?")
              : null,
          onMarquerRecupere: (item.statut == StatutObjet.DISPONIBLE || item.statut == StatutObjet.EN_ATTENTE_RECUPERATION)
              ? () => _updateStatus(item, StatutObjet.RECUPERE, "Confirmer que l'objet a été remis au propriétaire ?")
              : null,
          onTap: () {
            if (item.id == null) return;
            Navigator.pushNamed(context, '/admin-detail', arguments: item.id).then((_) => _refreshData());
          },
        );
      },
    );
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
