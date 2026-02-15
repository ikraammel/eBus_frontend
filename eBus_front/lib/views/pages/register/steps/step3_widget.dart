import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/file_picker_service.dart';
import '../file_picker_field.dart';

class Step3Widget extends StatelessWidget {
  const Step3Widget({
    super.key,
    required this.image,
    required this.carteScolaire,
    required this.cin,
    required this.onPickImage,
    required this.onPickCarteScolaire,
    required this.onPickCin});

  final XFile? image;
  final XFile? carteScolaire;
  final XFile? cin;

  final VoidCallback onPickImage;
  final VoidCallback onPickCarteScolaire;
  final VoidCallback onPickCin;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FilePickerField(
              label: "Photo *",
              image: image,
              onPick: onPickImage,
              placeholder: "Charger la photo (PNG/JPG – max 1MB)",
          ),
      
          FilePickerField(
              label: "Carte scolaire *",
              image: carteScolaire,
              onPick: onPickCarteScolaire,
              placeholder:"Charger la photo (PNG/JPG – max 1MB)"
          ),
      
          FilePickerField(
              label: "CIN *",
              image: cin,
              onPick: onPickCin,
              placeholder:"Charger la photo (PNG/JPG – max 1MB)"
          ),
        ],
      ),
    );
  }
}
