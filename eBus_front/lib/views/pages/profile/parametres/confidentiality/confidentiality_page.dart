import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/main.dart';
import 'package:smart_bus/services/auth_service.dart';
import '../../../../../bloc/auth/auth_bloc.dart';
import '../../../../../bloc/auth/auth_event.dart';
import '../../../../../bloc/auth/auth_state.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../utils/app_snack_bar.dart';
import '../../../../UI/list_tile_items.dart';
import '../../../../UI/splash_screen.dart';
import '../../../../UI/switch_list_tile_items.dart';

class ConfidentialityPage extends StatefulWidget {
  const ConfidentialityPage({super.key});


  @override
  State<ConfidentialityPage> createState() => _ConfidentialityPageState();
}

class _ConfidentialityPageState extends State<ConfidentialityPage> {
  bool locationEnabled = false;
  bool usageDataEnabled = true;
  bool publicProfileEnabled = false;
  bool historyEnabled = true;

  AuthService authService = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confidentialité',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.green,
      ),
      body: BlocConsumer<AuthBloc,AuthState>(
        listener: (context, state) {
          if(state is AuthFailure){
            AppSnackBar.showError(context, state.error);
          }
          if(state is AuthUnauthenticated){
            AppSnackBar.showSuccess(context, "Compte supprimé avec succès");
            Navigator.of(context).pushNamedAndRemoveUntil(
                "/loginPage",
                (route) => false
            );
          }
        },
        builder: (context,state){
          if(state is AuthLoading){
            return SplashScreen();
          }
          if(state is AuthAuthenticated){
            final id = state.user.id;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 15),
                child: Column(
                  children: [
                    ListTileItems(
                      title: 'Vos données sont protégées',
                      subtitle: "Nous respectons votre vie privée",
                      color: Colors.green[100],
                      prefixIcon: Icons.shield_outlined,
                      prefixIconColor: AppColors.green,
                    ),
                    SwitchListTileItems(
                        title: "Partage de position",
                        subtitle: "Permet à l'app d'accéder à votre position",
                        value: locationEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            locationEnabled = value;
                          });
                        }
                    ),
                    SwitchListTileItems(
                        title: "Données d'utilisation",
                        subtitle: "Aider à améliorer l'application",
                        value: usageDataEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            usageDataEnabled = value;
                          });
                        }
                    ),
                    SwitchListTileItems(
                        title: "Profil public",
                        subtitle: "Rendre votre profil visible",
                        value: publicProfileEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            publicProfileEnabled = value;
                          });
                        }
                    ),SwitchListTileItems(
                        title: "Historique des trajets",
                        subtitle: "Enregistrer vos trajets",
                        value: historyEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            historyEnabled = value;
                          });
                        }
                    ),ListTileItems(
                      title: 'Politique de confidentialité',
                      subtitle: "Consulter nos conditions d'utilisation",
                    ),ListTileItems(
                      title: 'Télécharger mes données',
                      subtitle: "Obtenir une copie de vos informations",
                    ),
                    ListTileItems(
                      title: 'Supprimer mon compte',
                      subtitle: "Action irréversible",
                      color: Colors.red[100],
                      onTap: () {
                        _showDeleteDialog(id);
                      },
                      titleColor: Colors.red,
                      subtitleColor: Colors.red,
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
          return SplashScreen();
        },
      )
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Supprimer le compte"),
          content: Text("Etes-vous sûr de vouloir supprimer votre compte ?"),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Annuler")
            ),
            TextButton(
              onPressed: () async {
                await _deleteUser(id);
              },
              child: Text("Supprimer mon compte")
            ),
          ],
        );
      }
    );
  }

  Future<void> _deleteUser(int id) async {
    context.read<AuthBloc>().add(AuthDeleteUserRequested(id: id));
    AppSnackBar.showSuccess(context, "Compte supprimé avec succès");
  }
}
