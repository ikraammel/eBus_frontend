import 'package:flutter/material.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/pages/home_page.dart';

import '../../models/User.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showHidePassword = true;

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
                Center(child: Image.asset('assets/logobus.png',height: 250,width: 300,)),
                Center(
                  child: Text(
                    'Connexion',
                     style: TextStyle(
                         color: Color(0xFF1A367C),
                          fontWeight: FontWeight.bold,
                       fontSize: 24
                     ),
                  ),
                ),
                Center(
                  child: Text(
                    'Bienvenue sur eBus',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 18
                    ),
                  ),
                ),
                SizedBox(height:20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                      'Email',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                SizedBox(height:10),
                TextField(
                  controller: _emailController,
                    decoration:
                    InputDecoration(
                      hintText: 'example@example.com',
                      hintStyle: TextStyle(
                        color: Colors.grey
                      ),
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    )
                ),
                SizedBox(height:20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    'Mot de passe',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                SizedBox(height:10),
                TextField(
                    controller: _passwordController,
                    obscureText: _showHidePassword,
                    decoration:
                InputDecoration(
                    hintText: '*******',
                    hintStyle: TextStyle(
                        color: Colors.grey
                    ),
                    prefixIcon: Icon(Icons.lock),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Mot de passe oublié ?',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
                ),
              SizedBox(height: 20,),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    AuthService authService = AuthService();
                    try {
                      final response = await authService.login(
                          _emailController.text,
                          _passwordController.text
                      );
                      final user = User(
                        id: response['id'],
                        nom: response['nom'],
                        prenom: response['prenom'],
                        email: response['email'],
                        role: response['role'],
                        tel: response['tel'],
                        adresse: response['adresse'],
                      );

                      await LocalStorageService().saveUser(user);

                      if(response['role'] == 'USER'){
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
                  ,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A367C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                      'Se Connecter',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                  ),
                ),
              ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Vous n\'avez pas de compte ? '),
                GestureDetector(
                  onTap: () {},
                  child: Text('S\'inscrire',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold
                    ),
                )
                ),
              ]
            ),
                SizedBox(height: 70,),
                Center(
                  child: Text(
                    'Accès administrateur',
                    style: TextStyle(
                      color: Colors.grey
                    ),),
                )
              ],
            ),
          )
      ),
    );
  }
}
