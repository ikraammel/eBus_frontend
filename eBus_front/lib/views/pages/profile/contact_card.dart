import 'package:flutter/material.dart';

import '../../../models/User.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key,required this.icon,required this.label,required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon,color: Color(0xFF1A367C)),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
              ),

            ],
          )
        ],
      ),
    );
  }
}
