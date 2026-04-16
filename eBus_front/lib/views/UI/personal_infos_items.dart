import 'package:flutter/material.dart';

class PersonalInfosItems extends StatelessWidget {
  const PersonalInfosItems({
    super.key,
    required this.label,
    this.controller,
    this.value,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap
  });

  final String label;
  final TextEditingController? controller;
  final String? value;
  final bool readOnly;
  final IconData? suffixIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        TextField(
          controller:controller ?? TextEditingController(text: value),
          readOnly: readOnly || controller == null,
          onTap: onTap,
          decoration: InputDecoration(
            suffixIcon: Icon(suffixIcon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

      ],
    );
  }
}
