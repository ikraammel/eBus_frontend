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

class AdminDossiersView extends StatelessWidget {
  const AdminDossiersView({super.key});

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
              final allDossiers = state.dossiers;

              return TabBarView(
                children: [
                  _buildDossierList(context, allDossiers), 
                  _buildDossierList(context, allDossiers.where((d) => d.statusDossier == "EN_ATTENTE").toList()), 
                  _buildDossierList(context, allDossiers.where((d) => d.statusDossier == "VALIDE").toList()), 
                  _buildDossierList(context, allDossiers.where((d) => d.statusDossier == "REJETE").toList()), 
                ],
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

  Widget _buildDossierCard(BuildContext context, Dossier dossier) {
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
              if (dossier.cne != null) _buildInfoRow(Icons.school, "CNE: ${dossier.cne}"),
              
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
                        onPressed: () => _showConfirmDialog(
                          context: context,
                          title: "Rejeter le dossier",
                          content: "Voulez-vous rejeter ce dossier ? L'abonnement passera au statut REJETÉ.",
                          confirmColor: Colors.red,
                          onConfirm: () => context.read<AdminDossierBloc>().add(RejeterDossierEvent(dossier.id)),
                        ),
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
