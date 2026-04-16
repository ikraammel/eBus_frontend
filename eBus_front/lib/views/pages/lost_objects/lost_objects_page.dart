import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_state.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/views/pages/lost_objects/declare_lost_object_page.dart';
import 'package:smart_bus/views/UI/objet_card.dart';

class LostObjectsPage extends StatefulWidget {
  final bool isAdmin;
  const LostObjectsPage({super.key, this.isAdmin = false});

  @override
  State<LostObjectsPage> createState() => _LostObjectsPageState();
}

class _LostObjectsPageState extends State<LostObjectsPage> {
  String _search = '';
  StatutObjet? _filtreStatut;

  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF43A047);
  static const Color bgColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();

    context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
  }

  List<ObjetPerdu> _getFilteredObjets(List<ObjetPerdu> objets) {
    return objets.where((o) {
      final matchSearch =
          (o.nom ?? '').toLowerCase().contains(_search.toLowerCase());
      final matchStatut =
          _filtreStatut == null || o.statut == _filtreStatut;
      return matchSearch && matchStatut;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, accentColor],
            ),
          ),
        ),
        title: Text(
          widget.isAdmin
              ? 'Espace Administration'
              : 'Objets Perdus & Trouvés',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      floatingActionButton: widget.isAdmin
          ? null
          : FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeclareObjetPage()),
                );
                // Rafraîchir après ajout
                if (mounted) context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),

      body: Column(
        children: [

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, accentColor],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 25, top: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un objet...',
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _chip("Tous", null),
                      _chip("Disponibles", StatutObjet.DISPONIBLE),
                      _chip("En attente", StatutObjet.EN_ATTENTE),
                      _chip("Récupérés", StatutObjet.RECUPERE),
                    ],
                  ),
                ),
              ],
            ),
          ),


          Expanded(
            child: BlocBuilder<ObjetPerduBloc, ObjetPerduState>(
              builder: (context, state) {
                if (state is ObjetPerduLoading) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }

                if (state is ObjetPerduLoadSuccess) {
                  final list = _getFilteredObjets(state.objets);

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
                    },
                    child: list.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text("Aucun objet trouvé")),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              final objet = list[i];
                              return ObjetCard(
                                objet: objet,
                                isAdmin: widget.isAdmin,
                                isOwner: false,
                                onTap: () {
                                  if (objet.id == null) return;
                                  // Navigation vers le détail (Utilisateur ou Admin selon la route)
                                  Navigator.pushNamed(
                                    context,
                                    widget.isAdmin ? '/admin-detail' : '/detail',
                                    arguments: objet.id, // On passe l'ID pour cohérence avec AdminDetailPage
                                  ).then((_) {
                                    if (mounted) {
                                      context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
                                    }
                                  });
                                },
                                onMarquerRecupere: widget.isAdmin
                                    ? () => _validerAction(objet)
                                    : null,
                              );
                            },
                          ),
                  );
                }

                if (state is ObjetPerduFailure) {
                  return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                }

                return const Center(child: Text("Commencez par charger les données"));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, StatutObjet? statut) {
    final selected = _filtreStatut == statut;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: selected ? primaryColor : Colors.white)),
        selected: selected,
        onSelected: (_) {
          setState(() => _filtreStatut = statut);
        },
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.2),
        checkmarkColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _validerAction(ObjetPerdu objet) async {
    if (objet.id == null) return;


    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Marquer cet objet comme récupéré ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Confirmer")),
        ],
      ),
    );

    if (confirm == true) {
      context.read<ObjetPerduBloc>().add(
        UpdateObjetPerduStatus(
          id: objet.id!,
          newStatus: StatutObjet.RECUPERE.name,
        ),
      );

    }
  }
}
