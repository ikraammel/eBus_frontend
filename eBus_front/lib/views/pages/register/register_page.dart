import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/models/request/register_request.dart';
import 'package:smart_bus/services/auth_service.dart';
import 'package:smart_bus/services/local_storage_service.dart';
import 'package:smart_bus/views/pages/home_page.dart';
import 'package:smart_bus/views/pages/register/file_picker_field.dart';
import 'package:smart_bus/views/pages/shared_login_register/administrator_access.dart';
import 'package:smart_bus/views/pages/shared_login_register/auth_button.dart';
import 'package:smart_bus/views/pages/shared_login_register/custom_text_field.dart';
import 'package:smart_bus/views/pages/shared_login_register/auth_header.dart';
import 'package:smart_bus/views/pages/shared_login_register/switch_auth_page.dart';

import '../../../models/User.dart';
import '../../../services/file_picker_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _carteEudiantController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _showHidePassword = true;
  bool _showHideConfirmPassword = true;

  final FilePickerService _filePickerService = FilePickerService();
  XFile? _image;
  XFile? _carteScolaire;
  XFile? _cin;

  Future<void> _pickImage() async{
    final pickedImage = await _filePickerService.pickImage();
    if (pickedImage != null){
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _pickCarteScolaire() async{
    final pickedImage = await _filePickerService.pickImage();
    if (pickedImage != null){
      setState(() {
        _carteScolaire = pickedImage;
      });
    }
  }

  Future<void> _pickCin() async{
    final pickedImage = await _filePickerService.pickImage();
    if (pickedImage != null){
      setState(() {
        _cin = pickedImage;
      });
    }
  }

  String _typeAbonnement = 'SCOLAIRE';
  Future<void> _selectDateNaissance(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _dateNaissanceController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }


  bool _verifyPassword(){
    final password = _passwordController.text;

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le mot de passe doit contenir au moins 8 caractères")),
      );
      return false;
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le mot de passe doit contenir des lettres et des chiffres")),
      );
      return false;
    }
    return true;
  }

  Future<void> _register() async{
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _adresseController.text.isEmpty ||
        _dateNaissanceController.text.isEmpty ||
        _cinController.text.isEmpty ||
        _carteEudiantController.text.isEmpty ||
        _dateNaissanceController.text.isEmpty
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Veuillez remplir tous les champs obligatoires"))
      );
      return;
    }if(_image == null || _cin == null || _carteScolaire == null){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Veuillez charger tous les documents obligatoires"))
      );

    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }
    if(!_verifyPassword()){
      return;
    }

    AuthService authService = AuthService();
    try {
      final registerRequest = RegisterRequest(
          nom: _nomController.text,
          prenom: _prenomController.text,
          email: _emailController.text,
          tel: _phoneController.text,
          password: _passwordController.text,
          adresse: _adresseController.text,
          dateNaissance: _dateNaissanceController.text,
          typeAbonnement: _typeAbonnement,
          CIN: _cinController.text,
          CNE: _carteEudiantController.text
      );
      final User newUser = await authService.register(
          registerRequest,
          _image!,
          _carteScolaire!,
          _cin!
      );
      final localStorage = LocalStorageService();
      await localStorage.saveUser(newUser);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(currentUser:newUser)),
      );
    } catch (e) {
      String errorMessage = "Une erreur est survenue";

      final exception = e.toString();

      if (exception.contains('403')) {
        errorMessage = "Email déjà utilisé";
      } else if (exception.contains('400')) {
        errorMessage = "Requête invalide. Vérifiez vos informations";
      } else if (exception.contains('500')) {
        errorMessage = "Erreur serveur, veuillez réessayer plus tard";
      } else if (exception.contains('Network')) {
        errorMessage = "Impossible de se connecter. Vérifiez votre connexion internet";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _adresseController.dispose();
    _phoneController.dispose();
    _cinController.dispose();
    _carteEudiantController.dispose();
    _dateNaissanceController.dispose();
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
                Header(label1: 'Inscription', label2: 'Rejoignez eBus'),
                SizedBox(height:20),

                CustomTextField(
                    controller: _nomController,
                    hint: 'El Hafi',
                    label: 'Nom*',
                ),

                CustomTextField(
                    controller: _prenomController,
                    hint: 'Ismail',
                    label: 'Prénom*',
                ),

                CustomTextField(
                    controller: _adresseController,
                    hint: 'Avenue de la liberté',
                    label: 'Adresse*',

                ),

                CustomTextField(
                    controller: _emailController,
                    hint: 'example@example.com',
                    label: 'Email*',
                    prefixIcon: Icons.email,
                ),

                CustomTextField(
                    controller: _phoneController,
                    hint: '0600000000',
                    label: 'Tel*',
                    prefixIcon: Icons.phone,
                ),

                CustomTextField(
                    controller: _cinController,
                    hint: 'HH123456',
                    label: 'CIN*',
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100], // couleur douce pour l'info
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Pour les élèves n'ayant pas l'âge légal pour détenir une CIN, "
                              "la CIN du tuteur doit être fournie à la place.",
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomTextField(
                    controller: _carteEudiantController,
                    hint:'CNE (Code national de l étudiant) ou le code MASSAR',
                    label: 'CNE/code Massar*',
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    'Type d\'abonnement*',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _typeAbonnement,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'SCOLAIRE',
                      child: Text('Scolaire'),
                    ),
                    DropdownMenuItem(
                      value: 'UNIVERSITAIRE',
                      child: Text('Universitaire'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _typeAbonnement = value!;
                    });
                  },
                ),
                SizedBox(height: 20),

                CustomTextField(
                  controller: _dateNaissanceController,
                  readOnly: true,
                  hint: 'Choisir une date',
                  prefixIcon: Icons.calendar_today,
                  onTap: () => _selectDateNaissance(context),
                  label: 'Date de naissance*',
                ),

                FilePickerField(
                    label: "Photo *",
                    image: _image,
                    onPick: _pickImage,
                    placeholder: "Charger la photo (PNG/JPG – max 1MB)"
                ),

                FilePickerField(
                    label: "Carte scolaire *",
                    image: _carteScolaire,
                    onPick: _pickCarteScolaire,
                    placeholder:"Charger la photo (PNG/JPG – max 1MB)"
                ),

                FilePickerField(
                    label: "CIN *",
                    image: _cin,
                    onPick: _pickCin,
                    placeholder:"Charger la photo (PNG/JPG – max 1MB)"
                ),

                CustomTextField(
                  controller: _passwordController,
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
                ),

                CustomTextField(
                  controller: _confirmPasswordController,
                  obscureText: _showHideConfirmPassword,
                  hint:'*******',
                  label: 'Confirmez le Mot de passe*',
                  prefixIcon: Icons.lock,
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

                Center(
                  child: AuthButton(
                      text: 'S\'inscrire',
                      onPressed: _register
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SwitchAuthPage(
                          questionText: 'Vous avez déjà un compte ?',
                          actionText: 'Se connecter',
                          onTap:() => Navigator.pushNamed(context, '/loginPage')
                      )
                    ]
                ),
                SizedBox(height: 70,),
                AdministratorAccess(),
              ],
            ),
          )
      ),
    );
  }
}
