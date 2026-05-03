import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/ticket.dart';
import 'package:smart_bus/models/type_abonnement.dart';
import 'package:smart_bus/services/ticket_service.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final TicketService _service = TicketService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllOffers();
  }

  String _formatTitle(String title) {
    if (title.isEmpty) return title;
    String formatted = title.replaceAll('_', ' ').toLowerCase();
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Connexion requise"),
        content: const Text("Vous devez vous connecter pour accéder à cette page."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/loginPage');
            },
            child: const Text("Se Connecter", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final bool isGuest = authState is! AuthAuthenticated;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          appBar: AppBar(
            title: const Text("Tickets & Abonnements", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: AppColors.darkBlue,
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: FutureBuilder<List<dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Erreur de chargement des offres"));
              }
              
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return const Center(child: Text("Aucune offre disponible"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  
                  if (item is TypeAbonnement) {
                    return _buildCard(
                      title: _formatTitle(item.nom),
                      subtitle: "Validité : ${item.dureeMois} mois",
                      price: "${item.prix} MAD",
                      icon: item.nom.toUpperCase().contains("SCOLAIRE") ? Icons.school : Icons.card_membership,
                      onPressed: () => isGuest ? _showLoginRequiredDialog() : _handleSubscribe(item),
                      buttonText: "S'abonner",
                    );
                  } else if (item is Ticket) {
                    return _buildCard(
                      title: _formatTitle(item.typeTicket),
                      subtitle: "Ticket unitaire pour un trajet",
                      price: "${item.prix} MAD",
                      icon: Icons.confirmation_number_outlined,
                      onPressed: null,
                      buttonText: "",
                      isTicket: true,
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _handleSubscribe(TypeAbonnement a) {
    // Logique d'abonnement
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required VoidCallback? onPressed,
    required String buttonText,
    bool isTicket = false,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: (isTicket ? AppColors.green : AppColors.darkBlue).withValues(alpha: 0.1),
                  child: Icon(icon, color: isTicket ? AppColors.green : AppColors.darkBlue),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
              ],
            ),
            if (onPressed != null) ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
