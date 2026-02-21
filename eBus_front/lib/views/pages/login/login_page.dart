import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/app_snack_bar/app_snack_bar.dart';
import 'package:smart_bus/views/loading/splash_screen.dart';
import 'package:smart_bus/views/pages/login/forgot_password.dart';
import 'package:smart_bus/views/pages/shared_login_register/administrator_access.dart';
import 'package:smart_bus/views/pages/shared_login_register/auth_button.dart';
import 'package:smart_bus/views/pages/shared_login_register/auth_header.dart';
import 'package:smart_bus/views/pages/shared_login_register/guest_button.dart';
import 'package:smart_bus/views/pages/shared_login_register/switch_auth_page.dart';
import '../../../main.dart';
import '../home/home_page.dart';
import '../shared_login_register/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  LocalStorageService get _storage => getIt<LocalStorageService>();
  final AuthService _authService = getIt<AuthService>();

  bool _showHidePassword = true;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                AppSnackBar.showSuccess(context, "Connexion réussie !");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              } else if (state is AuthFailure) {
                AppSnackBar.showError(context, state.error);
              }
            },
            builder: (context, state) {
              if (state is AuthLoading){
                return SplashScreen();
              }
              return Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      label1: 'Connexion',
                      label2: 'Bienvenue sur eBus',
                      image: 'assets/logobus1.png',
                    ),

                    CustomTextField(
                      controller: _emailController,
                      prefixIcon: Icons.email,
                      hint: 'example@example.com',
                      label: 'Email',
                    ),


                    CustomTextField(
                      controller: _passwordController,
                      prefixIcon: Icons.lock,
                      hint: '*******',
                      label: 'Mot de passe',
                      obscureText: _showHidePassword,
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
                    ),

                    ForgotPassword(),
                    SizedBox(height: 20,),
                    AuthButton(
                        onPressed: (){
                          context.read<AuthBloc>().add(
                            AuthLoginRequested(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                        },
                        text: 'Se Connecter'
                    ),
                    SizedBox(height: 20,),
                    SwitchAuthPage(
                        questionText: 'Vous n\'avez pas de compte ? ',
                        actionText: 'S\'inscrire',
                        onTap: () => Navigator.pushNamed(context, '/registerPage')
                    ),
                    const SizedBox(height: 32),
                    const GuestButton(),
                    const SizedBox(height: 30),
                    const AdministratorAccess(),
                    const SizedBox(height: 40)
                  ],
                ),
              ),
          ),
              );
            },
    );
  }
}