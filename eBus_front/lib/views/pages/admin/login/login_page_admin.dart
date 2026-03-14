import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/views/pages/admin/admin_home_page/admin_home_page.dart';

import '../../../../utils/app_snack_bar.dart';
import '../../../UI/buttons/app_button.dart';
import '../../../UI/shared_login_register/custom_text_field.dart';

class LoginPageAdmin extends StatefulWidget {
  const LoginPageAdmin({super.key});

  @override
  State<LoginPageAdmin> createState() => _LoginPageAdminState();
}

class _LoginPageAdminState extends State<LoginPageAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showHidePassword = false;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc,AuthState>(
      listener: (context, state) {
        if(state is AuthAuthenticated){
          if(state.user.role == Role.ADMIN){
            AppSnackBar.showSuccess(context, "Connexion réussie !");
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdminHomePage())
            );
          }
        }
        else if(state is AuthFailure){
          return AppSnackBar.showError(context, state.error);
        }

      },
      builder: (context,state){
        return Scaffold(
          backgroundColor: Color(0xFF1A222D),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Color(0xFF2C353F),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 60,
                      color: AppColors.green,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "Espace Admin",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Connexion sécurisée",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15
                    ),
                  ),
                ),
                SizedBox(height: 35),
                CustomTextField(
                  controller: _emailController,
                  hint: "admin@ebus.com",
                  label: "Identifiant Admin",
                  textColor: Colors.white,
                ),
                SizedBox(height: 5),
                CustomTextField(
                  controller: _passwordController,
                  hint: "......",
                  label: "Mot de passe",
                  textColor: Colors.white,
                  obscureText: _showHidePassword,
                  suffixIcon: IconButton(
                      onPressed:(){
                        setState(() {
                          _showHidePassword = !_showHidePassword;
                        });
                      },
                      icon: Icon(
                        _showHidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      )),
                ),
                SizedBox(height: 15,),
                Center(
                  child: AppButton(
                    color: AppColors.green,
                    text: "Connexion Admin",
                    icon: Icons.shield_outlined,
                    onPressed: (){
                      context.read<AuthBloc>().add(
                        AuthLoginRequested(
                            email: _emailController.text,
                            password: _passwordController.text
                        )
                      );
                    },
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                    color: Color(0xFF232B35),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 18),
                      SizedBox(width: 10),
                      Text(
                        "Accès réservé aux administrateurs autorisés",
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
