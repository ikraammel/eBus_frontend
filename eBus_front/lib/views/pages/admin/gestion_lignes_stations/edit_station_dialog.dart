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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier la station"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TextField(
            controller: widget.nameController,
            decoration: const InputDecoration(labelText: "Nom"),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: widget.orderController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Ordre"),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),

        TextButton(
          onPressed: () {
            widget.onValidate();
            Navigator.pop(context);
          },
          child: const Text("Valider"),
        ),
      ],
    );
  }
}