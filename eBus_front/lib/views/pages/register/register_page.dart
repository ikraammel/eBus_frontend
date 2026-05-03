import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/utils/password_utils.dart';
import 'package:smart_bus/views/pages/register/steps/step0_widget.dart';
import 'package:smart_bus/views/pages/register/steps/step1_widget.dart';
import 'package:smart_bus/views/pages/register/steps/step2_widget.dart';
import 'package:smart_bus/views/pages/register/steps/step3_widget.dart';
import 'package:smart_bus/views/pages/register/steps/step4_widget.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../models/request/register_request.dart';
import '../../../models/type_abonnement.dart';
import '../../../services/file_picker_service.dart';
import '../../../utils/app_snack_bar.dart';
import '../../UI/buttons/app_button.dart';
import '../../UI/shared_login_register/administrator_access.dart';
import '../../UI/shared_login_register/auth_header.dart';
import '../../UI/shared_login_register/guest_button.dart';
import '../../UI/shared_login_register/switch_auth_page.dart';
import '../../UI/splash_screen.dart';
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

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final FilePickerService _filePickerService = FilePickerService();
  XFile? _image;
  XFile? _carteScolaire;
  XFile? _cin;

  int? _selectedAbonnementId;
  String _typeAbonnementName = '';

  void nextStep() {
    bool isValid = false;

    switch (_currentPage) {
      case 0:
        isValid = _formKeyStep0.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _formKeyStep1.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _formKeyStep2.currentState?.validate() ?? false;
        if (isValid && _selectedAbonnementId == null) {
          AppSnackBar.showError(context, "Veuillez choisir un abonnement");
          isValid = false;
        }
        break;
      case 3:
        isValid = _image != null && _cin != null && _carteScolaire != null;
        if (!isValid) {
          AppSnackBar.showError(context, "Veuillez charger tous les documents obligatoires");
        }
        break;
    }
    if (!isValid) return;

    if (!mounted) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousStep() {
    if (_currentPage > 0) {
      if (!mounted) return;
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await _filePickerService.pickImage();
    if (pickedImage != null && mounted) setState(() => _image = pickedImage);
  }

  Future<void> _pickCarteScolaire() async {
    final pickedImage = await _filePickerService.pickImage();
    if (pickedImage != null && mounted) setState(() => _carteScolaire = pickedImage);
  }

  Future<void> _pickCin() async {
    final pickedImage = await _filePickerService.pickImage();
    if (pickedImage != null && mounted) setState(() => _cin = pickedImage);
  }

  bool _verifyPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final errorMessage = PasswordUtils.validatePassword(password, confirmPassword);
    if (errorMessage != null) {
      AppSnackBar.showError(context, errorMessage);
      return false;
    }
    return true;
  }

  @override
  void dispose() {
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          AppSnackBar.showSuccess(context, "Inscription réussie !");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
        } else if (state is AuthFailure) {
          AppSnackBar.showError(context, state.error);
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Header(label1: 'Inscription', label2: 'Rejoignez eBus'),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: PageView(
                          key: const PageStorageKey('register_view'),
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            if (mounted) setState(() => _currentPage = index);
                          },
                          children: [
                            Form(
                                key: _formKeyStep0,
                                child: Step0Widget(
                                    nomController: _nomController,
                                    prenomController: _prenomController)),
                            Form(
                                key: _formKeyStep1,
                                child: Step1Widget(
                                    adresseController: _adresseController,
                                    emailController: _emailController,
                                    phoneController: _phoneController,
                                    dateNaissanceController:
                                        _dateNaissanceController)),
                            Form(
                                key: _formKeyStep2,
                                child: Step2Widget(
                                  cinController: _cinController,
                                  carteEudiantController:
                                      _carteEudiantController,
                                  selectedAbonnementId: _selectedAbonnementId,
                                  onAbonnementChanged:
                                      (TypeAbonnement abonnement) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedAbonnementId = abonnement.id;
                                        _typeAbonnementName = abonnement.nom;
                                      });
                                    }
                                  },
                                )),
                            Step3Widget(
                              image: _image,
                              carteScolaire: _carteScolaire,
                              cin: _cin,
                              onPickImage: _pickImage,
                              onPickCarteScolaire: _pickCarteScolaire,
                              onPickCin: _pickCin,
                              typeAbonnement: _typeAbonnementName,
                            ),
                            Step4Widget(
                                passwordController: _passwordController,
                                confirmPasswordController:
                                    _confirmPasswordController),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (_currentPage > 0) ...[
                            Expanded(
                                child: AppButton(
                                    text: "Précédent", onPressed: previousStep)),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                              child: AppButton(
                                  text: _currentPage == 4
                                      ? 'S\'inscrire'
                                      : "Suivant",
                                  onPressed: _currentPage == 4
                                      ? () {
                                          if (!_verifyPassword()) return;
                                          if (_selectedAbonnementId == null) {
                                            AppSnackBar.showError(
                                                context, "Veuillez choisir un abonnement");
                                            return;
                                          }
                                          if (_image == null ||
                                              _cin == null ||
                                              _carteScolaire == null) {
                                            AppSnackBar.showError(context,
                                                "Veuillez charger tous les documents obligatoires");
                                            return;
                                          }

                                          final cneText = _carteEudiantController.text.trim();

                                          final registerRequest = RegisterRequest(
                                              nom: _nomController.text.trim(),
                                              prenom: _prenomController.text.trim(),
                                              email: _emailController.text.trim(),
                                              tel: _phoneController.text.trim(),
                                              password: _passwordController.text,
                                              adresse: _adresseController.text.trim(),
                                              dateNaissance:
                                                  _dateNaissanceController.text,
                                              abonnementId: _selectedAbonnementId!,
                                              cin: _cinController.text.trim(),
                                              cne: cneText.isEmpty ? null : cneText);
                                          
                                          context.read<AuthBloc>().add(
                                              AuthRegisterRequested(
                                                  request: registerRequest,
                                                  photo: _image!,
                                                  carteScolaire: _carteScolaire!,
                                                  cin: _cin!));
                                        }
                                      : nextStep)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SwitchAuthPage(
                          questionText: 'Déjà un compte ?',
                          actionText: 'Se connecter',
                          onTap: () =>
                              Navigator.pushNamed(context, '/loginPage')),
                      const SizedBox(height: 32),
                      const GuestButton(),
                      const SizedBox(height: 30),
                      const AdministratorAccess(),
                      const SizedBox(height: 40)
                    ],
                  ),
                ),
              ),
              if (state is AuthLoading)
                const SplashScreen(),
            ],
          ),
        );
      },
    );
  }
}
