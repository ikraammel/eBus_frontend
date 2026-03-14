import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/pages/admin/admin_home_page/admin_home_page.dart';
import 'package:smart_bus/views/pages/login/forgot_password/forgot_password.dart';
import '../../../enums/enums.dart';
import '../../../main.dart';
import '../../../utils/app_snack_bar.dart';
import '../../UI/buttons/app_button.dart';
import '../../UI/shared_login_register/administrator_access.dart';
import '../../UI/shared_login_register/auth_header.dart';
import '../../UI/shared_login_register/custom_text_field.dart';
import '../../UI/shared_login_register/guest_button.dart';
import '../../UI/shared_login_register/switch_auth_page.dart';
import '../home/home_page.dart';

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
                if(state.user.role == Role.USER){
                  AppSnackBar.showSuccess(context, "Connexion réussie !");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                  );
                }
                if(state.user.role == Role.ADMIN){
                  AppSnackBar.showSuccess(context, "Connexion réussie !");
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AdminHomePage())
                  );
                }
              }
              else if (state is AuthFailure ) {
                AppSnackBar.showError(context, state.error);
              }
            },
            builder: (context, state) {
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ForgotPassword(),)
                          );
                        },
                        child: Text('Mot de passe oublié ?',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ]
                ),
                    SizedBox(height: 20,),
                    AppButton(
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