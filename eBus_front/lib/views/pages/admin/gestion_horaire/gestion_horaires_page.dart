import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/horaire/horaire_bloc.dart';
import 'package:smart_bus/bloc/horaire/horaire_event.dart';
import 'package:smart_bus/bloc/horaire/horaire_state.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/horaire.dart';
import 'package:smart_bus/models/ligne.dart';
import 'package:smart_bus/services/horaire_service.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';
import 'package:smart_bus/views/pages/admin/gestion_horaire/horaire_form_dialog.dart';

class GestionHorairesPage extends StatefulWidget {
  const GestionHorairesPage({super.key});

  @override
  State<GestionHorairesPage> createState() => _GestionHorairesPageState();
}

class _GestionHorairesPageState extends State<GestionHorairesPage> {
  Ligne? _selectedLigne;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HoraireBloc(HoraireService()),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.darkBlue,
            title: const Text(
              "Gestion des horaires",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              if (_selectedLigne != null)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showHoraireForm(context, null),
                ),
            ],
          ),
          body: Column(
            children: [
              // Sélecteur de ligne
              _LigneSelector(
                selectedLigne: _selectedLigne,
                onLigneSelected: (ligne) {
                  setState(() => _selectedLigne = ligne);
                  if (ligne != null) {
                    context
                        .read<HoraireBloc>()
                        .add(LoadHoraires(ligne.id!));
                  }
                },
              ),

              // Liste des horaires
              Expanded(
                child: _selectedLigne == null
                    ? const _EmptySelection()
                    : BlocConsumer<HoraireBloc, HoraireState>(
                  listener: (context, state) {
                    if (state is HoraireCreated) {
                      AppSnackBar.showSuccess(
                          context, "Horaire ajouté avec succès");
                      context
                          .read<HoraireBloc>()
                          .add(LoadHoraires(_selectedLigne!.id!));
                    } else if (state is HoraireUpdated) {
                      AppSnackBar.showSuccess(
                          context, "Horaire modifié avec succès");
                      context
                          .read<HoraireBloc>()
                          .add(LoadHoraires(_selectedLigne!.id!));
                    } else if (state is HoraireDeleted) {
                      AppSnackBar.showSuccess(
                          context, "Horaire supprimé");
                      context
                          .read<HoraireBloc>()
                          .add(LoadHoraires(_selectedLigne!.id!));
                    } else if (state is HoraireError) {
                      AppSnackBar.showError(context, state.error);
                    }
                  },
                  builder: (context, state) {
                    if (state is HoraireLoading ||
                        state is HoraireInitial) {
                      return const SplashScreen();
                    }

                    final horaires =
                        context.read<HoraireBloc>().horaires;

                    if (horaires.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule,
                                size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text("Aucun horaire pour cette ligne",
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showHoraireForm(context, null),
                              icon: const Icon(Icons.add),
                              label: const Text("Ajouter un horaire"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: horaires.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (_, i) => _HoraireCard(
                        horaire: horaires[i],
                        onEdit: () =>
                            _showHoraireForm(context, horaires[i]),
                        onDelete: () => _confirmDelete(
                            context, horaires[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showHoraireForm(BuildContext context, Horaire? horaire) {
    showDialog(
      context: context,
      builder: (_) => HoraireFormDialog(
        horaire: horaire,
        ligneId: _selectedLigne!.id!,
        onSave: (h) {
          if (horaire == null) {
            context.read<HoraireBloc>().add(CreateHoraire(h));
          } else {
            context.read<HoraireBloc>().add(UpdateHoraire(horaire.id!, h));
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Horaire horaire) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer l'horaire"),
        content: Text(
            "Supprimer l'horaire ${horaire.heureDepart} → ${horaire.heureArrivee} ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              context.read<HoraireBloc>().add(DeleteHoraire(horaire.id!));
              Navigator.pop(context);
            },
            child:
            const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Sélecteur de ligne ───────────────────────────────────────────────────────

class _LigneSelector extends StatelessWidget {
  final Ligne? selectedLigne;
  final ValueChanged<Ligne?> onLigneSelected;

  const _LigneSelector({
    required this.selectedLigne,
    required this.onLigneSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LigneBloc, LigneState>(
      builder: (context, state) {
        if (state is! LigneLoaded) {
          return const SizedBox(
              height: 56,
              child: Center(child: CircularProgressIndicator()));
        }

        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Ligne>(
              isExpanded: true,
              hint: const Text("Sélectionner une ligne"),
              value: selectedLigne,
              items: state.lignes
                  .map((l) => DropdownMenuItem(
                value: l,
                child: Text(
                  "Ligne ${l.numero}  –  ${l.startPoint} → ${l.endPoint}",
                  overflow: TextOverflow.ellipsis,
                ),
              ))
                  .toList(),
              onChanged: onLigneSelected,
            ),
          ),
        );
      },
    );
  }
}

// ─── Carte horaire ────────────────────────────────────────────────────────────

class _HoraireCard extends StatelessWidget {
  final Horaire horaire;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HoraireCard({
    required this.horaire,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule,
                color: AppColors.darkBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      horaire.heureDepart,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward,
                          size: 16, color: Colors.grey),
                    ),
                    Text(
                      horaire.heureArrivee,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      horaire.jours,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.darkBlue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── État vide ────────────────────────────────────────────────────────────────

class _EmptySelection extends StatelessWidget {
  const _EmptySelection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_outlined,
              size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Sélectionnez une ligne\npour voir ses horaires",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}