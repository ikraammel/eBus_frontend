import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF8DC63F).withOpacity(0.1),
            child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF8DC63F)),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ticket acheté", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Ligne 12 • Il y a 2h", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Text("2.50€", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A367C))),
        ],
      ),
    );
  }
}
