import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class ParametresPage extends StatelessWidget {
  const ParametresPage({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap; 

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.darkBlue, size: 22),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
        trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20
        ),
      ),
    );
  }
}