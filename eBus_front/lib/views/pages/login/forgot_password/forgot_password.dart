import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/views/pages/login/forgot_password/verification.dart';

import '../../../../constants/app_colors.dart';
import '../../../../utils/app_snack_bar.dart';
import '../../../UI/buttons/app_button.dart';
import '../../../UI/shared_login_register/custom_text_field.dart';
import 'auth_header.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc,AuthState>(
      listener: (context, state) {
        if(state is ForgotPasswordSuccess){
          AppSnackBar.showSuccess(context, "Code envoyé avec succès");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => Verification(email: _emailController.text,)
              )
          );
        }
        if(state is AuthFailure){
          AppSnackBar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthHeader(
                    icon: Icons.key_outlined,
                    title: "Mot de passe oublié ?",
                    subtitle:"Entrez votre adresse email pour recevoir un code de vérification",
                  ),
                  SizedBox(height: 30,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                          controller: _emailController,
                          prefixIcon: Icons.email,
                          hint: "example@exmaple.com",
                          label: "Email"
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                  AppButton(
                      color: AppColors.green,
                      text: state is AuthLoading
                      ? "Envoi"
                      : "Envoyer le code",
                      onPressed: state is AuthLoading
                        ? null
                        : (){
                        context.read<AuthBloc>().add(
                          AuthForgotPasswordRequested(
                              email: _emailController.text
                          ),
                        );
                      },
                  ),
                  SizedBox(height: 20,),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Retour à la connexion",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );

  }
}
