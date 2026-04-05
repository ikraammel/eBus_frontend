import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/views/pages/claims/claims_list.dart';
import 'package:smart_bus/views/pages/claims/new_claim/new_claim_page.dart';

import '../../../constants/app_colors.dart';
import '../../../enums/claims_sort_type.dart';

class ClaimsPage extends StatefulWidget {
  const ClaimsPage({super.key});

  @override
  State<ClaimsPage> createState() => _ClaimsPageState();
}

class _ClaimsPageState extends State<ClaimsPage> {
  ClaimsSortType sortType = ClaimsSortType.defaultOrder;

  void changeSort(ClaimsSortType type) {
    setState(() {
      sortType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: BlocBuilder<AuthBloc,AuthState>(
        builder: (context, state) {
          if(state is AuthAuthenticated){
            return FloatingActionButton(
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewClaimPage()),
                  );
                },
                backgroundColor: AppColors.green
            );
          }
          else{
            return const SizedBox.shrink();
          }
        },
      ),
      appBar: AppBar(
        title: const Text(
            "Réclamations",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: AppColors.darkBlue,
        actions: [
          PopupMenuButton<ClaimsSortType>(
            icon: Icon(Icons.sort,color: Colors.white,),
            onSelected: changeSort,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ClaimsSortType.latest,
                child: Text("Plus récentes"),
              ),
              const PopupMenuItem(
                value: ClaimsSortType.defaultOrder,
                child: Text("Par défaut"),
              ),
            ],
          )
        ],
      ),
      body: ClaimsList(sortType: sortType),
    );
  }
}
