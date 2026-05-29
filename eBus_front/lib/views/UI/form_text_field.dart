import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'input_decoration.dart';

class FormTextField extends StatelessWidget {

  final String hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;

  const FormTextField({
    super.key,
    required this.hint,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.validator,
    this.readOnly=false
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      cursorColor: AppColors.darkBlue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      decoration: AppInputDecoration.input(hint).copyWith(
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      ),
    );
  }
}
