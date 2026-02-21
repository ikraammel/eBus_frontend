import 'package:flutter/material.dart';

import '../home/home_page.dart';

class GuestButton extends StatelessWidget {
  const GuestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40, // Hauteur standard pour un bouton moderne
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1A367C), width: 1.5), // Bordure bleue
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Arrondi comme sur l'image
          ),
          foregroundColor: const Color(0xFF1A367C), // Couleur du texte et de l'effet splash
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        },
        child: const Text(
          "Continuer en tant qu’invité",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600, // Un peu plus gras pour la lisibilité
          ),
        ),
      ),
    );
  }
}