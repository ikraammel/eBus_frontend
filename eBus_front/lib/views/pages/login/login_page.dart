import 'package:flutter/material.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/pages/home_page.dart';
import 'package:smart_bus/views/pages/login/forgot_password.dart';
import 'package:smart_bus/views/pages/shared_login_register/administrator_access.dart';
import 'package:smart_bus/views/pages/shared_login_register/auth_button.dart';
import 'package:smart_bus/views/pages/shared_login_register/auth_header.dart';
import 'package:smart_bus/views/pages/shared_login_register/switch_auth_page.dart';
import '../shared_login_register/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showHidePassword = true;

  Future<void> _login() async{
    try {
      AuthService authService = AuthService();
      final user = await authService.login(
        _emailController.text,
        _passwordController.text,
      );

      await LocalStorageService().saveUser(user);
      if(user.role == 'USER'){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }

    } catch (e) {
      print("ERREUR LOGIN: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header(label1: 'Connexion', label2: 'Bienvenue sur eBus'),

                CustomTextField(
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  hint: 'example@example.com',
                  label: 'Email',
                ),


                CustomTextField(
                  controller: _passwordController,
                  prefixIcon: Icons.email,
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
              AuthButton(onPressed: _login, text: 'Se Connecter'),
              SizedBox(height: 20,),
              SwitchAuthPage(
                  questionText: 'Vous n\'avez pas de compte ? ',
                  actionText: 'S\'inscrire',
                  onTap: () => Navigator.pushNamed(context, '/registerPage')
              ),
              SizedBox(height: 40,),
             AdministratorAccess(),
              ],
            ),
          )
      ),
    );
  }
}
