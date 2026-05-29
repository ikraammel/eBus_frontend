import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/ligne.dart';
import 'package:smart_bus/models/station.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';

import '../../../UI/buttons/app_button.dart';
import '../../../UI/confirm_delete_dialog.dart';
import '../../../UI/form_label.dart';
import '../../../UI/form_text_field.dart';
import 'edit_station_dialog.dart';
import 'station_card.dart';

class LineFormPage extends StatefulWidget {
  final Ligne? ligne;
  const LineFormPage({super.key, this.ligne});

  @override
  State<LineFormPage> createState() => _LineFormPageState();
}

class _LineFormPageState extends State<LineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _arriveeController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  int _stationCount = 0;
  final List<TextEditingController> _stationNameControllers = [];
  final List<TextEditingController> _stationOrderControllers = [];
  final List<int?> _stationIds = [];

  @override
  void initState() {
    super.initState();

    final ligne = widget.ligne;
    if (ligne != null) {
      _numeroController.text = ligne.numero;
      _departController.text = ligne.startPoint;
      _arriveeController.text = ligne.endPoint;
      _distanceController.text = ligne.distance?.toString() ?? '';

      final stations = List<Station>.from(ligne.stations)
        ..sort((a, b) => a.ordre.compareTo(b.ordre));
      _stationCount = stations.length;
      for (final station in stations) {
        _stationNameControllers.add(TextEditingController(text: station.nom));
        _stationOrderControllers.add(
          TextEditingController(text: station.ordre.toString()),
        );
        _stationIds.add(station.id);
      }
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _departController.dispose();
    _arriveeController.dispose();
    _distanceController.dispose();
    for (final controller in _stationNameControllers) {
      controller.dispose();
    }
    for (final controller in _stationOrderControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Ligne _buildLine() {
    return Ligne(
      id: widget.ligne?.id,
      numero: _numeroController.text.trim(),
      startPoint: _departController.text.trim(),
      endPoint: _arriveeController.text.trim(),
      distance: double.tryParse(_distanceController.text.replaceAll(',', '.')),
      stations: List.generate(
        _stationCount,
        (index) => Station(
          id: _stationIds.length > index ? _stationIds[index] : null,
          nom: _stationNameControllers[index].text.trim(),
          ordre: int.tryParse(_stationOrderControllers[index].text) ?? index + 1,
          direction: '',
        ),
      ),
    );
  }

  void _addStation() {
    setState(() {
      _stationCount++;
      _stationNameControllers.add(TextEditingController());
      _stationOrderControllers.add(
        TextEditingController(text: _stationCount.toString()),
      );
      _stationIds.add(null);
    });
  }

  void _removeStationAt(int index) {
    final stationId = _stationIds[index];
    if (stationId != null && widget.ligne?.id != null) {
      context.read<LigneBloc>().add(DeleteStation(widget.ligne!.id!, stationId));
    }

    setState(() {
      _stationNameControllers[index].dispose();
      _stationOrderControllers[index].dispose();
      _stationNameControllers.removeAt(index);
      _stationOrderControllers.removeAt(index);
      _stationIds.removeAt(index);
      _stationCount--;
    });
  }

  void _openStationDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => EditStationDialog(
        nameController: _stationNameControllers[index],
        orderController: _stationOrderControllers[index],
        onValidate: () {
          final name = _stationNameControllers[index].text.trim();
          final order = int.tryParse(_stationOrderControllers[index].text);
          if (name.isEmpty || order == null) {
            AppSnackBar.showError(context, "Nom et ordre de station obligatoires");
            return;
          }

          if (widget.ligne?.id == null) {
            setState(() {});
            return;
          }

          final station = Station(
            id: _stationIds[index],
            nom: name,
            ordre: order,
            direction: '',
          );

          if (_stationIds[index] == null) {
            context.read<LigneBloc>().add(CreateStation(widget.ligne!.id!, station));
          } else {
            context.read<LigneBloc>().add(
                  UpdateStation(station, widget.ligne!.id!, _stationIds[index]!),
                );
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.ligne == null ? "Nouvelle ligne" : "Modifier la ligne",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<LigneBloc, LigneState>(
        listener: (context, state) {
          if (state is LigneCreated) {
            AppSnackBar.showSuccess(context, "Ligne creee avec succes");
            context.read<LigneBloc>().add(LoadLignes());
            Navigator.pop(context);
          } else if (state is LigneUpdated) {
            AppSnackBar.showSuccess(context, "Ligne modifiee avec succes");
            context.read<LigneBloc>().add(LoadLignes());
            Navigator.pop(context);
          } else if (state is StationCreated) {
            final index = _stationIds.lastIndexWhere((id) => id == null);
            if (index != -1) {
              setState(() => _stationIds[index] = state.station.id);
            }
            AppSnackBar.showSuccess(context, "Station ajoutee");
          } else if (state is StationUpdated) {
            AppSnackBar.showSuccess(context, "Station modifiee");
          } else if (state is StationDeleted) {
            AppSnackBar.showSuccess(context, "Station supprimee");
          } else if (state is LigneError) {
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(text: "Numero de ligne"),
                      FormTextField(
                        hint: "Ex: 12",
                        controller: _numeroController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Numero obligatoire"
                                : null,
                      ),
                      const SizedBox(height: 20),
                      FormLabel(text: "Point de depart"),
                      FormTextField(
                        hint: "Ex: Gare Centrale",
                        controller: _departController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Point de depart obligatoire"
                                : null,
                      ),
                      const SizedBox(height: 20),
                      FormLabel(text: "Point d'arrivee"),
                      FormTextField(
                        hint: "Ex: Universite",
                        controller: _arriveeController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Point d'arrivee obligatoire"
                                : null,
                      ),
                      const SizedBox(height: 20),
                      FormLabel(text: "Distance (en km)"),
                      FormTextField(
                        hint: "Ex: 3.5",
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return null;
                          return double.tryParse(value.replaceAll(',', '.')) == null
                              ? "Distance invalide"
                              : null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Stations",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: _addStation,
                    ),
                  ],
                ),
                if (_stationCount == 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Aucune station ajoutee"),
                  ),
                ...List.generate(_stationCount, (index) {
                  return StationCard(
                    nom: _stationNameControllers[index].text,
                    ordre: _stationOrderControllers[index].text,
                    onEdit: () => _openStationDialog(index),
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmDeleteDialog(
                          title: "Supprimer la station",
                          content: "Voulez-vous supprimer cette station ?",
                          onConfirm: () => _removeStationAt(index),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  color: Colors.grey,
                  text: "Annuler",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: widget.ligne == null ? "Creer la ligne" : "Modifier",
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final ligne = _buildLine();
                    if (widget.ligne == null) {
                      context.read<LigneBloc>().add(CreateLigne(ligne));
                    } else {
                      context.read<LigneBloc>().add(UpdateLine(widget.ligne!.id!, ligne));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
