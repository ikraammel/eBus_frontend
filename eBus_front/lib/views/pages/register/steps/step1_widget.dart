import 'package:flutter/material.dart';

import '../../shared_login_register/custom_text_field.dart';

class Step1Widget extends StatefulWidget {
  const Step1Widget({
    super.key,
    required this.adresseController,
    required this.emailController,
    required this.phoneController,
    required this.dateNaissanceController,
  });

  final TextEditingController adresseController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController dateNaissanceController;

  @override
  State<Step1Widget> createState() => _Step1WidgetState();
}

class _Step1WidgetState extends State<Step1Widget> {

  @override
  Widget build(BuildContext context) {
    Future<void> _selectDateNaissance(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2005),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        locale: const Locale('fr', 'FR'),
      );

      if (picked != null) {
        setState(() {
          widget.dateNaissanceController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        });
      }
    }

    return Column(
      children: [
        CustomTextField(
          controller: widget.adresseController,
          hint: 'Avenue de la liberté',
          label: 'Adresse*',
          validator: (value){
            if(value == null || value.isEmpty){
              return "Adresse obligatoire";
            }else{
              return null;
            }
          },

        ),

        CustomTextField(
          controller: widget.emailController,
          hint: 'example@example.com',
          label: 'Email*',
          prefixIcon: Icons.email,
          validator: (value){
            if(value == null || value.isEmpty){
              return "Email obligatoire";
            }else{
              return null;
            }
          },
        ),

        CustomTextField(
          controller: widget.phoneController,
          hint: '0600000000',
          label: 'Tel*',
          prefixIcon: Icons.phone,
          validator: (value){
            if(value == null || value.isEmpty){
              return "Téléphone obligatoire";
            }else{
              return null;
            }
          },
        ),

        CustomTextField(
          controller: widget.dateNaissanceController,
          readOnly: true,
          hint: 'Choisir une date',
          prefixIcon: Icons.calendar_today,
          onTap: () => _selectDateNaissance(context),
          label: 'Date de naissance*',
          validator: (value){
            if(value == null || value.isEmpty){
              return "Date de naissance obligatoire";
            }else{
              return null;
            }
          },
        ),

      ],
    );
  }
}
