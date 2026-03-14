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
   final Color? textColor;
   final Color? inputColor;

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
     this.validator,
     this.textColor = Colors.black,
     this.inputColor = Colors.grey
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
                color: textColor,
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
          style: TextStyle(
            color: textColor
          ),
          decoration:
          InputDecoration(
            hintText:hint,
            hintStyle: TextStyle(
            color: inputColor
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
