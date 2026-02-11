import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerField extends StatelessWidget {
  const FilePickerField({super.key, required this.label, required this.image,required this.onPick, required this.placeholder});

  final String label;
  final XFile? image;
  final VoidCallback onPick;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        ),
        SizedBox(height: 6),
        /// Zone cliquable
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                const Icon(Icons.image, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    image != null ? "Image sélectionnée" : placeholder,
                    style: TextStyle(
                      color: image != null
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (image != null)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ),
        /// Aperçu de l'image
        if (image != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(image!.path),
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
        ],
        SizedBox(height: 20,),
      ],
    );
  }
}
