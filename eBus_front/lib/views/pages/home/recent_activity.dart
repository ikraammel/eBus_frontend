import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActivityItem(
          icon: Icons.confirmation_number_outlined,
          color: AppColors.green,
          title: "Ticket acheté",
          subtitle: "Ligne 12 • Aujourd'hui, 08:30",
          amount: "4.00 DH",
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.card_membership,
          color: AppColors.darkBlue,
          title: "Abonnement renouvelé",
          subtitle: "Mensuel Scolaire • Hier",
          amount: "60.00 DH",
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        ],
      ),
    );
  }
}
