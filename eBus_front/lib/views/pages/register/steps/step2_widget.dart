import 'package:flutter/material.dart';

import '../../../UI/shared_login_register/custom_text_field.dart';


class Step2Widget extends StatefulWidget {
  const Step2Widget({
    super.key,
    required this.cinController,
    required this.carteEudiantController,
    required this.typeAbonnement,
    required this.onTypeChanged
  });

  final TextEditingController cinController;
  final TextEditingController carteEudiantController;
  final String typeAbonnement;
  final Function(String) onTypeChanged;

  @override
  State<Step2Widget> createState() => _Step2WidgetState();
}

class _Step2WidgetState extends State<Step2Widget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: widget.cinController,
          hint: 'HH123456',
          label: 'CIN*',
          validator: (value){
            if(value == null || value.isEmpty){
              return "CIN obligatoire";
            }else{
              return null;
            }
          },
        ),
        Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Pour les élèves n'ayant pas l'âge légal pour détenir une CIN, "
                      "la CIN du tuteur doit être fournie à la place.",
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        CustomTextField(
          controller: widget.carteEudiantController,
          hint:'CNE (Code national de l étudiant) ou le code MASSAR',
          label: 'CNE/code Massar*',
          validator: (value){
            if(value == null || value.isEmpty){
              return "CNE obligatoire";
            }else{
              return null;
            }
          },
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: Text(
            'Type d\'abonnement*',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: widget.typeAbonnement,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'SCOLAIRE',
              child: Text('Scolaire'),
            ),
            DropdownMenuItem(
              value: 'MENSUEL',
              child: Text('Mensuel'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
            widget.onTypeChanged(value);
            }
          },
        ),
      ],
    );
  }
}
