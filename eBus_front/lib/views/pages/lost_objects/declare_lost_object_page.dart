import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/views/app_snack_bar/app_snack_bar.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/services/objet_perdu_service.dart';
import 'package:smart_bus/services/local_storage_service.dart'; // ← ajouté
import '../../../main.dart'; // ← ajouté

class DeclareLostObjectPage extends StatefulWidget {
  const DeclareLostObjectPage({super.key});

  @override
  State<DeclareLostObjectPage> createState() => _DeclareLostObjectPageState();
}

class _DeclareLostObjectPageState extends State<DeclareLostObjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _service = ObjetPerduService();
  LocalStorageService get _storage => getIt<LocalStorageService>(); // ← ajouté
  int? _userId; // ← ajouté

  String? selectedLine;
  bool _loading = false;

  @override
  void initState() { // ← ajouté
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async { // ← ajouté
    final id = _storage.getUserId();
    setState(() => _userId = id);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userId == null) { // ← ajouté
      AppSnackBar.showError(context, "Session expirée, reconnectez-vous.");
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.create(ObjetPerdu(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: selectedLine ?? '',
        dateDeclaration: DateTime.now().toIso8601String().split('T')[0],
        status: 'LOST',
        userId: _userId!, // ← modifié
      ));
      if (mounted) {
        AppSnackBar.showSuccess(context, "Déclaration envoyée !");
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, "Erreur : $e");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Déclarer un objet perdu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Nom de l'objet"),
              _buildTextField(
                controller: _nameCtrl,
                hint: "Ex: Portefeuille noir",
                validator: (v) =>
                    v == null || v.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 20),

              _buildLabel("Ligne où vous l'avez perdu"),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Sélectionner une ligne"),
                items: ["Ligne 12", "Ligne 5", "Ligne 8", "Ligne 3"]
                    .map((ligne) => DropdownMenuItem(
                          value: ligne,
                          child: Text(ligne),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedLine = value),
                validator: (v) =>
                    v == null ? "Veuillez sélectionner une ligne" : null,
              ),
              const SizedBox(height: 20),

              _buildLabel("Date approximative"),
              _buildTextField(
                controller: _dateCtrl,
                hint: "jj/mm/aaaa",
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 20),

              _buildLabel("Description détaillée"),
              _buildTextField(
                controller: _descCtrl,
                hint: "Décrivez l'objet en détail...",
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              _buildLabel("Votre email de contact"),
              _buildTextField(
                controller: _emailCtrl,
                hint: "exemple@email.com",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Soumettre la déclaration",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkBlue,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hint).copyWith(
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: AppColors.lightGreenBg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGreenBg),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGreenBg),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 2),
      ),
    );
  }
}
