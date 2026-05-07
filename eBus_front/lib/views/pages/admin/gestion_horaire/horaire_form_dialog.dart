import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/horaire.dart';

class HoraireFormDialog extends StatefulWidget {
  final Horaire? horaire;
  final int ligneId;
  final ValueChanged<Horaire> onSave;

  const HoraireFormDialog({
    super.key,
    this.horaire,
    required this.ligneId,
    required this.onSave,
  });

  @override
  State<HoraireFormDialog> createState() => _HoraireFormDialogState();
}

class _HoraireFormDialogState extends State<HoraireFormDialog> {
  late TimeOfDay _heureDepart;
  late TimeOfDay _heureArrivee;
  final Set<String> _selectedJours = {};
  final _formKey = GlobalKey<FormState>();

  static const _jours = [
    "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.horaire != null) {
      _heureDepart = _parseTime(widget.horaire!.heureDepart);
      _heureArrivee = _parseTime(widget.horaire!.heureArrivee);
      // parse jours séparés par "-" ou ","
      _selectedJours.addAll(
        widget.horaire!.jours.split(RegExp(r'[-,]')).map((j) => j.trim()),
      );
    } else {
      _heureDepart = const TimeOfDay(hour: 7, minute: 0);
      _heureArrivee = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  TimeOfDay _parseTime(String s) {
    try {
      final parts = s.split(':');
      return TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  String _formatJours() => _selectedJours.join('-');

  Future<void> _pickTime(bool isDepart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isDepart ? _heureDepart : _heureArrivee,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDepart) {
          _heureDepart = picked;
        } else {
          _heureArrivee = picked;
        }
      });
    }
  }

  void _save() {
    if (_selectedJours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un jour")),
      );
      return;
    }

    final horaire = Horaire(
      id: widget.horaire?.id,
      ligneId: widget.ligneId,
      heureDepart: _formatTime(_heureDepart),
      heureArrivee: _formatTime(_heureArrivee),
      jours: _formatJours(),
    );
    widget.onSave(horaire);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.horaire == null ? "Ajouter un horaire" : "Modifier l'horaire",
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: AppColors.darkBlue),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heure départ
              const Text("Heure de départ",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _TimePicker(
                time: _heureDepart,
                onTap: () => _pickTime(true),
              ),

              const SizedBox(height: 16),

              // Heure arrivée
              const Text("Heure d'arrivée",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _TimePicker(
                time: _heureArrivee,
                onTap: () => _pickTime(false),
              ),

              const SizedBox(height: 16),

              // Jours
              const Text("Jours de service",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              // Raccourcis rapides
              Wrap(
                spacing: 6,
                children: [
                  _ShortcutChip(
                    label: "Lun-Ven",
                    onTap: () => setState(() {
                      _selectedJours.clear();
                      _selectedJours
                          .addAll(["Lun", "Mar", "Mer", "Jeu", "Ven"]);
                    }),
                  ),
                  _ShortcutChip(
                    label: "Tous",
                    onTap: () => setState(() {
                      _selectedJours.clear();
                      _selectedJours.addAll(_jours);
                    }),
                  ),
                  _ShortcutChip(
                    label: "Weekend",
                    onTap: () => setState(() {
                      _selectedJours.clear();
                      _selectedJours.addAll(["Sam", "Dim"]);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _jours.map((jour) {
                  final selected = _selectedJours.contains(jour);
                  return FilterChip(
                    label: Text(jour),
                    selected: selected,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selectedJours.add(jour);
                      } else {
                        _selectedJours.remove(jour);
                      }
                    }),
                    selectedColor: AppColors.darkBlue.withOpacity(0.15),
                    checkmarkColor: AppColors.darkBlue,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.darkBlue : Colors.black87,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.horaire == null ? "Ajouter" : "Modifier"),
        ),
      ],
    );
  }
}

class _TimePicker extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePicker({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatted =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.darkBlue),
            const SizedBox(width: 12),
            Text(
              formatted,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ShortcutChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: onTap,
      backgroundColor: AppColors.green.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}