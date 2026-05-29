import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_event.dart';
import 'package:smart_bus/bloc/bus/bus_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/bus.dart';
import 'package:smart_bus/models/ligne.dart';
import 'package:smart_bus/services/ligne_service.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';

import '../../../UI/buttons/app_button.dart';
import '../../../UI/form_label.dart';
import '../../../UI/form_text_field.dart';

class BusFormPage extends StatefulWidget {
  final Bus? bus;
  const BusFormPage({super.key, this.bus});

  @override
  State<BusFormPage> createState() => _BusFormPageState();
}

class _BusFormPageState extends State<BusFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _etatController = TextEditingController();
  final _immatriculationController = TextEditingController();
  final _capaciteController = TextEditingController();
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();
  late final Future<List<Ligne>> _lignesFuture;
  int? _selectedLigneId;

  @override
  void initState() {
    super.initState();
    _lignesFuture = LigneService().getLignes();
    final bus = widget.bus;
    if (bus != null) {
      _numeroController.text = bus.numero;
      _etatController.text = bus.etat;
      _immatriculationController.text = bus.immatriculation;
      _capaciteController.text = bus.capacite?.toString() ?? '';
      _marqueController.text = bus.marque ?? '';
      _modeleController.text = bus.modele ?? '';
      _selectedLigneId = bus.ligneId == 0 ? null : bus.ligneId;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _etatController.dispose();
    _immatriculationController.dispose();
    _capaciteController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    super.dispose();
  }

  Bus _buildBus() {
    return Bus(
      id: widget.bus?.id,
      numero: _numeroController.text.trim(),
      etat: _etatController.text.trim(),
      immatriculation: _immatriculationController.text.trim(),
      capacite: int.tryParse(_capaciteController.text.trim()),
      marque: _marqueController.text.trim(),
      modele: _modeleController.text.trim(),
      ligneId: _selectedLigneId!,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bus = _buildBus();
    if (widget.bus == null) {
      context.read<BusBloc>().add(CreateBus(bus));
    } else {
      context.read<BusBloc>().add(UpdateBus(widget.bus!.id!, bus));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: Text(
          widget.bus == null ? "Ajouter un bus" : "Modifier le bus",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<BusBloc, BusState>(
        listener: (context, state) {
          if (state is BusCreated) {
            AppSnackBar.showSuccess(context, "Bus cree avec succes");
            Navigator.pop(context);
          } else if (state is BusUpdated) {
            AppSnackBar.showSuccess(context, "Bus modifie avec succes");
            Navigator.pop(context);
          } else if (state is BusError) {
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BusLoading) {
            return const SplashScreen();
          }

          return FutureBuilder<List<Ligne>>(
            future: _lignesFuture,
            builder: (context, snapshot) {
              final lignes = snapshot.data ?? const <Ligne>[];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(text: "Numero du bus"),
                      FormTextField(
                        hint: "Ex: BUS-001",
                        controller: _numeroController,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? "Le numero est obligatoire"
                            : null,
                      ),
                      const SizedBox(height: 18),
                      FormLabel(text: "Immatriculation"),
                      FormTextField(
                        hint: "Ex: 12345-A-10",
                        controller: _immatriculationController,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? "L'immatriculation est obligatoire"
                            : null,
                      ),
                      const SizedBox(height: 18),
                      FormLabel(text: "Etat / statut"),
                      FormTextField(
                        hint: "Ex: En service",
                        controller: _etatController,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? "Le statut est obligatoire"
                            : null,
                      ),
                      const SizedBox(height: 18),
                      FormLabel(text: "Capacite"),
                      FormTextField(
                        hint: "Ex: 45",
                        controller: _capaciteController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          return int.tryParse(text) == null
                              ? "Capacite invalide"
                              : null;
                        },
                      ),
                      const SizedBox(height: 18),
                      FormLabel(text: "Marque"),
                      FormTextField(
                        hint: "Ex: Mercedes",
                        controller: _marqueController,
                      ),
                      const SizedBox(height: 18),
                      FormLabel(text: "Modele"),
                      FormTextField(
                        hint: "Ex: Citaro",
                        controller: _modeleController,
                      ),
                      const SizedBox(height: 18),
                      FormLabel(text: "Ligne"),
                      DropdownButtonFormField<int>(
                        value: lignes.any((ligne) => ligne.id == _selectedLigneId)
                            ? _selectedLigneId
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: snapshot.connectionState == ConnectionState.waiting
                              ? "Chargement des lignes..."
                              : "Choisir une ligne",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: lignes
                            .where((ligne) => ligne.id != null)
                            .map(
                              (ligne) => DropdownMenuItem<int>(
                                value: ligne.id,
                                child: Text(
                                  ligne.startPoint.isNotEmpty || ligne.endPoint.isNotEmpty
                                      ? "Ligne ${ligne.numero} - ${ligne.startPoint} / ${ligne.endPoint}"
                                      : "Ligne ${ligne.numero}",
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _selectedLigneId = value),
                        validator: (value) =>
                            value == null ? "La ligne est obligatoire" : null,
                      ),
                      const SizedBox(height: 28),
                      Row(
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
                              text: widget.bus == null ? "Creer" : "Modifier",
                              onPressed: _submit,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
