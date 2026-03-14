import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class LineSearchBar extends StatelessWidget {
  const LineSearchBar({
    super.key,
    this.onChanged,
    this.hintText = "Rechercher une ligne...",
  });

  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      decoration: const BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),

          filled: true,
          fillColor: Colors.white.withOpacity(0.15),

          contentPadding: const EdgeInsets.symmetric(vertical: 0),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.white30,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}