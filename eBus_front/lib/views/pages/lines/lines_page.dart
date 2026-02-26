import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/views/loading/splash_screen.dart';
import '../../../bloc/ligne/ligne_event.dart';
import '../../../constants/app_colors.dart';
import 'line_details_page.dart';

class LinesPage extends StatelessWidget {
  const LinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreenBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Lignes de bus",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<LigneBloc,LigneState>(
        builder: (context, state) {
          if(state is LigneLoading){
            return SplashScreen();
          }
          if(state is LigneLoaded){
            final lignes = state.lignes;

            return Column(
              children: [
                _buildSearchBar(context),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: lignes.length,
                    itemBuilder: (context, index) {
                      final ligne = lignes[index];

                      return _buildLineCard(
                        context,
                        ligne.numero,
                        ligne.startPoint,
                        ligne.endPoint,
                        AppColors.darkBlue,
                      );
                    },
                  ),
                ),
              ],
            );
          }if(state is LigneError){
            return Center(child: Text(state.error));
          }
          return const SizedBox();
        }
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: AppColors.darkBlue,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          context.read<LigneBloc>().add(SearchLignes(value));
        },
        decoration: InputDecoration(
          hintText: "Rechercher une ligne...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildLineCard(BuildContext context, String number, String start, String end, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // FORCE la détection du clic sur toute la carte
        onTap: () {
          debugPrint("Clic sur la ligne $number");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LineDetailsPage(
                lineNumber: number,
                themeColor: color,
                stops: [],
              ),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                ),
                child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ligne $number", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
                      const SizedBox(height: 5),
                      Text("$start → $end", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
  }
