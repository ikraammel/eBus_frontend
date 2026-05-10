import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/models/activity.dart';
import 'package:smart_bus/services/activity_service.dart';
import 'package:smart_bus/models/user.dart';
import '../../../constants/app_colors.dart';

class RecentActivity extends StatefulWidget {
  final bool isAdmin;
  const RecentActivity({super.key,this.isAdmin = false});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {

        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        User? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        } else if (state is AuthProfileUpdated) {
          user = state.user;
        }

        if (user != null) {
          return FutureBuilder<List<Activity>>(
            future: widget.isAdmin
              ? ActivityService().getRecentActivitiesAdmin()
            : ActivityService().getRecentActivities(user.id),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text("Erreur de chargement");
              }

              final activities = snapshot.data ?? [];

              if (activities.isEmpty) {
                return const Text("Aucune activité récente");
              }

              return Column(
                children: activities.map((activity) {
                  return Column(
                    children: [
                      _buildActivityItem(
                        icon: _getIcon(activity.type),
                        color: _getColor(activity.type),
                        title: widget.isAdmin
                          ? "${activity.userNom} ${activity.userPrenom} - ${activity.description}"
                          : activity.description,
                        subtitle: _formatDate(activity.date),
                        amount: "",
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              );
            },
          );
        }

        // Pour les invités ou non-connectés, on ne renvoie rien
        return const SizedBox.shrink();
      },
    );
  }

  // 🎯 UI CARD
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
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue)),
        ],
      ),
    );
  }

  // 🎯 ICONES dynamiques
  IconData _getIcon(String type) {
    switch (type) {
      case "Payment":
        return Icons.payment;
      case "Reclamation":
        return Icons.report;
      case "Ticket":
        return Icons.confirmation_number_outlined;
      case "Objet Perdu":
        return Icons.inventory;
      case "Abonnement":
        return Icons.subscriptions;
      default:
        return Icons.history;
    }
  }

  // 🎯 COULEURS dynamiques
  Color _getColor(String type) {
    switch (type) {
      case "Payment":
        return Colors.green;
      case "Reclamation":
        return Colors.orange;
      case "Ticket":
        return AppColors.green;
      case "Objet Perdu":
        return Colors.blue;
      case "Abonnement":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // 🎯 FORMAT DATE
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
