import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_event.dart';
import 'package:smart_bus/models/Bus.dart';

import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../bloc/auth/auth_state.dart';
import '../../../../enums/enums.dart';
import '../../../UI/buttons/action_icon_button.dart';
import '../../../UI/confirm_delete_dialog.dart';
import 'bus_form_page.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
  final Color color;

  const BusCard({super.key, required this.bus, required this.color});

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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,4))],
            ),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Page détails du bus à venir"))
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 60,
                    color: color,
                    child: Center(child: Text(bus.numero.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${bus.immatriculation}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(bus.etat, style: const TextStyle(color: Colors.grey)),
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
                              title: "Supprimer le bus",
                              content: "Êtes-vous sûr de vouloir supprimer cette ligne ?",
                              onConfirm: () {
                                context.read<BusBloc>().add(DeleteBus(bus.id!));
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
                            builder: (_) => BusFormPage(bus: bus),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

          );
  });
}
}