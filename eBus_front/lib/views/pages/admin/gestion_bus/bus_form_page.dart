import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_event.dart';
import 'package:smart_bus/bloc/bus/bus_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/Bus.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';
import '../../../UI/buttons/app_button.dart';
import '../../../UI/confirm_delete_dialog.dart';
import '../../../UI/form_label.dart';
import '../../../UI/form_text_field.dart';

class BusFormPage extends StatefulWidget {
  final Bus? bus;
  const BusFormPage({super.key, this.bus});

  @override
  State<BusFormPage> createState() => _BusFormPageState();
}

class _BusFormPageState extends State<BusFormPage> {
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _etatController = TextEditingController();
  TextEditingController _immatriculationController = TextEditingController();
  TextEditingController _ligneIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.bus != null) {
      _numeroController.text = widget.bus!.numero;
      _etatController.text = widget.bus!.etat;
      _immatriculationController.text = widget.bus!.immatriculation;
      _ligneIdController.text = widget.bus!.ligneId.toString();
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _etatController.dispose();
    _immatriculationController.dispose();
    _ligneIdController.dispose();
    super.dispose();
  }

  Bus buildBus() {
    return Bus(
      id: widget.bus?.id,
      numero: _numeroController.text.trim(),
      etat: _etatController.text.trim(),
      immatriculation: _immatriculationController.text.trim(),
      ligneId: int.parse(_ligneIdController.text),
    );
  }

  void _confirmDeleteBus() {
    if (widget.bus == null) return;

    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: "Supprimer le bus",
        content: "Êtes-vous sûr de vouloir supprimer ce bus ?",
        onConfirm: () {
          context.read<BusBloc>().add(DeleteBus(widget.bus!.id!));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: Text(
          widget.bus == null ? "Ajouter un bus" : "Modifier le bus",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.bus != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDeleteBus,
            )
        ],
      ),
      body: BlocConsumer<BusBloc, BusState>(
        listener: (context, state) {
          if (state is BusCreated) {
            AppSnackBar.showSuccess(context, "Bus créé avec succès");
            context.read<BusBloc>().add(LoadBuses());
            Navigator.pop(context);
          } else if (state is BusUpdated) {
            AppSnackBar.showSuccess(context, "Bus modifié avec succès");
            context.read<BusBloc>().add(LoadBuses());
            Navigator.pop(context);
          } else if (state is BusError) {
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BusLoading) {
              return const SplashScreen();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormLabel(text: "Numéro du bus"),
                FormTextField(hint: "Ex: BUS-001", controller: _numeroController),
                const SizedBox(height: 20),
                FormLabel(text: "État"),
                FormTextField(hint: "Ex: En service", controller: _etatController),
                const SizedBox(height: 20),
                FormLabel(text: "Immatriculation"),
                FormTextField(hint: "Ex: AB-123-CD", controller: _immatriculationController),
                const SizedBox(height: 20),
                FormLabel(text: "ID de la ligne"),
                FormTextField(
                  hint: "Ex: 19",
                  controller: _ligneIdController,
                ),
                const SizedBox(height: 30),
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
                        text: widget.bus == null ? "Créer le bus" : "Modifier le bus",
                        onPressed: () {
                          final bus = buildBus();
                          if (widget.bus == null) {
                            context.read<BusBloc>().add(CreateBus(bus));
                          } else {
                            context.read<BusBloc>().add(UpdateBus(widget.bus!.id!, bus));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}