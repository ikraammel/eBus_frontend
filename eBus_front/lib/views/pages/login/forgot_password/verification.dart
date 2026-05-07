import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/views/pages/login/forgot_password/new_password.dart';

import '../../../UI/buttons/app_button.dart';
import '../../../UI/shared_login_register/custom_text_field.dart';
import 'auth_header.dart';

class Verification extends StatefulWidget {
  const Verification({super.key, required this.email});

  final String email;

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {

          if (state is AuthCodeVerified) {
            AppSnackBar.showSuccess(context, "Code vérifié !");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewPassword(token: state.token),
              ),
            );
          }

          if (state is AuthFailure) {
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [

                  AuthHeader(
                    icon: Icons.email_outlined,
                    title: "Vérification",
                    subtitle: "Entrez le code envoyé à ${widget.email}",
                  ),

                  const SizedBox(height: 30),

                  CustomTextField(
                    controller: codeController,
                    label: "Code de réinitialisation",
                    hint: "Collez le code reçu par email",
                    prefixIcon: Icons.lock,
                  ),

                  const SizedBox(height: 40),

                  state is AuthLoading
                      ? const CircularProgressIndicator()
                      : AppButton(
                    text: "Vérifier le code",
                    color: AppColors.green,
                    onPressed: () {
                      final code = codeController.text.trim();

                      if (code.isEmpty) {
                        AppSnackBar.showError(
                            context, "Veuillez entrer le code");
                        return;
                      }

                      context.read<AuthBloc>().add(
                        AuthVerifyResetCodeRequested(
                          email: widget.email,
                          code: code,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        AuthForgotPasswordRequested(
                          email: widget.email,
                        ),
                      );
                    },
                    child: const Text("Renvoyer le code"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}