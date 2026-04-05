import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/ligne/ligne_bloc.dart';
import '../../../../bloc/ligne/ligne_state.dart';
import '../../../../models/Ligne.dart';
import '../../../UI/personal_infos_items.dart';

class ClaimForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController objetController;
  final TextEditingController descriptionController;
  final Ligne? selectedLigne;
  final ValueChanged<Ligne?> onLigneChanged;

  const ClaimForm({
    super.key,
    required this.formKey,
    required this.objetController,
    required this.descriptionController,
    required this.selectedLigne,
    required this.onLigneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonalInfosItems(label: 'Objet', controller: objetController),
          PersonalInfosItems(label: 'Description', controller: descriptionController),
          const Text("Ligne concernée"),
          const SizedBox(height: 8),
          BlocBuilder<LigneBloc, LigneState>(
            builder: (context, state) {
              List<Ligne> lignes = [];
              bool isLoading = false;

              if (state is LigneLoaded) lignes = state.lignes;
              if (state is LigneLoading) isLoading = true;
              if (state is LigneError) {
                return Text(state.error, style: const TextStyle(color: Colors.red));
              }

              return DropdownButtonFormField<int>(
                value: selectedLigne?.id,
                items: lignes
                    .map((ligne) => DropdownMenuItem(
                  value: ligne.id,
                  child: Text("${ligne.numero}"),
                ))
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                  onLigneChanged(lignes.firstWhere((l) => l.id == value));
                },
                hint: isLoading
                    ? Row(
                  children: const [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text("Chargement..."),
                  ],
                )
                    : const Text("Sélectionner une ligne"),
                validator: (value) => value == null ? "Veuillez sélectionner une ligne" : null,
              );
            },
          ),
        ],
      ),
    );
  }
}