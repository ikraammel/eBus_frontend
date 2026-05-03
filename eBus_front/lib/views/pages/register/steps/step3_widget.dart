import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../file_picker_field.dart';

class Step3Widget extends StatelessWidget {
  const Step3Widget({
    super.key,
    required this.image,
    required this.carteScolaire,
    required this.cin,
    required this.onPickImage,
    required this.onPickCarteScolaire,
    required this.onPickCin,
    required this.typeAbonnement
  });

  final XFile? image;
  final XFile? carteScolaire;
  final XFile? cin;
  final String typeAbonnement;

  final VoidCallback onPickImage;
  final VoidCallback onPickCarteScolaire;
  final VoidCallback onPickCin;

  @override
  Widget build(BuildContext context) {
    // Détection si c'est un profil étudiant
    bool isEtudiant = (typeAbonnement ?? '').toUpperCase().contains('SCOLAIRE') || 
                      (typeAbonnement ?? '').toUpperCase().contains('ETUDIANT');

    return SingleChildScrollView(
      child: Column(
        children: [
          FilePickerField(
            label: "Photo de profil*",
            image: image,
            onPick: onPickImage,
            placeholder: "Charger votre photo",
          ),
      
          if (isEtudiant)
            FilePickerField(
              label: "Carte scolaire ou Attestation de scolarité*",
              image: carteScolaire,
              onPick: onPickCarteScolaire,
              placeholder: "Charger le justificatif de scolarité",
            ),
      
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
