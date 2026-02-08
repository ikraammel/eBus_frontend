import 'package:flutter/material.dart';

class DeclareLostObjectPage extends StatefulWidget {
  const DeclareLostObjectPage({super.key});

  @override
  State<DeclareLostObjectPage> createState() => _DeclareLostObjectPageState();
}

class _DeclareLostObjectPageState extends State<DeclareLostObjectPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedLine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8DC63F),
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
              _buildTextField("Ex: Portefeuille noir"),
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
              ),
              const SizedBox(height: 20),

              _buildLabel("Date approximative"),
              _buildTextField("jj/mm/aaaa", icon: Icons.calendar_today),
              const SizedBox(height: 20),

              _buildLabel("Description détaillée"),
              _buildTextField("Décrivez l'objet en détail...", maxLines: 4),
              const SizedBox(height: 20),

              _buildLabel("Votre email de contact"),
              _buildTextField("exemple@email.com", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Simulation de succès
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Déclaration envoyée !"),
                          backgroundColor: Color(0xFF8DC63F),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8DC63F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Soumettre la déclaration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour les titres des champs
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A367C),
          fontSize: 15,
        ),
      ),
    );
  }

  // Widget pour générer les champs de texte
  Widget _buildTextField(String hint, {IconData? icon, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint).copyWith(
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      ),
    );
  }

  // Décoration réutilisable pour les inputs
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8DC63F), width: 2),
      ),
    );
  }
}