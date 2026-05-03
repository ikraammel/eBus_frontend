import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/models/bus.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/services/bus_service.dart';
import 'package:smart_bus/services/file_picker_service.dart';

import '../../../constants/app_colors.dart';

class DeclareObjetPage extends StatefulWidget {
  const DeclareObjetPage({super.key});

  @override
  State<DeclareObjetPage> createState() => _DeclareObjetPageState();
}

class _DeclareObjetPageState extends State<DeclareObjetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contactCtrl = TextEditingController(); // Changé de _emailCtrl à _contactCtrl

  int? _selectedLigneId;
  Bus? _selectedBus;
  List<Bus> _availableBuses = [];
  bool _loadingBuses = false;

  DateTime? _date;
  TypeAnnonce _typeSelectionne = TypeAnnonce.PERTE;

  final FilePickerService _filePickerService = FilePickerService();
  final BusService _busService = BusService();
  XFile? _pickedImage;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose(); // Mis à jour
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _filePickerService.pickImage();
    if (image != null && mounted) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _fetchBuses(int ligneId) async {
    setState(() {
      _loadingBuses = true;
      _selectedBus = null;
      _availableBuses = [];
    });
    try {
      final buses = await _busService.getBusesByLigne(ligneId);
      debugPrint("BUSES LOADED: ${buses.length}");
      if (mounted) {
        setState(() {
          _availableBuses = buses;
          _loadingBuses = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR BUS: $e");
      if (mounted) setState(() => _loadingBuses = false);
    }
  }

  Color get _activeColor {
    return _typeSelectionne == TypeAnnonce.PERTE ? AppColors.darkBlue : AppColors.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _typeSelectionne == TypeAnnonce.PERTE ? 'Déclarer un objet perdu' : 'Déclarer un objet trouvé',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 24),
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildTextField("Nom de l'objet", _nomCtrl, Icons.inventory_2_outlined, 'Ex: Sac, Clés...'),
              const SizedBox(height: 20),
              _buildLigneSelector(),
              const SizedBox(height: 20),
              _buildBusSelector(),
              const SizedBox(height: 20),
              _buildDatePicker(),
              const SizedBox(height: 20),
              _buildTextField("Description", _descCtrl, Icons.description_outlined, 'Décrivez l\'objet...', maxLines: 3),
              const SizedBox(height: 20),
              _buildTextField("Contact (Téléphone)", _contactCtrl, Icons.phone_outlined, 'Votre numéro de téléphone', isPhone: true), // Mis à jour
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _typeSelectionne = TypeAnnonce.PERTE),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _typeSelectionne == TypeAnnonce.PERTE ? AppColors.darkBlue : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _typeSelectionne == TypeAnnonce.PERTE ? AppColors.darkBlue : Colors.grey.shade300),
              ),
              child: Text("J'ai perdu", textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: _typeSelectionne == TypeAnnonce.PERTE ? Colors.white : AppColors.darkBlue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _typeSelectionne = TypeAnnonce.TROUVE),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _typeSelectionne == TypeAnnonce.TROUVE ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _typeSelectionne == TypeAnnonce.TROUVE ? AppColors.primaryColor : Colors.grey.shade300),
              ),
              child: Text("J'ai trouvé", textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: _typeSelectionne == TypeAnnonce.TROUVE ? Colors.white : AppColors.primaryColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Photo de l'objet (Optionnel)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _pickedImage != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_a_photo_outlined, size: 40, color: _activeColor),
              const SizedBox(height: 8),
              Text("Ajouter une photo", style: TextStyle(color: _activeColor, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String hint, {int maxLines = 1, bool isEmail = false, bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryColor)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Champ requis';
            if (isEmail && !v.contains('@')) return 'Email invalide';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLigneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ligne concernée", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        BlocBuilder<LigneBloc, LigneState>(
          builder: (context, state) {
            if (state is LigneLoaded) {
              return DropdownButtonFormField<int>(
                value: _selectedLigneId,
                hint: const Text('Sélectionner la ligne'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.directions_bus_outlined, color: AppColors.primaryColor),
                ),
                items: state.lignes.map((l) => DropdownMenuItem(value: l.id, child: Text("Ligne ${l.numero}"))).toList(),
                onChanged: (id) {
                  if (id != null) {
                    setState(() => _selectedLigneId = id);
                    _fetchBuses(id);
                  }
                },
                validator: (v) => v == null ? 'Choisissez une ligne' : null,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }

  Widget _buildBusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bus concerné (Optionnel)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        if (_loadingBuses)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<Bus>(
            value: _selectedBus,
            hint: const Text('Sélectionner le bus'),
            disabledHint: const Text('Sélectionnez d\'abord une ligne'),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.directions_bus, color: AppColors.primaryColor),
            ),
            items: _availableBuses.map((b) => DropdownMenuItem(value: b, child: Text("${b.numero} - ${b.immatriculation}"))).toList(),
            onChanged: _selectedLigneId == null ? null : (Bus? bus) => setState(() => _selectedBus = bus),
          ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date de l'événement", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(text: _date == null ? '' : '${_date!.day}/${_date!.month}/${_date!.year}'),
          decoration: InputDecoration(
            hintText: 'Cliquer pour choisir une date',
            prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onTap: _pickDate,
          validator: (v) => _date == null ? 'Date requise' : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _activeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _submit,
        child: const Text("VALIDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (d != null && mounted) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final objetData = {
      'nom': _nomCtrl.text,
      'description': _descCtrl.text,
      'ligneId': _selectedLigneId,
      'busId': _selectedBus?.id,
      'contact': _contactCtrl.text,
      'type': _typeSelectionne.name,
      'statut': StatutObjet.EN_ATTENTE.name,
      'dateDeclaration': (_date ?? DateTime.now()).toIso8601String(),
      'userId': 1,
    };

    context.read<ObjetPerduBloc>().add(AddObjetPerdu(
      objetData: objetData,
      image: _pickedImage,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déclaration envoyée !'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}
