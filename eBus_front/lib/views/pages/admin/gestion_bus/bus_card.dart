import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_event.dart';
import 'package:smart_bus/models/bus.dart';

import '../../../UI/buttons/action_icon_button.dart';
import '../../../UI/confirm_delete_dialog.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
  final Color color;
  final ValueChanged<Bus> onEdit;
  final ValueChanged<Bus> onDetails;

  const BusCard({
    super.key,
    required this.bus,
    required this.color,
    required this.onEdit,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final title = bus.numero.isNotEmpty ? bus.numero : bus.immatriculation;
    final ligne = bus.ligneNumero != null && bus.ligneNumero!.isNotEmpty
        ? "Ligne ${bus.ligneNumero}"
        : "Ligne ID ${bus.ligneId}";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onDetails(bus),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_bus, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(bus.immatriculation),
                    const SizedBox(height: 4),
                    Text(
                      "${bus.etat.isEmpty ? 'Etat non renseigne' : bus.etat} - $ligne",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ActionIconButton(
                icon: CupertinoIcons.pen,
                iconColor: Colors.blueGrey,
                backgroundColor: Colors.blueGrey.withOpacity(0.15),
                onTap: () => onEdit(bus),
              ),
              const SizedBox(width: 8),
              ActionIconButton(
                icon: CupertinoIcons.trash,
                iconColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.15),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmDeleteDialog(
                      title: "Supprimer le bus",
                      content: "Etes-vous sur de vouloir supprimer ce bus ?",
                      onConfirm: () {
                        if (bus.id != null) {
                          context.read<BusBloc>().add(DeleteBus(bus.id!));
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
