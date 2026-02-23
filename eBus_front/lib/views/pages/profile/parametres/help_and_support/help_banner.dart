import 'package:flutter/material.dart';

class HelpBanner extends StatelessWidget {
  const HelpBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1A367C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Besoin d'aide ?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Notre équipe est à votre disposition",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          SizedBox(height: 15,),
          Row(
            children: [
              Icon(Icons.email, color: Colors.white, size: 20),
              SizedBox(width: 12,),
              Text(
                "support@ebus-vectalia.ma",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          SizedBox(height: 12,),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.white, size: 20),
              SizedBox(width: 12,),
              Text(
               "06 23 45 67 89",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
