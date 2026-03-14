import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/views/pages/lines/search_bar.dart';
import '../../../bloc/ligne/ligne_event.dart';
import 'lines_view.dart';
import '../../../constants/app_colors.dart';
import 'lines_list.dart';

class LinesPage extends StatelessWidget {
  const LinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Lignes de bus",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: LignesView(
        builder: (lignes) {
          return Column(
            children: [
              LineSearchBar(
                onChanged: (value) {
                  context.read<LigneBloc>().add(SearchLignes(value));
                },
              ),
              Expanded(
                child: LinesList(lignes: lignes),
              ),
            ],
          );
        },
      ),
    );
  }

  }
