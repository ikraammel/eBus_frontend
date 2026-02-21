import 'package:flutter/material.dart';

class SwitchListTileItems extends StatelessWidget {
  const SwitchListTileItems({super.key, required this.title, required this.subtitle, required this.value, this.onChanged});

  final String title;
  final String subtitle;
  final bool value;
  final  Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Ombre très légère
            blurRadius: 10,
            offset: const Offset(0, 4), // Ombre vers le bas
          ),
          ],
       ),
        child: SwitchListTile(
          title: Text(
              title,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400)
          ),
          subtitle: Text(subtitle),
          activeTrackColor: Color(0xFF76BC41),
          value: value,
          onChanged: onChanged
        ),
      ),
    );
  }
}
