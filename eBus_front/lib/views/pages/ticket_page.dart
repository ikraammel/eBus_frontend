import 'package:flutter/material.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A367C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Acheter un ticket",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choisissez votre ticket",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A367C),
              ),
            ),
            const SizedBox(height: 20),
            _buildTicketOption(
              context,
              title: "Ticket Simple",
              subtitle: "1 trajet",
              price: "2.50€",
              iconColor: const Color(0xFF1A367C),
            ),
            _buildTicketOption(
              context,
              title: "Pass Journée",
              subtitle: "Illimité 24h",
              price: "8.00€",
              iconColor: const Color(0xFF8DC63F),
            ),
            _buildTicketOption(
              context,
              title: "Abonnement Hebdo",
              subtitle: "7 jours",
              price: "25.00€",
              iconColor: const Color(0xFF1A367C),
            ),
            _buildTicketOption(
              context,
              title: "Abonnement Mensuel",
              subtitle: "30 jours",
              price: "65.00€",
              iconColor: const Color(0xFF8DC63F),
              isPopular: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String price,
    required Color iconColor,
    bool isPopular = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône Ticket
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              // Textes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A367C))),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              // Prix
              Text(
                price,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A367C)),
              ),
            ],
          ),
        ),
        // Badge Populaire
        if (isPopular)
          Positioned(
            top: -10,
            right: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8DC63F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Populaire",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
