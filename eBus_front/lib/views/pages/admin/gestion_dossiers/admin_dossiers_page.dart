import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import '../../../../bloc/admin_dossier/admin_dossier_bloc.dart';
import '../../../../bloc/admin_dossier/admin_dossier_event.dart';
import '../../../../bloc/admin_dossier/admin_dossier_state.dart';
import '../../../../constants/app_colors.dart';
import '../../../../models/dossier.dart';
import '../../../../services/admin_dossier_service.dart';
import '../../../UI/splash_screen.dart';
import 'admin_dossier_detail_page.dart';

class AdminDossiersPage extends StatelessWidget {
  const AdminDossiersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminDossierBloc(
        dossierService: AdminDossierService(),
      )..add(LoadDossiers()),
      child: const AdminDossiersView(),
    );
  }
}

class AdminDossiersView extends StatefulWidget {
  const AdminDossiersView({super.key});

  @override
  State<AdminDossiersView> createState() => _AdminDossiersViewState();
}

class _AdminDossiersViewState extends State<AdminDossiersView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRejectDialog(BuildContext context, Dossier dossier) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Rejeter le dossier",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Veuillez indiquer la raison du rejet :",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 4,
                minLines: 2,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Ex: Documents incomplets, informations manquantes...",
                  labelText: "Motif de refus",
                  labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  helperText: "Ce motif sera visible par l'utilisateur",
                  helperMaxLines: 1,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                "Annuler",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Veuillez saisir un motif de refus"),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                context.read<AdminDossierBloc>().add(
                  RejeterDossierEvent(dossier.id, reason),
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Confirmer le rejet",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        );
      },
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
    required Color confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Confirmer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, 
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue,
          title: const Text(
            "Gestion des Dossiers",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Tous"),
              Tab(text: "En attente"),
              Tab(text: "Validés"),
              Tab(text: "Rejetés"),
            ],
          ),
        ),
        body: BlocConsumer<AdminDossierBloc, AdminDossierState>(
          listener: (context, state) {
            if (state is AdminDossierActionSuccess) {
              AppSnackBar.showSuccess(context, state.message);
            } else if (state is AdminDossierError) {
              AppSnackBar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is AdminDossierLoading) {
              return const SplashScreen();
            }

            if (state is AdminDossierLoaded) {
              final allDossiers = _filterDossiers(state.dossiers);

              return Column(
                children: [
                  _buildSearchField(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildDossierList(context, allDossiers),
                        _buildDossierList(
                          context,
                          allDossiers
                              .where((d) => d.statusDossier == "EN_ATTENTE")
                              .toList(),
                        ),
                        _buildDossierList(
                          context,
                          allDossiers
                              .where((d) => d.statusDossier == "VALIDE")
                              .toList(),
                        ),
                        _buildDossierList(
                          context,
                          allDossiers
                              .where((d) => d.statusDossier == "REJETE")
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (state is AdminDossierError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        state.message.replaceFirst("Exception: ", ""),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<AdminDossierBloc>().add(LoadDossiers()),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Reessayer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDossierList(BuildContext context, List<Dossier> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text("Aucun dossier trouvé", style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminDossierBloc>().add(LoadDossiers());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildDossierCard(context, list[index]);
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 8),
      color: const Color(0xFFF8F9FB),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Rechercher par nom, prenom, CIN, email, telephone...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  List<Dossier> _filterDossiers(List<Dossier> dossiers) {
    final query = _normalizeSearch(_searchQuery);
    if (query.isEmpty) return dossiers;

    return dossiers.where((dossier) {
      final searchable = _normalizeSearch([
        dossier.nom,
        dossier.prenom,
        dossier.email,
        dossier.tel,
        dossier.adresse,
        dossier.typeAbonnement,
        dossier.cin,
        dossier.cne,
        dossier.statusDossier,
        dossier.rejectionReason,
      ].whereType<String>().join(' '));

      return searchable.contains(query);
    }).toList();
  }

  String _normalizeSearch(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ç', 'c');
  }

  Widget _buildDossierCard(BuildContext context, Dossier dossier) {
    final isEtudiant = _isEtudiantDossier(dossier);
    Color statusColor;
    switch (dossier.statusDossier) {
      case "VALIDE": statusColor = Colors.green; break;
      case "REJETE": statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDossierDetailPage(dossier: dossier),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
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
                      "${dossier.prenom} ${dossier.nom}",
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
                      dossier.statusDossier,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (dossier.cin != null) _buildInfoRow(Icons.badge, "CIN: ${dossier.cin}"),
              if (isEtudiant && dossier.cne != null && dossier.cne!.isNotEmpty)
                _buildInfoRow(Icons.school, "CNE: ${dossier.cne}"),
              
              if (dossier.dateDebutAbonnement != null)
                _buildInfoRow(Icons.calendar_today, "Début: ${dossier.dateDebutAbonnement}"),
              if (dossier.dateFinAbonnement != null)
                _buildInfoRow(Icons.event_available, "Fin: ${dossier.dateFinAbonnement}"),

              const Divider(height: 30),
              
              Row(
                children: [
                  if (dossier.statusDossier != "REJETE")
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context, dossier),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text("Rejeter", style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      ),
                    ),
                  
                  if (dossier.statusDossier != "REJETE" && dossier.statusDossier != "VALIDE") const SizedBox(width: 15),

                  if (dossier.statusDossier != "VALIDE")
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showConfirmDialog(
                          context: context,
                          title: "Valider le dossier",
                          content: "Voulez-vous valider ce dossier ? L'abonnement passera au statut VALIDÉ.",
                          confirmColor: Colors.green,
                          onConfirm: () => context.read<AdminDossierBloc>().add(ValiderDossierEvent(dossier.id)),
                        ),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text("Valider", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isEtudiantDossier(Dossier dossier) {
    final type = (dossier.typeAbonnement ?? "")
        .toUpperCase()
        .trim()
        .replaceAll("É", "E")
        .replaceAll("È", "E")
        .replaceAll("Ê", "E");
    return type.contains("SCOLAIRE") ||
        type.contains("ETUDIANT") ||
        (dossier.cne != null && dossier.cne!.isNotEmpty);
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
