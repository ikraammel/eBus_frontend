import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/views/UI/personal_infos_items.dart';

import '../../../../../bloc/auth/auth_bloc.dart';
import '../../../../../bloc/auth/auth_event.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../models/user.dart';
import '../../../../../utils/app_snack_bar.dart';
import '../../../../UI/buttons/app_button.dart';
import '../../../../UI/splash_screen.dart';

class PersonalInfos extends StatefulWidget {
  const PersonalInfos({super.key});

  @override
  State<PersonalInfos> createState() => _PersonalInfosState();
}

class _PersonalInfosState extends State<PersonalInfos> {
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController emailController;
  late TextEditingController telController;
  late TextEditingController adresseController;
  late TextEditingController dateController;

  User? currentUser;

  String? selectedAbonnement;

  XFile? _newCinFile;
  XFile? _newCarteScolaireFile;

  final ImagePicker _picker = ImagePicker();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    nomController = TextEditingController();
    prenomController = TextEditingController();
    emailController = TextEditingController();
    telController = TextEditingController();
    adresseController = TextEditingController();
    dateController = TextEditingController();
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telController.dispose();
    adresseController.dispose();
    dateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isDossierRejete =>
      currentUser?.statusDossier?.toUpperCase() == "REJETE";

  bool get _isEtudiant =>
      currentUser?.typeAbonnement
              ?.toUpperCase()
              .contains('SCOLAIRE') ==
          true ||
      currentUser?.cne != null;

  Future<void> _pickFile(bool isCin) async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        if (isCin) {
          _newCinFile = file;
        } else {
          _newCarteScolaireFile = file;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdated) {
          AppSnackBar.showSuccess(
            context,
            "Profil mis à jour avec succès !",
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }

        if (state is AuthDossierResubmitted) {
          AppSnackBar.showSuccess(
            context,
            "Dossier re-soumis avec succès ! En attente de validation.",
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }

        if (state is AuthFailure) {
          String friendlyMessage = "Une erreur est survenue";

          final error = state.error.toLowerCase();

          if (error.contains("email")) {
            friendlyMessage = "Cet email est déjà utilisé.";
          } else if (error.contains("tel")) {
            friendlyMessage =
                "Ce numéro de téléphone est déjà utilisé.";
          } else if (error.contains("cin")) {
            friendlyMessage = "Cette CIN est déjà utilisée.";
          }

          AppSnackBar.showError(context, friendlyMessage);
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          currentUser = state.user;
        }

        if (currentUser == null) {
          return const SplashScreen();
        }

        nomController.text = currentUser!.nom;
        prenomController.text = currentUser!.prenom;
        emailController.text = currentUser!.email;
        telController.text = currentUser!.tel;
        adresseController.text = currentUser!.adresse;
        dateController.text = currentUser!.dateNaissance;

        selectedAbonnement =
            (currentUser!.typeAbonnement?.isNotEmpty ?? false)
                ? currentUser!.typeAbonnement
                : null;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.darkBlue,
            title: const Text(
              "Informations personnelles",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Scrollbar(
              controller: _scrollController,
              thickness: 8,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ───────── BANNIÈRE DOSSIER REJETÉ ─────────
                    if (_isDossierRejete) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Votre dossier a été rejeté. "
                                "Veuillez modifier vos informations "
                                "et re-soumettre vos documents.",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ───────── INFORMATIONS ─────────

                    PersonalInfosItems(
                      label: 'Nom',
                      controller: nomController,
                      suffixIcon: Icons.edit,
                    ),

                    PersonalInfosItems(
                      label: 'Prénom',
                      controller: prenomController,
                      suffixIcon: Icons.edit,
                    ),

                    PersonalInfosItems(
                      label: 'Email',
                      controller: emailController,
                      suffixIcon: Icons.edit,
                    ),

                    PersonalInfosItems(
                      label: 'Téléphone',
                      controller: telController,
                      suffixIcon: Icons.edit,
                    ),

                    // IMPORTANT : CIN MODIFIABLE SI REJETE

                    PersonalInfosItems(
                      label: 'CIN',
                      value: currentUser!.cin,
                      readOnly: !_isDossierRejete,
                      suffixIcon:
                          _isDossierRejete ? Icons.edit : null,
                    ),

                    PersonalInfosItems(
                      label: 'Date de naissance',
                      controller: dateController,
                      suffixIcon: Icons.calendar_month,
                      onTap: () async {
                        final DateTime? picked =
                            await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.tryParse(
                                    dateController.text,
                                  ) ??
                                  DateTime(2005),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                          locale: const Locale('fr', 'FR'),
                        );

                        if (picked != null) {
                          dateController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),

                    PersonalInfosItems(
                      label: 'Adresse',
                      controller: adresseController,
                      suffixIcon: Icons.edit,
                    ),

                    const SizedBox(height: 16),

                    PersonalInfosItems(
                      label: 'Type abonnement',
                      value: selectedAbonnement ?? "-",
                      readOnly: true,
                      suffixIcon: Icons.card_membership,
                    ),

                    // ───────── DOCUMENTS ─────────

                    if (_isDossierRejete) ...[
                      const SizedBox(height: 24),

                      Text(
                        "Documents du dossier",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildDocumentPickerRow(
                        label: "Photo CIN",
                        icon: Icons.credit_card,
                        fileName: _newCinFile?.name,
                        existingUrl: currentUser!.cinUrl,
                        onTap: () => _pickFile(true),
                        onClear: () {
                          setState(() {
                            _newCinFile = null;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      if (_isEtudiant)
                        _buildDocumentPickerRow(
                          label: "Carte scolaire",
                          icon: Icons.school,
                          fileName:
                              _newCarteScolaireFile?.name,
                          existingUrl:
                              currentUser!.carteScolaireUrl,
                          onTap: () => _pickFile(false),
                          onClear: () {
                            setState(() {
                              _newCarteScolaireFile = null;
                            });
                          },
                        ),
                    ],

                    const SizedBox(height: 30),

                    // ───────── BOUTON ─────────

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _isDossierRejete
                          ? ElevatedButton.icon(
                              onPressed: _handleResubmit,
                              icon: const Icon(Icons.send),
                              label: const Text(
                                "Enregistrer et re-soumettre",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.orange.shade700,
                                foregroundColor:
                                    Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),
                              ),
                            )
                          : AppButton(
                              text:
                                  "Enregistrer les modifications",
                              onPressed: _handleSave,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSave() {
    if (currentUser == null) return;

    context.read<AuthBloc>().add(
          AuthUpdateUserRequested(
            id: currentUser!.id,
            nom: nomController.text.trim(),
            prenom: prenomController.text.trim(),
            email: emailController.text.trim(),
            tel: telController.text.trim(),
            adresse: adresseController.text.trim(),
            dateNaissance:
                dateController.text.trim(),
          ),
        );
  }

  void _handleResubmit() {
    if (currentUser == null) return;

    context.read<AuthBloc>().add(
          AuthResubmitDossierRequested(
            userId: currentUser!.id,
            nom: nomController.text.trim(),
            prenom: prenomController.text.trim(),
            email: emailController.text.trim(),
            tel: telController.text.trim(),
            adresse: adresseController.text.trim(),
            dateNaissance:
                dateController.text.trim(),
            newCinFile: _newCinFile,
            newCarteScolaireFile:
                _newCarteScolaireFile,
          ),
        );
  }

  Widget _buildDocumentPickerRow({
    required String label,
    required IconData icon,
    required String? fileName,
    required String? existingUrl,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final bool hasNew = fileName != null;

    final bool hasExisting =
        existingUrl != null && existingUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasNew
                ? AppColors.green
                : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasNew
                    ? AppColors.green.withOpacity(0.1)
                    : AppColors.darkBlue
                        .withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: hasNew
                    ? AppColors.green
                    : AppColors.darkBlue,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    hasNew
                        ? fileName
                        : hasExisting
                            ? "Document actuel (appuyer pour changer)"
                            : "Appuyer pour sélectionner",
                    style: TextStyle(
                      fontSize: 12,
                      color: hasNew
                          ? AppColors.green
                          : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (hasNew)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              )
            else
              Icon(
                Icons.upload_file,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
}
