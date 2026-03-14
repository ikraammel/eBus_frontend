import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';

import '../../../utils/app_snack_bar.dart';
import '../../UI/buttons/app_button.dart';
import '../../UI/form_label.dart';
import '../../UI/form_text_field.dart';
import '../../UI/input_decoration.dart';

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
              FormLabel(text: "Nom de l'objet"),
              FormTextField(hint:"Ex: Portefeuille noir"),
              const SizedBox(height: 20),

              FormLabel(text: "Ligne où vous l'avez perdu"),
              DropdownButtonFormField<String>(
                decoration: AppInputDecoration.input("Sélectionner une ligne"),
                items: ["Ligne 12", "Ligne 5", "Ligne 8", "Ligne 3"]
                    .map((ligne) => DropdownMenuItem(
                  value: ligne,
                  child: Text(ligne),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedLine = value),
              ),
              const SizedBox(height: 20),

              FormLabel(text: "Date approximative"),
              FormTextField(hint:"jj/mm/aaaa", icon: Icons.calendar_today),
              const SizedBox(height: 20),

              FormLabel(text: "Description détaillée"),
              FormTextField(hint:"Décrivez l'objet en détail...", maxLines: 4),
              const SizedBox(height: 20),

              FormLabel(text: "Votre email de contact"),
              FormTextField(hint:"exemple@email.com", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 40),

              AppButton(
                text: "Soumettre la déclaration",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    AppSnackBar.showSuccess(context, "Déclaration envoyée !");
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}