import 'package:flutter/material.dart';

import '../../../UI/shared_login_register/custom_text_field.dart';

class Step4Widget extends StatefulWidget {


  const Step4Widget({super.key,required this.passwordController,required this.confirmPasswordController});
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  @override
  State<Step4Widget> createState() => _Step4WidgetState();
}

class _Step4WidgetState extends State<Step4Widget> {

  bool _showHidePassword = true;
  bool _showHideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: widget.passwordController,
          obscureText: _showHidePassword,
          hint:'*******',
          label: 'Mot de passe*',
          prefixIcon: Icons.lock,
          suffixIcon: IconButton(
              onPressed: (){
                setState(() {
                  _showHidePassword = !_showHidePassword;
                });
              },
              icon: Icon(
                _showHidePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              )),
          validator: (value){
            if(value == null || value.isEmpty){
              return "Mot de passe obligatoire";
            }else{
              return null;
            }
          },
        ),

        CustomTextField(
          controller: widget.confirmPasswordController,
          obscureText: _showHideConfirmPassword,
          hint:'*******',
          label: 'Confirmez le Mot de passe*',
          prefixIcon: Icons.lock,
          validator: (value){
            if(value == null || value.isEmpty){
              return "Veuillez confirmez le mot de passe";
            }else{
              return null;
            }
          },
          suffixIcon: IconButton(
              onPressed: (){
                setState(() {
                  _showHideConfirmPassword = !_showHideConfirmPassword;
                });
              },
              icon: Icon(
                _showHideConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              )),
        ),
      ],
    );
  }
}
