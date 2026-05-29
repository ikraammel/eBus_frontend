import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../models/bus.dart';
import 'bus_card.dart';

class BusList extends StatelessWidget {
  final List<Bus> buses;
  final ValueChanged<Bus> onEdit;
  final ValueChanged<Bus> onDetails;

  const BusList({
    super.key,
    required this.buses,
    required this.onEdit,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: buses.length,
      itemBuilder: (context, index) {
        return BusCard(
          bus: buses[index],
          color: AppColors.darkBlue,
          onEdit: onEdit,
          onDetails: onDetails,
        );
      },
    );
  }
}
