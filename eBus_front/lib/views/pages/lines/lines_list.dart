import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/ligne.dart';
import 'line_card.dart';

class LinesList extends StatelessWidget {

  final List<Ligne> lignes;

  const LinesList({
    super.key,
    required this.lignes,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: lignes.length,
      itemBuilder: (context, index) {

        return LineCard(
          ligne: lignes[index],
          color: AppColors.darkBlue,
        );

      },
    );
  }
}