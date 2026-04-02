import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class AdministratorAccess extends StatelessWidget {
  const AdministratorAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          print("Vers l'interface admin");
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Accès administrateur',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}