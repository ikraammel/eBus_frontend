import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../file_picker_field.dart';

class Step3Widget extends StatelessWidget {
  const Step3Widget({
    super.key,
    required this.image,
    required this.carteScolaire,
    this.attestationScolaire,
    required this.cin,
    required this.onPickImage,
    required this.onPickCarteScolaire,
    this.onPickAttestationScolaire,
    required this.onPickCin,
    required this.typeAbonnement,
  });

  final XFile? image;
  final XFile? carteScolaire;
  final XFile? attestationScolaire;
  final XFile? cin;
  final String typeAbonnement;

  final VoidCallback onPickImage;
  final VoidCallback onPickCarteScolaire;
  final VoidCallback? onPickAttestationScolaire;
  final VoidCallback onPickCin;

  @override
  Widget build(BuildContext context) {
    final normalizedType = typeAbonnement
        .toUpperCase()
        .trim()
        .replaceAll("É", "E")
        .replaceAll("È", "E")
        .replaceAll("Ê", "E");
    final isEtudiant = normalizedType.contains('SCOLAIRE') ||
        normalizedType.contains('ETUDIANT');

    return SingleChildScrollView(
      child: Column(
        children: [
          FilePickerField(
            label: "Photo de profil*",
            image: image,
            onPick: onPickImage,
            placeholder: "Charger votre photo",
          ),
          if (isEtudiant) ...[
            FilePickerField(
              label: "Carte scolaire*",
              image: carteScolaire,
              onPick: onPickCarteScolaire,
              placeholder: "Charger votre carte scolaire",
            ),
            FilePickerField(
              label: "Attestation de scolarite*",
              image: attestationScolaire,
              onPick: onPickAttestationScolaire ?? () {},
              placeholder: "Charger l'attestation de scolarite",
            ),
          ],
          FilePickerField(
            label: "CIN (Recto/Verso)*",
            image: cin,
            onPick: onPickCin,
            placeholder: "Charger la photo de votre CIN",
          ),
        ],
      ),
    );
  }
}
