import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/views/pages/register/steps/step0_widget.dart';
import 'package:smart_bus/views/pages/register/steps/step1_widget.dart';
import 'package:smart_bus/views/pages/register/steps/step2_widget.dart';
import 'package:smart_bus/views/pages/register/steps/step3_widget.dart';
import 'package:smart_bus/views/pages/register/steps/step4_widget.dart';
import 'package:smart_bus/views/pages/shared_login_register/administrator_access.dart';
import 'package:smart_bus/views/pages/shared_login_register/auth_button.dart';
import 'package:smart_bus/views/pages/shared_login_register/auth_header.dart';
import 'package:smart_bus/views/pages/shared_login_register/guest_button.dart';
import 'package:smart_bus/views/pages/shared_login_register/switch_auth_page.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../models/request/register_request.dart';
import '../../../services/file_picker_service.dart';
import '../../app_snack_bar/app_snack_bar.dart';
import '../../loading/splash_screen.dart';
import '../home/home_page.dart';

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

  final _formKeyStep0 = GlobalKey<FormState>();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();
  final _formKeyStep4 = GlobalKey<FormState>();

  PageController _pageController = PageController();
  int _currentPage = 0;

  final FilePickerService _filePickerService = FilePickerService();
  XFile? _image;
  XFile? _carteScolaire;
  XFile? _cin;

  void nextStep() {
    bool isValid = false;

    switch (_currentPage) {
      case 0:
        isValid = _formKeyStep0.currentState!.validate();
        break;
      case 1:
        isValid = _formKeyStep1.currentState!.validate();
        break;
      case 2:
        isValid = _formKeyStep2.currentState!.validate();
        break;
      case 3:
        isValid = _image != null && _cin != null && _carteScolaire != null;
        if (!isValid) {
          AppSnackBar.showError(context, "Veuillez charger tous les documents obligatoires");
        }
        break;
    }
    if (!isValid) return;

    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousStep() {
      if (_currentPage > 0) {
        _pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut
        );
        setState(() {
          _currentPage--;
        });
      }
    }

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

  bool _verifyPassword(){
    final password = _passwordController.text;

    if (password.length < 8) {
      AppSnackBar.showError(context, "Le mot de passe doit contenir au moins 8 caractères");
      return false;
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      AppSnackBar.showError(context, "Le mot de passe doit contenir des lettres et des chiffres");
      return false;
    }
    return true;
  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    return BlocConsumer<AuthBloc,AuthState>(
          listener: (context,state){
            if(state is AuthAuthenticated){
              AppSnackBar.showSuccess(context, "Inscription réussie !");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
            }else if(state is AuthFailure){
              AppSnackBar.showError(context, state.error);
            }
          },
          builder: (BuildContext context, AuthState state) {
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
                        Header(label1: 'Inscription', label2: 'Rejoignez eBus'),
                        SizedBox(height:20),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index){
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            children: [
                              Form(
                                key: _formKeyStep0,
                                child: Step0Widget(
                                    nomController: _nomController,
                                    prenomController: _prenomController
                                ),
                              ),
                              Form(
                                key: _formKeyStep1,
                                child: Step1Widget(
                                  adresseController: _adresseController,
                                  emailController: _emailController,
                                  phoneController: _phoneController,
                                  dateNaissanceController: _dateNaissanceController,
                                ),
                              ), // Infos personnelles
                              Form(
                                key: _formKeyStep2,
                                child: Step2Widget(
                                  cinController: _cinController,
                                  carteEudiantController: _carteEudiantController,
                                  typeAbonnement: _typeAbonnement,
                                  onTypeChanged: (value) {
                                    setState(() {
                                      _typeAbonnement = value;
                                    });
                                  },
                                ),
                              ),
                              Form(
                                key: _formKeyStep3,
                                child: Step3Widget(
                                  image: _image,
                                  carteScolaire: _carteScolaire,
                                  cin: _cin,
                                  onPickImage: _pickImage,
                                  onPickCarteScolaire: _pickCarteScolaire,
                                  onPickCin: _pickCin,
                                ),
                              ),
                              Form(
                                key: _formKeyStep4,
                                child: Step4Widget(
                                  passwordController: _passwordController,
                                  confirmPasswordController: _confirmPasswordController,
                                ),
                              ), // Récapitulatif
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            if (_currentPage > 0) ...[
                              Expanded(
                                child: AuthButton(
                                  text: "Précédent",
                                  onPressed: previousStep,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                            Expanded(
                                child: AuthButton(
                                    text: _currentPage == 4 ? 'S\'inscrire' : "Suivant",
                                    onPressed: _currentPage == 4
                                      ? (){
                                      if(!_verifyPassword()){
                                        return;
                                      }
                                      if(_image == null || _cin == null || _carteScolaire == null){
                                        AppSnackBar.showError(context, "Veuillez charger tous les documents obligatoires");
                                        return;
                                      }

                                      if (_passwordController.text != _confirmPasswordController.text) {
                                        AppSnackBar.showError(context, "Les mots de passe ne correspondent pas");
                                        return;
                                      }
                                      final registerRequest = RegisterRequest(
                                          nom: _nomController.text,
                                          prenom: _prenomController.text,
                                          email: _emailController.text,
                                          tel: _phoneController.text,
                                          password: _passwordController.text,
                                          adresse: _adresseController.text,
                                          dateNaissance: _dateNaissanceController.text,
                                          typeAbonnement: _typeAbonnement,
                                          cin: _cinController.text,
                                          cne: _carteEudiantController.text
                                      );
                                      context.read<AuthBloc>().add(
                                          AuthRegisterRequested(
                                              request: registerRequest,
                                              photo: _image!,
                                              carteScolaire: _carteScolaire!,
                                              cin: _cin!
                                          )
                                      );
                                      }
                                        : nextStep
                                )
                            ),
                          ],
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
                        const SizedBox(height: 32),
                        const GuestButton(),
                        const SizedBox(height: 30),
                        const AdministratorAccess(),
                        const SizedBox(height: 40)
                      ],
                    ),
                  )
              ),
            );
          },
      );
  }
}