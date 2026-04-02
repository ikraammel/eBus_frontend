import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
   final TextEditingController controller;
   final IconData? prefixIcon;
   final Widget? suffixIcon;
   final String hint;
   final String label;
   final bool? obscureText;
   final Function()? onTap;
   final bool? readOnly;
   final String? Function(String?)? validator;

   const CustomTextField({
     super.key,
     required this.controller,
     this.prefixIcon,
     required this.hint,
     required this.label,
     this.obscureText,
     this.suffixIcon,
     this.onTap,
     this.readOnly = false,
     this.validator
   });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
        SizedBox(height:10),
        TextFormField(
          controller: controller,
          obscureText: obscureText ?? false,
          validator: validator,
          readOnly: readOnly ?? false,
            onTap: onTap,
            decoration:
          InputDecoration(
            hintText:hint,
            hintStyle: TextStyle(
            color: Colors.grey
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
          )
          )
        ),
        SizedBox(height: 10,),
      ],
    );
  }
}
