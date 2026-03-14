import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import '../../../../constants/app_colors.dart';
import '../../../../utils/app_snack_bar.dart';
import '../../../../utils/password_utils.dart';
import '../../../UI/buttons/app_button.dart';
import '../../../UI/shared_login_register/custom_text_field.dart';
import 'auth_header.dart';

class NewPassword extends StatefulWidget {
  final String token;
  const NewPassword({super.key, required this.token});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  late String _token;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _showHideConfirmPassword = false;
  bool _showHidePassword = false;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
  }

  @override
  void dispose(){
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthBloc,AuthState>(
        listener: (context, state) {
          if(state is ResetPasswordSuccess){
            AppSnackBar.showSuccess(context, "Mot de passe réinitialisé !");
            Navigator.pushReplacementNamed(context, "/resetSuccess");
          }
          if(state is AuthFailure){
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthHeader(
                    icon: Icons.lock,
                    title: "Nouveau mot de passe",
                    subtitle: "Choisissez un mot de passe sécurisé",
                  ),
                  SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: passwordController,
                        obscureText: _showHidePassword,
                        hint: '*******',
                        label: 'Mot de passe',
                        prefixIcon: Icons.lock,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showHidePassword = !_showHidePassword;
                            });
                          },
                          icon: Icon(
                            _showHidePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: confirmPasswordController,
                        obscureText: _showHideConfirmPassword,
                        hint: '*******',
                        label: 'Confirmez le mot de passe',
                        prefixIcon: Icons.lock,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showHideConfirmPassword = !_showHideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _showHideConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Le mot de passe doit contenir :",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildValidationRow("Au moins 8 caractères", false),
                        _buildValidationRow("Une majuscule", false),
                        _buildValidationRow("Un chiffre", false),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  AppButton(
                    text: state is AuthLoading
                    ? "Chargement..."
                    : 'Réinitialiser le mot de passe',
                    color: AppColors.green,
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                      FocusScope.of(context).unfocus();

                      final errorMessage = PasswordUtils.validatePassword(
                        passwordController.text,
                        confirmPasswordController.text,
                      );

                      if (errorMessage != null) {
                        AppSnackBar.showError(context, errorMessage);
                        return;
                      }

                      context.read<AuthBloc>().add(
                        AuthResetPasswordRequested(
                          token: _token,
                          newPassword: passwordController.text,
                        ),
                      );
                    },
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

Widget _buildValidationRow(String text, bool isValid) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isValid ? AppColors.green : Colors.grey[400],
          ),
        ),
        SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
      ],
    ),
  );
}