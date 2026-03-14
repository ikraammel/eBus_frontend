import 'package:flutter/material.dart';

class StationCard extends StatelessWidget {

  final String nom;
  final String ordre;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StationCard({
    super.key,
    required this.nom,
    required this.ordre,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: ListTile(
        title: Text(nom),
        subtitle: Text("Ordre : $ordre"),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}