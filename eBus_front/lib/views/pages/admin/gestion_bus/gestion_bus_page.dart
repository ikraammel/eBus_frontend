import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_bloc.dart';
import 'package:smart_bus/bloc/bus/bus_state.dart';
import 'package:smart_bus/views/UI/app_bar_gestion.dart';
import 'package:smart_bus/views/pages/admin/gestion_bus/bus_form_page.dart';
import 'package:smart_bus/views/pages/admin/gestion_bus/bus_list.dart';

import '../../../../bloc/bus/bus_event.dart';
import '../../../../constants/app_colors.dart';
import '../../../../utils/app_snack_bar.dart';
import '../../../UI/splash_screen.dart';

class GestionBusPage extends StatelessWidget {
  const GestionBusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGestion(
          title: "Gestion des bus",
          bgColor: AppColors.green,
          onPressed: () async{
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BusFormPage())
            );
            context.read<BusBloc>().add(LoadBuses());
          }
      ),
      body: BlocConsumer<BusBloc, BusState>(
        listener: (context, state) {
          if (state is BusDeleted) {
            AppSnackBar.showSuccess(context, "Bus supprimé avec succès");
          }
          if (state is BusError) {
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          final buses = context.read<BusBloc>().buses;
          if (state is BusLoading || state is BusInitial) {
            return SplashScreen();
          }
          if (buses.isNotEmpty) {
            return BusList(buses: buses);
          }

          return Center(child: Text("Aucun bus disponible"));
        },
      ),
    );
  }
}