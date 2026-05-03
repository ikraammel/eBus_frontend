import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/bloc/claims/claims_bloc.dart';
import 'package:smart_bus/bloc/claims/claims_event.dart';
import 'package:smart_bus/bloc/claims/claims_state.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/ligne.dart';
import 'package:smart_bus/models/reclamation.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/views/UI/buttons/app_button.dart';
import 'claim_form.dart';

class NewClaimPage extends StatefulWidget {
  const NewClaimPage({super.key});

  @override
  State<NewClaimPage> createState() => _NewClaimPageState();
}

class _NewClaimPageState extends State<NewClaimPage> {
  final _formKey = GlobalKey<FormState>();
  final _objetController = TextEditingController();
  final _descriptionController = TextEditingController();
  Ligne? _selectedLigne;

  @override
  void initState() {
    super.initState();
    final ligneState = context.read<LigneBloc>().state;
    if (ligneState is! LigneLoaded) {
      context.read<LigneBloc>().add(LoadLignes());
    }
  }

  void _submitClaim() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLigne == null) {
      AppSnackBar.showError(context, "Veuillez sélectionner une ligne");
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      AppSnackBar.showError(context, "Utilisateur non authentifié");
      return;
    }

    final reclamation = Reclamation(
      titre: _objetController.text,
      description: _descriptionController.text,
      ligneId: _selectedLigne!.id,
      userId: authState.user.id,
      date: DateTime.now(),
    );

    // 🔥 envoyer au bloc
    context.read<ClaimsBloc>().add(CreateClaim(reclamation));

    // 🔥 revenir DIRECT
    Navigator.pop(context);

    AppSnackBar.showSuccess(context, "Réclamation envoyée");
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClaimsBloc, ClaimsState>(
      listener: (context, state) {
        if(state is ClaimsCreated){
          Navigator.pop(context);
          AppSnackBar.showSuccess(context, "Réclamation envoyée avec succès");
          context.read<ClaimsBloc>().add(LoadClaims());
        }else if(state is ClaimsError){
          AppSnackBar.showError(context, state.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue,
          title: const Text("Nouvelle réclamation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ClaimForm(
                  formKey: _formKey,
                  objetController: _objetController,
                  descriptionController: _descriptionController,
                  selectedLigne: _selectedLigne,
                  onLigneChanged: (ligne) => setState(() => _selectedLigne = ligne),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 33), // ici tu règles la hauteur
              child: AppButton(
              text: "Soumettre la réclamation",
              onPressed: _submitClaim,
              icon: Icons.send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
