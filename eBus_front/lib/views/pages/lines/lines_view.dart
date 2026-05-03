import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';
import '../../../../bloc/ligne/ligne_bloc.dart';
import '../../../../bloc/ligne/ligne_state.dart';
import '../../../../models/ligne.dart';

class LignesView extends StatelessWidget {

  final Widget Function(List<Ligne> lignes) builder;

  const LignesView({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LigneBloc, LigneState>(
      builder: (context, state) {
        if (state is LigneLoading) {
          return const SplashScreen();
        }

        List<Ligne> lignes;
        if (state is LigneLoaded) {
          lignes = state.lignes;
        } else {
          lignes = context.read<LigneBloc>().lignes;
        }

        final sorted = List<Ligne>.from(lignes)
          ..sort((a, b) {
            final numA = int.tryParse(a.numero) ?? 0;
            final numB = int.tryParse(b.numero) ?? 0;
            return numA.compareTo(numB);
          });
        return builder(sorted);
      },
    );
  }
}
