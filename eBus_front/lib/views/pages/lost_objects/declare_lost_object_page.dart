import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/constants/constants.dart';
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/models/statut_objet.dart';

class DeclareObjetPage extends StatefulWidget {
  const DeclareObjetPage({super.key});

  @override
  State<DeclareObjetPage> createState() => _DeclareObjetPageState();
}

class _DeclareObjetPageState extends State<DeclareObjetPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String? _ligneSel;
  DateTime? _date;
  TypeAnnonce _typeSelectionne = TypeAnnonce.PERTE;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _typeSelectionne == TypeAnnonce.PERTE
        ? Colors.orange
        : const Color(0xFF6DC24B);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: activeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _typeSelectionne == TypeAnnonce.PERTE
              ? 'Déclarer un objet perdu'
              : 'Déclarer un objet trouvé',
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


              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _typeSelectionne = TypeAnnonce.PERTE),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _typeSelectionne == TypeAnnonce.PERTE
                              ? Colors.orange
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "J'ai perdu",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _typeSelectionne == TypeAnnonce.PERTE
                                ? Colors.white
                                : Colors.black54,
                          ),
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
                          color: _typeSelectionne == TypeAnnonce.TROUVE
                              ? const Color(0xFF6DC24B)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "J'ai trouvé",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _typeSelectionne == TypeAnnonce.TROUVE
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _label("Nom de l'objet"),
              TextFormField(
                controller: _nomCtrl,
                decoration: _inputDecor('Ex: Sac, Clés...', Icons.inventory_2_outlined),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),

              const SizedBox(height: 20),

              _label("Ligne concernée"),
              DropdownButtonFormField<String>(
                value: _ligneSel,
                hint: const Text('Sélectionner la ligne'),
                items: AppConstants.lignes
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() => _ligneSel = v),
                decoration: _inputDecor('', Icons.directions_bus_outlined),
                validator: (v) => v == null ? 'Choisissez une ligne' : null,
              ),

              const SizedBox(height: 20),

              _label("Date de l'événement"),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _date == null
                      ? ''
                      : '${_date!.day}/${_date!.month}/${_date!.year}',
                ),
                decoration: _inputDecor(
                    'Cliquer pour choisir une date',
                    Icons.calendar_today_outlined),
                onTap: _pickDate,
                validator: (v) => v == null || v.isEmpty ? 'Date requise' : null,
              ),

              const SizedBox(height: 20),

              _label("Description"),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: _inputDecor(
                    'Décrivez l\'objet...',
                    Icons.description_outlined),
                validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
              ),

              const SizedBox(height: 20),

              _label("Email de contact"),
              TextFormField(
                controller: _emailCtrl,
                decoration: _inputDecor('Email', Icons.email_outlined),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Email invalide' : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                  ),
                  onPressed: _submit,
                  child: const Text("VALIDER",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
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
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final objetData = {
      'nom': _nomCtrl.text,
      'description': _descCtrl.text,
      'ligne': _ligneSel,
      'contact': _emailCtrl.text,

      'type': _typeSelectionne.name,
      'statut': StatutObjet.EN_ATTENTE.name,
      'dateDeclaration': (_date ?? DateTime.now()).toIso8601String(),
      'userId': 1,
    };

    context.read<ObjetPerduBloc>().add(AddObjetPerdu(objetData: objetData));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déclaration envoyée !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  InputDecoration _inputDecor(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
