import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/admin_abonnement/admin_abonnement_bloc.dart';
import '../../../../bloc/admin_abonnement/admin_abonnement_event.dart';
import '../../../../bloc/admin_abonnement/admin_abonnement_state.dart';
import '../../../../constants/app_colors.dart';
import '../../../../models/abonnement.dart';
import '../../../../services/admin_abonnement_service.dart';
import '../../../UI/splash_screen.dart';

class AdminAbonnementsPage extends StatelessWidget {
  const AdminAbonnementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminAbonnementBloc(
        abonnementService: AdminAbonnementService(),
      )..add(LoadAbonnements()),
      child: const AdminAbonnementsView(),
    );
  }
}

class AdminAbonnementsView extends StatefulWidget {
  const AdminAbonnementsView({super.key});

  @override
  State<AdminAbonnementsView> createState() => _AdminAbonnementsViewState();
}

class _AdminAbonnementsViewState extends State<AdminAbonnementsView> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  String _formatTitle(String title) {
    if (title.isEmpty) return title;
    String formatted = title.replaceAll('_', ' ').toLowerCase();
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  List<Abonnement> _applySearch(List<Abonnement> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((a) {
      final query = _searchQuery.toLowerCase();
      final fullName = "${a.nom} ${a.prenom}".toLowerCase();
      final email = a.email.toLowerCase();
      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Rechercher un abonné...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                "Monitoring Abonnements",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = "";
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child: BlocBuilder<AdminAbonnementBloc, AdminAbonnementState>(
              builder: (context, state) {
                if (state is AdminAbonnementLoading) {
                  return const SplashScreen();
                }

                if (state is AdminAbonnementLoaded) {
                  final list = _applySearch(state.filteredAbonnements);
                  
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 60, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            _searchQuery.isEmpty ? "Aucun abonnement trouvé" : "Aucun résultat pour \"$_searchQuery\"",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminAbonnementBloc>().add(LoadAbonnements());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return _buildAbonnementCard(context, list[index]);
                      },
                    ),
                  );
                }

                if (state is AdminAbonnementError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return BlocBuilder<AdminAbonnementBloc, AdminAbonnementState>(
      builder: (context, state) {
        String currentFilter = 'TOUS';
        if (state is AdminAbonnementLoaded) {
          currentFilter = state.currentFilter;
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              _filterChip(context, "Tous", 'TOUS', currentFilter),
              _filterChip(context, "Actifs", 'ACTIF', currentFilter),
              _filterChip(context, "En attente", 'EN_ATTENTE', currentFilter),
              _filterChip(context, "Expirés", 'EXPIRE', currentFilter),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(BuildContext context, String label, String value, String current) {
    final isSelected = value == current;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          context.read<AdminAbonnementBloc>().add(FilterAbonnementEvent(value));
        },
        selectedColor: AppColors.darkBlue.withValues(alpha: 0.2),
        checkmarkColor: AppColors.darkBlue,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.darkBlue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAbonnementCard(BuildContext context, Abonnement a) {
    Color statusColor;
    switch (a.status) {
      case 'ACTIF':
        statusColor = Colors.green;
        break;
      case 'EXPIRE':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${a.prenom} ${a.nom}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    a.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.card_membership, "Type: ${_formatTitle(a.typeNom)}"),
            _buildInfoRow(Icons.calendar_today, "Début: ${a.dateDebut}"),
            _buildInfoRow(Icons.event_available, "Fin: ${a.dateFin}"),
            _buildInfoRow(Icons.email_outlined, "Email: ${a.email}"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }
}
