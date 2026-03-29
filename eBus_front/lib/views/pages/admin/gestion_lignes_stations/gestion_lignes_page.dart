import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/views/UI/app_bar_gestion.dart';
import 'package:smart_bus/views/pages/lines/lines_list.dart';
import 'package:smart_bus/views/pages/lines/search_bar.dart';

import '../../../UI/splash_screen.dart';
import '../../lines/lines_view.dart';
import 'line_form_page.dart';

class GestionLignesPage extends StatefulWidget {
  const GestionLignesPage({super.key});

  @override
  State<GestionLignesPage> createState() => _GestionLignesPageState();
}

class _GestionLignesPageState extends State<GestionLignesPage> {
  @override
  void initState(){
    super.initState();
    context.read<LigneBloc>().add(LoadLignes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGestion(
        title: "Gestion des lignes",
        bgColor: AppColors.darkBlue,
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LineFormPage())
          );
        }
      ),
      body: BlocConsumer<LigneBloc,LigneState>(
        listener: (context, state) {
          if(state is LigneDeleted){
            AppSnackBar.showSuccess(context, "Ligne supprimée avec succès");
          }
          if(state is LigneError){
            AppSnackBar.showError(context,state.error);
          }
        },
        builder: (context, state) {
          if (state is LigneLoading || state is LigneInitial) {
            return SplashScreen();
          }
          return LignesView(
            builder: (lignes) {
              return Column(
                children: [
                  LineSearchBar(
                    onChanged: (value){
                      context.read<LigneBloc>().add(SearchLignes(value));
                    },
                  ),
                  Expanded(
                    child: LinesList(lignes: lignes),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
