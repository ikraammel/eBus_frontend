import 'package:flutter/material.dart';

class ListTileItems extends StatelessWidget {
  const ListTileItems({super.key,
    required this.title,
    required this.subtitle,
    this.prefixIcon,
    this.color,
    this.titleColor,
    this.subtitleColor,
    this.onTap
  });

  final String title;
  final Color? titleColor;
  final String subtitle;
  final Color? subtitleColor;
  final IconData? prefixIcon;
  final Color? color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: color != null ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Ombre très légère
              blurRadius: 10,
              offset: const Offset(0, 4), // Ombre vers le bas
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          leading: prefixIcon != null ? Icon(prefixIcon, color: Color(0xFF76BC41)) : null,
          title: Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: TextStyle(color: subtitleColor,fontSize: 13),),

        ),
      ),
    );
  }
}
