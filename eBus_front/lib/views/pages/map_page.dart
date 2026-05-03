import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_bus/constants/app_colors.dart';


class MapPage extends StatelessWidget {
  const MapPage({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        title: const Text(
            'Suivi en temps réel',
            style: TextStyle(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600
            ),
        ),
        actions: [
          IconButton(
              onPressed: (){},
              icon: const Icon(Icons.send, color: Colors.green),
             padding: EdgeInsets.zero,
          ),
        ],
      ),
      body: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(32.2994, -9.2372),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // Obligatoire pour éviter l'erreur 403 (Politique d'utilisation d'OpenStreetMap)
              userAgentPackageName: 'com.ebus.smart_bus',
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                ),
              ],
            ),
          ]
      ),
    );
  }
}
