import 'package:flutter/material.dart';

import '../../shared_login_register/custom_text_field.dart';

class Step0Widget extends StatefulWidget {
  const Step0Widget({
    super.key,
    required this.nomController,
    required this.prenomController,
  });

  final TextEditingController nomController;
  final TextEditingController prenomController;

  @override
  State<Step0Widget> createState() => _Step0WidgetState();
}

class _Step0WidgetState extends State<Step0Widget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: widget.nomController,
          hint: 'El Hafi',
          label: 'Nom*',
          validator: (value){
            if(value == null || value.isEmpty){
              return "Nom obligatoire";
            }else{
              return null;
            }
          },
        ),

        CustomTextField(
          controller: widget.prenomController,
          hint: 'Ismail',
          label: 'Prénom*',
          validator: (value){
            if(value == null || value.isEmpty){
              return "Prénom obligatoire";
            }else{
              return null;
            }
          },
        ),

      ],
    );
  }
}
