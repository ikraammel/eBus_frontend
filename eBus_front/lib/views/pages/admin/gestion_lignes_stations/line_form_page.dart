import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/Ligne.dart';
import 'package:smart_bus/models/Station.dart';
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
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _departController = TextEditingController();
  TextEditingController _arriveeController = TextEditingController();
  TextEditingController _distanceController = TextEditingController();

  int _stationCount = 0;
  List<TextEditingController> _stationNameControllers = [];
  List<TextEditingController> _stationOrderControllers = [];
  List<int?> _stationIds = [];

  @override
  void initState() {
    super.initState();

    if (widget.ligne != null) {
      _numeroController.text = widget.ligne!.numero;
      _departController.text = widget.ligne!.startPoint;
      _arriveeController.text = widget.ligne!.endPoint;
      _distanceController.text = widget.ligne!.distance.toString();

      final stations = widget.ligne!.stations;
      _stationCount = stations.length;
      _stationNameControllers = List.generate(
          _stationCount, (index) => TextEditingController(text: stations[index].nom));
      _stationOrderControllers = List.generate(
          _stationCount, (index) => TextEditingController(text: stations[index].ordre.toString()));
      _stationIds = stations.map((s) => s.id).toList();
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _departController.dispose();
    _arriveeController.dispose();
    _distanceController.dispose();
    for (var c in _stationNameControllers) c.dispose();
    for (var c in _stationOrderControllers) c.dispose();
    super.dispose();
  }

  Ligne buildPatchLine() {
    return Ligne(
      id: widget.ligne?.id,
      numero: _numeroController.text.trim(),
      startPoint: _departController.text.trim(),
      endPoint: _arriveeController.text.trim(),
      distance: double.tryParse(_distanceController.text) ?? 0.0,
      stations: List.generate(
        _stationCount,
            (index) => Station(
          id: _stationIds.length > index ? _stationIds[index] : null,
          nom: _stationNameControllers[index].text.trim(),
          ordre: int.tryParse(_stationOrderControllers[index].text) ?? 0,
          direction: '',
        ),
      ),
    );
  }

  void _addStation() {
    setState(() {
      _stationCount++;
      _stationNameControllers.add(TextEditingController());
      _stationOrderControllers.add(TextEditingController());
      _stationIds.add(null);
    });
  }

  void _removeStation() {
    if (_stationCount > 0) {
      setState(() {
        _stationCount--;
        _stationNameControllers.removeLast().dispose();
        _stationOrderControllers.removeLast().dispose();
        _stationIds.removeLast();
      });
    }
  }

  void _removeStationAt(int index) {
    final stationId = _stationIds[index];
    if (stationId != null && widget.ligne != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: Text(
          widget.ligne == null ? "Nouvelle ligne" : "Modifier la ligne",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<LigneBloc, LigneState>(
        listener: (context, state) {
          if (state is LigneCreated) {
            AppSnackBar.showSuccess(context, "Ligne créée avec succès");
            context.read<LigneBloc>().add(LoadLignes());
            Navigator.pop(context);
          } else if (state is LigneUpdated) {
            AppSnackBar.showSuccess(context, "Ligne modifiée avec succès");
            context.read<LigneBloc>().add(LoadLignes());
            Navigator.pop(context);
          } else if (state is StationCreated) {
            final index = _stationCount - 1;
            _stationIds[index] = state.station.id;
            setState(() {});
          } else if (state is LigneError) {
            AppSnackBar.showError(context, state.error);
            context.read<LigneBloc>().add(LoadLignes());
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormLabel(text: "Numéro de ligne"),
                  FormTextField(hint: "Ex: 12", controller: _numeroController),
                  const SizedBox(height: 20),
                  FormLabel(text: "Point de départ"),
                  FormTextField(hint: "Ex: Gare Centrale", controller: _departController),
                  const SizedBox(height: 20),
                  FormLabel(text: "Point d'arrivée"),
                  FormTextField(hint: "Ex: Université", controller: _arriveeController),
                  const SizedBox(height: 20),
                  FormLabel(text: "Distance (en Km)"),
                  FormTextField(hint: "Ex: 3 km", controller: _distanceController),
                  const SizedBox(height: 20),
                  FormLabel(text: "Nombre de stations"),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: _removeStation),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_stationCount.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _addStation),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_stationCount, (index) {
                    return StationCard(
                      nom: _stationNameControllers[index].text,
                      ordre: _stationOrderControllers[index].text,
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (_) => EditStationDialog(
                              nameController: _stationNameControllers[index],
                              orderController: _stationOrderControllers[index],
                              onValidate: () {
                                final name = _stationNameControllers[index].text.trim();
                                if (name.isEmpty) return;

                                final order = int.tryParse(_stationOrderControllers[index].text) ?? 0;

                                if (widget.ligne == null) {
                                  // Ligne non encore créée, on garde tout local
                                  setState(() {});
                                  return;
                                }

                                if (_stationIds[index] == null) {
                                  // Nouvelle station pour une ligne existante → création côté serveur
                                  final newStation = Station(
                                    nom: name,
                                    ordre: order,
                                    direction: '',
                                  );
                                  context.read<LigneBloc>().add(CreateStation(widget.ligne!.id!, newStation));
                                } else {
                                  // Station existante → update
                                  final updatedStation = Station(
                                    id: _stationIds[index],
                                    nom: name,
                                    ordre: order,
                                    direction: '',
                                  );
                                  context.read<LigneBloc>().add(UpdateStation(updatedStation, widget.ligne!.id!, _stationIds[index]!));
                                }
                              },
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: "Supprimer la station",
                              content: "Êtes-vous sûr de vouloir supprimer cette station ?",
                              onConfirm: () => _removeStationAt(index),
                            ),
                          );
                        }
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
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
                  child: AppButton(color: Colors.grey, text: "Annuler", onPressed: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: widget.ligne == null ? "Créer la ligne" : "Modifier la ligne",
                  onPressed: () {
                    final ligne = buildPatchLine();
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