import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';

import '../../../../constants/app_colors.dart';
import '../../../../bloc/dashboard/dashboard_bloc.dart';
import '../../../../bloc/dashboard/dashboard_state.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/loginPage');
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {

          bool isOnline = true;
          DateTime? lastUpdate;

          if (state is DashboardLoaded) {
            lastUpdate = state.systemStatus?.lastUpdate;
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            color: const Color(0xFF1A1F26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Dashboard\nAdmin",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Vue d'ensemble du système",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white24,
                          child: IconButton(
                            icon: const Icon(Icons.logout),
                            color: Colors.white,
                            iconSize: 20,
                            onPressed: () {
                              context.read<AuthBloc>().add(AuthLogoutRequested());
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.green,
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// SYSTEM STATUS
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        color: isOnline ? Colors.green : Colors.red,
                        size: 10,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        isOnline ? "Système opérationnel" : "Système hors ligne",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        lastUpdate != null
                            ? "Mis à jour il y a ${_timeAgo(lastUpdate)}"
                            : "Chargement...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date).inSeconds;
    if (diff < 60) return "$diff s";
    if (diff < 3600) return "${diff ~/ 60} min";
    return "${diff ~/ 3600} h";
  }
}