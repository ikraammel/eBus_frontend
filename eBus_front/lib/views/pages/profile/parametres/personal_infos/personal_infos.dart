import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/views/pages/profile/parametres/personal_infos/personal_infos_items.dart';
import '../../../../../bloc/auth/auth_bloc.dart';
import '../../../../../bloc/auth/auth_event.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../models/User.dart';
import '../../../../../utils/app_snack_bar.dart';
import '../../../../UI/buttons/app_button.dart';
import '../../../../UI/splash_screen.dart';

class PersonalInfos extends StatefulWidget {
  const PersonalInfos({super.key});

  @override
  State<PersonalInfos> createState() => _PersonalInfosState();
}

class _PersonalInfosState extends State<PersonalInfos> {
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController emailController;
  late TextEditingController telController;
  late TextEditingController adresseController;
  late TextEditingController dateController;
  User? currentUser;

  String? selectedAbonnement;

  @override
  void initState() {
    super.initState();

    nomController = TextEditingController();
    prenomController = TextEditingController();
    emailController = TextEditingController();
    telController = TextEditingController();
    adresseController = TextEditingController();
    dateController = TextEditingController();
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telController.dispose();
    adresseController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
        if(state is AuthProfileUpdated) {
          AppSnackBar.showSuccess(context, "Profil mis à jour avec succès!");
          
          Future.delayed(Duration(seconds: 3),(){
            if(mounted){
              Navigator.pop(context);
            }
          });
        }
        if (state is AuthFailure) {
          String friendlyMessage = "Une erreur est survenue";

          final error = state.error.toLowerCase();

          if (error.contains("email") || error.contains("users_email_key")) {
            friendlyMessage = "Cet email est déjà utilisé.";
          } else if (error.contains("tel") || error.contains("users_tel_key")) {
            friendlyMessage = "Ce numéro de téléphone est déjà utilisé.";
          } else if (error.contains("cin") || error.contains("users_cin_key")) {
            friendlyMessage = "Cette CIN est déjà utilisée.";
          }
          // fallback si aucune correspondance
          else {
            // pour éviter d’afficher toute la stack
            final lines = state.error.split("\n");
            friendlyMessage = lines.first;
          }

          AppSnackBar.showError(context, friendlyMessage);
        }
    },
      builder: (context,state){
        if (state is AuthAuthenticated) {
          currentUser = state.user;
        }

        if (currentUser == null) {
          return SplashScreen();
        }

        nomController.text = currentUser!.nom;
        prenomController.text = currentUser!.prenom;
        emailController.text = currentUser!.email;
        telController.text = currentUser!.tel;
        adresseController.text = currentUser!.adresse;
        dateController.text = currentUser!.dateNaissance;
        selectedAbonnement = (currentUser!.typeAbonnement?.isNotEmpty ?? false)
            ? currentUser!.typeAbonnement
            : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Informations personnelles",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.darkBlue,
            ),
            body: Container(
              padding: const EdgeInsets.all(20.0),
              child: Scrollbar(
                thickness: 8,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PersonalInfosItems(
                        label: 'Nom',
                        controller: nomController,
                        suffixIcon: Icons.edit,
                      ), PersonalInfosItems(
                        label: 'Prénom',
                        controller: prenomController,
                        suffixIcon: Icons.edit,
                      ),
                      PersonalInfosItems(
                        label: 'Email',
                        controller: emailController,
                        suffixIcon: Icons.edit,
                      ),
                      PersonalInfosItems(
                        label: 'Téléphone',
                        controller: telController,
                        suffixIcon: Icons.edit,
                      ),
                      PersonalInfosItems(
                        label: 'CIN',
                        value: currentUser!.cin,
                        readOnly: true,
                      ),
                      PersonalInfosItems(
                        label: 'Date de naissance',
                        controller: dateController,
                        suffixIcon: Icons.calendar_month,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.tryParse(
                                dateController.text) ?? DateTime(2005),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                            locale: const Locale('fr', 'FR'),
                          );
                          if (picked != null) {
                            dateController.text =
                            "${picked.year}-${picked.month.toString().padLeft(
                                2, '0')}-${picked.day.toString().padLeft(
                                2, '0')}";
                          }
                        },
                      ),
                      PersonalInfosItems(
                        label: 'Adresse',
                        controller: adresseController,
                        suffixIcon: Icons.edit,
                      ),
                      const SizedBox(height: 16),
                      PersonalInfosItems(
                        label: 'Type d\'abonnement',
                        value: selectedAbonnement ?? "-",
                        readOnly: true,
                        suffixIcon: Icons.card_membership,
                      ),

                      // DropdownButtonFormField<String>(
                      //   value: selectedAbonnement,
                      //   hint: const Text("Sélectionner un abonnement"),
                      //   decoration: InputDecoration(
                      //     labelText: "Type d'abonnement",
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //   ),
                      //   items: const [
                      //     DropdownMenuItem(value: 'SCOLAIRE',
                      //         child: Text('Scolaire')),
                      //     DropdownMenuItem(value: 'MENSUEL',
                      //         child: Text('Mensuel')),
                      //   ],
                      //   onChanged: (value) {
                      //     setState(() {
                      //       selectedAbonnement = value;
                      //     });
                      //   },
                      // ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: AppButton(
                          text: 'Enregistrer les modifications',
                          onPressed: () {
                            if (currentUser == null) return;
                            context.read<AuthBloc>().add(
                              AuthUpdateUserRequested(
                                id: currentUser!.id,
                                nom: nomController.text.trim().isEmpty
                                    ? null
                                    : nomController.text != currentUser!.nom
                                    ? nomController.text
                                    : null,

                                prenom: prenomController.text.trim().isEmpty
                                    ? null
                                    : prenomController.text != currentUser!.prenom
                                    ? prenomController.text
                                    : null,

                                email: emailController.text.trim().isEmpty
                                    ? null
                                    : emailController.text != currentUser!.email
                                    ? emailController.text
                                    : null,

                                tel: telController.text.trim().isEmpty
                                    ? null
                                    : telController.text != currentUser!.tel
                                    ? telController.text
                                    : null,

                                adresse: adresseController.text.trim().isEmpty
                                    ? null
                                    : adresseController.text != currentUser!.adresse
                                    ? adresseController.text
                                    : null,

                                dateNaissance: dateController.text.trim().isEmpty
                                    ? null
                                    : dateController.text != currentUser!.dateNaissance
                                    ? dateController.text
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
                ,
              ),
            ),
          );
      },
    );
  }
}
