import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/claims/claims_bloc.dart';
import '../../../bloc/claims/claims_state.dart';
import '../../../enums/claims_sort_type.dart';
import '../../../enums/reclamation_status.dart';
import '../../UI/splash_screen.dart';
import '../../../models/reclamation.dart';
import 'claim_card.dart';

class ClaimsList extends StatelessWidget {
  final ClaimsSortType? sortType;
  final ReclamationStatus? statusFilter;

  const ClaimsList({super.key, this.sortType, this.statusFilter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClaimsBloc, ClaimsState>(
      builder: (context, state) {
        if (state is ClaimsLoading) return const SplashScreen();
        if (state is ClaimsError) return Center(child: Text(state.error));
        if (state is ClaimsLoaded) {
          List<Reclamation> claims = state.claims;

          if (statusFilter != null) {
            claims = claims.where((c) => c.status == statusFilter).toList();
          }

          if (sortType == ClaimsSortType.latest) {
            claims.sort((a, b) => b.date!.compareTo(a.date!));
          }

          if (claims.isEmpty) {
            return const Center(child: Text("Aucune réclamation"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final Reclamation claim = claims[index];
              return ClaimCard(claim: claim);
            },
          );
        }
        return Container();
      },
    );
  }
}
extension ReclamationStatusExtension on ReclamationStatus {
  String get label {
    switch (this) {
      case ReclamationStatus.EN_ATTENTE:
        return "En attente";
      case ReclamationStatus.TRAITEE:
        return "Traitée";
      case ReclamationStatus.ANNULEE:
        return "Annulée";
    }
  }
}