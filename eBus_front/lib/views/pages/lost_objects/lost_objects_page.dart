import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_state.dart';
import 'package:smart_bus/enums/claims_sort_type.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/models/user.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/views/pages/lost_objects/declare_lost_object_page.dart';
import 'package:smart_bus/views/UI/objet_card.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';
import 'package:smart_bus/constants/app_colors.dart';

class LostObjectsPage extends StatefulWidget {
  final bool isAdmin;
  const LostObjectsPage({super.key, this.isAdmin = false});

  @override
  State<LostObjectsPage> createState() => _LostObjectsPageState();
}

class _LostObjectsPageState extends State<LostObjectsPage> {
  String _search = '';
  StatutObjet? _filtreStatut;
  ClaimsSortType _sortType = ClaimsSortType.defaultOrder;

  static const Color primaryGreen = AppColors.green;
  static const Color lightBg = Color(0xFFF8F9FB);

  @override
  void initState() {
    super.initState();
    context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
  }

  List<ObjetPerdu> _getFilteredObjets(List<ObjetPerdu> objets) {
    final filtered = objets.where((o) {
      final matchSearch = (o.nom ?? '').toLowerCase().contains(_search.toLowerCase());
      final matchStatut = _filtreStatut == null || o.statut == _filtreStatut;
      return matchSearch && matchStatut;
    }).toList();

    if (_sortType == ClaimsSortType.latest) {
      filtered.sort((a, b) => b.dateDeclaration.compareTo(a.dateDeclaration));
    }
    
    return filtered;
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer l\'annonce'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette annonce ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<ObjetPerduBloc>().add(DeleteObjetPerdu(id: id));
      AppSnackBar.showSuccess(context, "Annonce supprimée");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.green,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.isAdmin ? 'Gestion Objets' : 'Objets Perdus',
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
      ),
      floatingActionButton: widget.isAdmin
          ? null
          : FloatingActionButton.extended(
              backgroundColor: primaryGreen,
              elevation: 4,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeclareObjetPage()),
                );
                if (mounted) context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
              },
              icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
              label: const Text("Déclarer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: AppColors.darkBlue),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un objet...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: primaryGreen),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip("Tous", null),
                      _buildFilterChip("Disponibles", StatutObjet.DISPONIBLE),
                      _buildFilterChip("En attente", StatutObjet.EN_ATTENTE),
                      _buildFilterChip("Récupérés", StatutObjet.RECUPERE),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                User? user;
                if (authState is AuthAuthenticated) user = authState.user;
                if (authState is AuthProfileUpdated) user = authState.user;
                
                final String? currentUserId = user?.id.toString();

                return BlocBuilder<ObjetPerduBloc, ObjetPerduState>(
                  builder: (context, state) {
                    if (state is ObjetPerduLoading) {
                      return const SplashScreen();
                    }

                    if (state is ObjetPerduLoadSuccess) {
                      final list = _getFilteredObjets(state.objets);

                      if (list.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async => context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus()),
                          child: ListView(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 100, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Aucun résultat trouvé",
                                      style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus()),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: list.length,
                          itemBuilder: (context, i) {
                            final objet = list[i];
                            final isOwner = currentUserId != null && objet.userId?.toString() == currentUserId;

                            return Hero(
                              tag: 'objet_card_${objet.id}',
                              child: ObjetCard(
                                objet: objet,
                                isAdmin: widget.isAdmin,
                                isOwner: isOwner,
                                onDelete: (isOwner || widget.isAdmin) && objet.id != null 
                                  ? () => _confirmDelete(objet.id!) 
                                  : null,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    widget.isAdmin ? '/admin-detail' : '/detail',
                                    arguments: objet,
                                  ).then((_) {
                                    if (mounted) context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }

                    if (state is ObjetPerduFailure) {
                      return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                    }

                    return const SplashScreen();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, StatutObjet? statut) {
    final bool isSelected = _filtreStatut == statut;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => setState(() => _filtreStatut = statut),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : const Color(0xFFF1F7FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primaryGreen : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.darkBlue,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
