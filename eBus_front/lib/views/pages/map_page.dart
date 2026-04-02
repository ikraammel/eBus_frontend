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
        title: Text(
            'Suivi en temps réel',
            style: TextStyle(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600
            ),
        ),
        actions: [
          IconButton(
              onPressed: (){

              },
              icon: Icon(Icons.send,color: Colors.green,),
             padding: EdgeInsets.zero,
          )
          ,
        ],
      ),
      body: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(32.2994, -9.2372),
            initialZoom: 9.2,
          ),
          children: [
            TileLayer( // Bring your own tiles
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
               // Add your app identifier
              // And many more recommended properties!
            ),
            RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                ),
                // Also add images...
              ],
            ),
          ]
      ),
    );
  }

}
