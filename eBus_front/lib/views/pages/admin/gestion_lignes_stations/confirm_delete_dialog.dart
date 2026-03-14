import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({super.key,required this.onConfirm,});
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Supprimer la station"),
      content: const Text(
        "Êtes-vous sûr de vouloir supprimer cette station ?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.darkBlue,
          ),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text("Supprimer"),
        ),
      ],
    );
  }
}
