import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/views/app_snack_bar/app_snack_bar.dart';
import 'package:smart_bus/views/loading/splash_screen.dart';
import 'package:smart_bus/views/pages/login/forgot_password/new_password.dart';
import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../bloc/auth/auth_event.dart';
import '../../shared_login_register/auth_button.dart';
import 'auth_header.dart';

class Verification extends StatefulWidget {
  const Verification({super.key, required this.email});

  final String email;

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  List<TextEditingController> _codeControllers =
  List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthBloc,AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            AppSnackBar.showSuccess(context, "Code envoyé avec succès !");
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
        builder: (context, state){
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthHeader(
                    icon: Icons.email_outlined,
                    title: "Vérification",
                    subtitle: "Entrez le code envoyé à ${widget.email}",
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                          (index) => SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _codeControllers[index],
                          autofocus: index == 0,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: AppColors.darkBlue),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  state is AuthLoading
                      ? SplashScreen()
                      : AuthButton(
                    text: "Vérifier le code",
                    onPressed: () {
                      final code = _codeControllers.map((c) => c.text).join();

                      if (code.length != 6) {
                        AppSnackBar.showError(context, "Veuillez entrer le code complet");
                        return;
                      }

                      context.read<AuthBloc>().add(
                        AuthForgotPasswordRequested(
                          email: widget.email,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      children: [
                        const TextSpan(text: "Vous n'avez pas reçu le code ? "),
                        TextSpan(
                          text: "Renvoyer",
                          style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.read<AuthBloc>().add(
                                  AuthForgotPasswordRequested(
                                    email: widget.email,
                                  ),
                                );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}