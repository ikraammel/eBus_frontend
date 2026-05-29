import 'package:flutter/material.dart';

class EditStationDialog extends StatefulWidget {

  final TextEditingController nameController;
  final TextEditingController orderController;
  final VoidCallback onValidate;

  const EditStationDialog({
    super.key,
    required this.nameController,
    required this.orderController,
    required this.onValidate,
  });

  @override
  State<EditStationDialog> createState() => _EditStationDialogState();
}

class _EditStationDialogState extends State<EditStationDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier la station"),

      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: widget.nameController,
              decoration: const InputDecoration(labelText: "Nom"),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? "Nom obligatoire" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: widget.orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Ordre"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Ordre obligatoire";
                }
                return int.tryParse(value) == null ? "Ordre invalide" : null;
              },
            ),
          ],
        ),
      ),

      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),

        TextButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            widget.onValidate();
            Navigator.pop(context);
          },
          child: const Text("Valider"),
        ),
      ],
    );
  }
}
