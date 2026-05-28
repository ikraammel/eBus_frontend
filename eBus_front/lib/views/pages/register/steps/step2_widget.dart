import 'package:flutter/material.dart';
import 'package:smart_bus/services/type_abonnement_service.dart';
import '../../../../models/type_abonnement.dart';
import '../../../UI/shared_login_register/custom_text_field.dart';

class Step2Widget extends StatefulWidget {
  const Step2Widget({
    super.key,
    required this.cinController,
    required this.carteEudiantController,
    required this.selectedAbonnementId,
    required this.onAbonnementChanged
  });

  final TextEditingController cinController;
  final TextEditingController carteEudiantController;
  final int? selectedAbonnementId;
  final Function(TypeAbonnement) onAbonnementChanged;

  @override
  State<Step2Widget> createState() => _Step2WidgetState();
}

class _Step2WidgetState extends State<Step2Widget> {
  final TypeAbonnementService _service = TypeAbonnementService();
  List<TypeAbonnement> _types = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final list = await _service.getAll();
      if (mounted) {
        setState(() {
          _types = list.where((t) => t.actif).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatTitle(String title) {
    if (title.isEmpty) return title;
    String formatted = title.replaceAll('_', ' ').toLowerCase();
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  bool _isStudentAbonnement(TypeAbonnement type) {
    final nom = type.nom
        .toUpperCase()
        .trim()
        .replaceAll("É", "E")
        .replaceAll("È", "E")
        .replaceAll("Ê", "E");
    return nom.contains('SCOLAIRE') || nom.contains('ETUDIANT');
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si le type actuellement sélectionné est scolaire ou étudiant
    bool isScolaireOrEtudiant = false;
    if (widget.selectedAbonnementId != null && _types.isNotEmpty) {
      try {
        final current = _types.firstWhere((t) => t.id == widget.selectedAbonnementId);
        isScolaireOrEtudiant = _isStudentAbonnement(current);
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.cinController,
          hint: 'HH123456',
          label: 'CIN*',
          validator: (value) => (value == null || value.isEmpty) ? "CIN obligatoire" : null,
        ),
        
        if (isScolaireOrEtudiant)
          CustomTextField(
            controller: widget.carteEudiantController,
            hint:'CNE ou Code MASSAR',
            label: 'CNE/code Massar*',
            validator: (value) {
              if(isScolaireOrEtudiant && (value == null || value.isEmpty)) return "CNE obligatoire";
              return null;
            },
          ),

        const Padding(
          padding: EdgeInsets.fromLTRB(5, 10, 0, 5),
          child: Text('Type d\'abonnement*', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),
        
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<int>(
            value: widget.selectedAbonnementId,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            ),
            items: _types.map<DropdownMenuItem<int>>((TypeAbonnement t) => DropdownMenuItem<int>(
              value: t.id,
              child: Text("${_formatTitle(t.nom)} (${t.prix} MAD)"),
            )).toList(),
            onChanged: (id) {
              if (id != null) {
                final selected = _types.firstWhere((t) => t.id == id);
                widget.onAbonnementChanged(selected);
              }
            },
          ),
      ],
    );
  }
}
