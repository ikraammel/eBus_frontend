import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/enums/enums.dart';
import '../../../constants/app_colors.dart';
import '../../../models/Ligne.dart';
import '../../UI/buttons/action_icon_button.dart';
import '../../UI/confirm_delete_dialog.dart';
import '../admin/gestion_lignes_stations/line_form_page.dart';
import 'line_details_page.dart';

class LineCard extends StatelessWidget {
  final Ligne ligne;
  final Color color;
  const LineCard({super.key, required this.ligne, required this.color});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc,AuthState,bool>(
      selector: (state) {
        if(state is AuthAuthenticated){
          return state.user.role == Role.ADMIN;
        }
        return false;
      },
      builder: (context, isAdmin) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final sortedStations = List.from(ligne.stations)
                ..sort((a, b) => a.ordre.compareTo(b.ordre));

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LineDetailsPage(
                        lineNumber: ligne.numero,
                        themeColor: color,
                        stops: sortedStations
                            .map<Map<String, String>>((s) =>
                        {
                          "name": s.nom.toString(),
                          "time": "--:--",
                        })
                            .toList(),
                      ),
                ),
              );
            },
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        ligne.numero,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ligne ${ligne.numero}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${ligne.startPoint} → ${ligne.endPoint}",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if(isAdmin) ...[
                    ActionIconButton(
                      icon: CupertinoIcons.trash,
                      iconColor: Colors.red,
                      backgroundColor: Colors.red.withOpacity(0.15),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: "Supprimer la ligne",
                              content: "Êtes-vous sûr de vouloir supprimer cette ligne ?",
                              onConfirm: () {
                                context.read<LigneBloc>().add(DeleteLine(ligne.id!));
                              },
                            )
                        );
                      },
                    ),

                    ActionIconButton(
                      icon: CupertinoIcons.pen,
                      iconColor: Colors.blueGrey,
                      backgroundColor: Colors.blueGrey.withOpacity(0.15),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LineFormPage(ligne: ligne),
                          ),
                        );
                      },
                    ),
                  ],

                  const Icon(Icons.chevron_right, color: Colors.grey),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
