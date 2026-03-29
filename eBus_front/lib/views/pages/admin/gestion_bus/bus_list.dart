import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../models/Bus.dart';
import 'bus_card.dart';

class BusList extends StatelessWidget {
  final List<Bus> buses;
  const BusList({super.key,required this.buses});

  @override
  Widget build(BuildContext context) {
     return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: buses.length,
      itemBuilder: (context, index) {

        return BusCard(
          bus: buses[index],
          color: AppColors.darkBlue,
        );

      },
    );
  }
}
