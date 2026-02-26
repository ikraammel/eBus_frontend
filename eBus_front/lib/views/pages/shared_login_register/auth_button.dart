import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppColors.darkBlue,
  });

  final VoidCallback? onPressed; // Utiliser VoidCallback est plus standard en Flutter
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52, // Un peu plus haut pour le confort tactile
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white, // Gère la couleur du texte et du splash
          elevation: 2, // Légère ombre pour l'effet "Elevated" de l'image
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Coins arrondis modernes
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        child: Text(text),
      ),
    );
  }
}