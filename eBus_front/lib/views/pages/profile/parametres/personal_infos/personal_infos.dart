import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/views/UI/personal_infos_items.dart';
import 'package:smart_bus/services/ticket_service.dart';
import 'package:smart_bus/models/abonnement.dart';

import '../../../../../bloc/auth/auth_bloc.dart';
import '../../../../../bloc/auth/auth_event.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../models/user.dart';
import '../../../../../utils/app_snack_bar.dart';
import '../../../../UI/buttons/app_button.dart';
import '../../../../UI/splash_screen.dart';

class PersonalInfos extends StatefulWidget {
  final String? rejectionReason;
  const PersonalInfos({super.key, this.rejectionReason});

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
  late TextEditingController cinController;
  late TextEditingController cneController;

  User? currentUser;
  String? selectedAbonnement;

  XFile? _newPhotoFile;
  XFile? _newCinPhotoFile;
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
    cinController = TextEditingController();
    cneController = TextEditingController();
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telController.dispose();
    adresseController.dispose();
    dateController.dispose();
    cinController.dispose();
    cneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isDossierRejete {
    final s = currentUser?.statusDossier?.toUpperCase().trim() ?? "";
    return s == "REJETE" || s == "REJETÉ";
  }

  bool get _isEtudiant =>
      currentUser?.typeAbonnement?.toUpperCase().contains('SCOLAIRE') == true ||
          currentUser?.cne != null;

  Future<void> _pickImage(Function(XFile) onPicked) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) setState(() => onPicked(file));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdated) {
          AppSnackBar.showSuccess(context, "Profil mis à jour avec succès !");
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
        if (state is AuthDossierResubmitted) {
          AppSnackBar.showSuccess(
              context, "Dossier re-soumis avec succès ! En attente de validation.");
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
        if (state is AuthFailure) {
          String msg = "Une erreur est survenue";
          final err = state.error.toLowerCase();
          if (err.contains("email")) msg = "Cet email est déjà utilisé.";
          else if (err.contains("tel")) msg = "Ce numéro de téléphone est déjà utilisé.";
          else if (err.contains("cin")) msg = "Cette CIN est déjà utilisée.";
          AppSnackBar.showError(context, msg);
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) currentUser = state.user;
        if (currentUser == null) return const SplashScreen();

        nomController.text = currentUser!.nom;
        prenomController.text = currentUser!.prenom;
        emailController.text = currentUser!.email;
        telController.text = currentUser!.tel;
        adresseController.text = currentUser!.adresse;
        dateController.text = currentUser!.dateNaissance;
        cinController.text = currentUser!.cin;
        cneController.text = currentUser!.cne ?? '';

        selectedAbonnement = (currentUser!.typeAbonnement?.isNotEmpty ?? false)
            ? currentUser!.typeAbonnement
            : null; // peut être null si cache pas à jour

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.darkBlue,
            title: const Text(
              "Informations personnelles",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

                    // ───────── BANNIÈRE REJET ─────────
                    if (_isDossierRejete) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Votre dossier a été rejeté. Veuillez modifier vos informations et re-soumettre vos documents.",
                                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                  ),
                                  if (widget.rejectionReason != null && widget.rejectionReason!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      "Motif : ${widget.rejectionReason}",
                                      style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ───────── PHOTO DE PROFIL ─────────
                    const Text(
                      "Photo de profil",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _newPhotoFile != null
                                ? FileImage(File(_newPhotoFile!.path))
                                : (currentUser!.photoUrl != null && currentUser!.photoUrl!.isNotEmpty
                                ? NetworkImage(currentUser!.photoUrl!) as ImageProvider
                                : null),
                            child: (_newPhotoFile == null &&
                                (currentUser!.photoUrl == null || currentUser!.photoUrl!.isEmpty))
                                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                : null,
                          ),
                          if (_isDossierRejete)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _pickImage((f) => _newPhotoFile = f),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ───────── CHAMPS TEXTE ─────────
                    PersonalInfosItems(label: 'Nom', controller: nomController, suffixIcon: Icons.edit),
                    PersonalInfosItems(label: 'Prénom', controller: prenomController, suffixIcon: Icons.edit),
                    PersonalInfosItems(label: 'Email', controller: emailController, suffixIcon: Icons.edit),
                    PersonalInfosItems(label: 'Téléphone', controller: telController, suffixIcon: Icons.edit),
                    PersonalInfosItems(
                      label: 'CIN',
                      controller: _isDossierRejete ? cinController : null,
                      value: _isDossierRejete ? null : currentUser!.cin,
                      readOnly: !_isDossierRejete,
                      suffixIcon: _isDossierRejete ? Icons.edit : null,
                    ),
                    // ─── CNE (visible si étudiant ou si valeur existante) ───
                    if (_isEtudiant || (currentUser!.cne != null && currentUser!.cne!.isNotEmpty))
                      PersonalInfosItems(
                        label: 'CNE',
                        controller: _isDossierRejete ? cneController : null,
                        value: _isDossierRejete ? null : (currentUser!.cne ?? '-'),
                        readOnly: !_isDossierRejete,
                        suffixIcon: _isDossierRejete ? Icons.edit : null,
                      ),
                    PersonalInfosItems(
                      label: 'Date de naissance',
                      controller: dateController,
                      suffixIcon: Icons.calendar_month,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(dateController.text) ?? DateTime(2005),
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
                    PersonalInfosItems(label: 'Adresse', controller: adresseController, suffixIcon: Icons.edit),
                    const SizedBox(height: 16),
                    // Type abonnement : FutureBuilder si non disponible dans le cache
                    FutureBuilder<String>(
                      future: selectedAbonnement != null
                          ? Future.value(selectedAbonnement!)
                          : TicketService()
                              .getCurrentAbonnement(currentUser!.id)
                              .then((a) => a?.typeNom ?? '-'),
                      builder: (ctx, snap) {
                        return PersonalInfosItems(
                          label: 'Type abonnement',
                          value: snap.data ?? '-',
                          readOnly: true,
                          suffixIcon: Icons.card_membership,
                        );
                      },
                    ),

                    // ───────── SECTION DOCUMENTS (toujours visible) ─────────
                    const SizedBox(height: 24),
                    const Text(
                      "Documents du dossier",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                    ),
                    const SizedBox(height: 6),
                    if (!_isDossierRejete)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          "Vos documents actuels (non modifiables)",
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(height: 10),

                    // ─── PHOTO CIN ───
                    _buildDocumentRow(
                      label: "Photo CIN",
                      icon: Icons.credit_card,
                      existingUrl: currentUser!.cinUrl,
                      newFile: _newCinPhotoFile,
                      canEdit: _isDossierRejete,
                      onTap: () => _pickImage((f) => _newCinPhotoFile = f),
                      onClear: () => setState(() => _newCinPhotoFile = null),
                    ),

                    const SizedBox(height: 14),

                    // ─── CARTE SCOLAIRE (si étudiant) ───
                    if (_isEtudiant) ...[
                      _buildDocumentRow(
                        label: "Carte scolaire",
                        icon: Icons.school,
                        existingUrl: currentUser!.carteScolaireUrl,
                        newFile: _newCarteScolaireFile,
                        canEdit: _isDossierRejete,
                        onTap: () => _pickImage((f) => _newCarteScolaireFile = f),
                        onClear: () => setState(() => _newCarteScolaireFile = null),
                      ),
                      const SizedBox(height: 14),
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
                        label: const Text("Enregistrer et re-soumettre",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                          : AppButton(
                        text: "Enregistrer les modifications",
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
    context.read<AuthBloc>().add(AuthUpdateUserRequested(
      id: currentUser!.id,
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      email: emailController.text.trim(),
      tel: telController.text.trim(),
      adresse: adresseController.text.trim(),
      dateNaissance: dateController.text.trim(),
    ));
  }

  void _handleResubmit() {
    if (currentUser == null) return;
    context.read<AuthBloc>().add(AuthResubmitDossierRequested(
      userId: currentUser!.id,
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      email: emailController.text.trim(),
      tel: telController.text.trim(),
      adresse: adresseController.text.trim(),
      dateNaissance: dateController.text.trim(),
      cin: cinController.text.trim().isNotEmpty ? cinController.text.trim() : null,
      newPhotoFile: _newPhotoFile,
      newCinFile: _newCinPhotoFile,
      newCarteScolaireFile: _newCarteScolaireFile,
    ));
  }

  // ─── Widget document : affiche toujours, modifiable seulement si rejeté ───
  Widget _buildDocumentRow({
    required String label,
    required IconData icon,
    required String? existingUrl,
    required XFile? newFile,
    required bool canEdit,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final bool hasNew = newFile != null;
    final bool hasExisting = existingUrl != null && existingUrl.isNotEmpty;

    return GestureDetector(
      onTap: canEdit ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasNew
                ? AppColors.green
                : canEdit
                ? Colors.orange.shade300
                : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // ── Miniature si photo existante ──
            if (hasNew)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(newFile!.path), width: 48, height: 48, fit: BoxFit.cover),
              )
            else if (hasExisting)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  existingUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.darkBlue),
                  ),
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.grey),
              ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    hasNew
                        ? newFile!.name
                        : hasExisting
                        ? canEdit
                        ? "Document actuel (appuyer pour changer)"
                        : "Document actuel"
                        : canEdit
                        ? "Appuyer pour sélectionner"
                        : "Aucun document",
                    style: TextStyle(
                      fontSize: 12,
                      color: hasNew ? AppColors.green : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (hasNew)
              GestureDetector(onTap: onClear, child: const Icon(Icons.close, color: Colors.red))
            else if (canEdit)
              Icon(Icons.upload_file, color: Colors.orange.shade400)
            else
              Icon(Icons.lock_outline, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}