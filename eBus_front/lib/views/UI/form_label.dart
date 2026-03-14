import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class FormLabel extends StatelessWidget {
  final String text;
  const FormLabel({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkBlue,
          fontSize: 15,
        ),
      ),
    );
  }
}