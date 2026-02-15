import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed
  });

  final VoidCallback onPressed; // Utiliser VoidCallback est plus standard en Flutter
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52, // Un peu plus haut pour le confort tactile
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A367C), // Ton bleu foncé
          foregroundColor: Colors.white, // Gère la couleur du texte et du splash
          elevation: 2, // Légère ombre pour l'effet "Elevated" de l'image
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Coins arrondis modernes
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5, // Un petit espacement pour la clarté
          ),
        ),
        child: Text(text),
      ),
    );
  }
}