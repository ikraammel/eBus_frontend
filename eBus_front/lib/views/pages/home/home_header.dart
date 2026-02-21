import 'package:flutter/material.dart';

import '../../../models/User.dart';


class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key,this.currentUser});

  final User? currentUser;

  @override
  Widget build(BuildContext context) {
     return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1A367C),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bienvenue,", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(
                      currentUser != null ?
                      '${currentUser?.nom} ${currentUser?.prenom}'
                          : "Invité",
                      style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
              Container(
                height: 50, width: 50,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.directions_bus, color: Color(0xFF8DC63F)),
              )
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
            child: const Row(
              children: [
                Icon(Icons.bus_alert, color: Colors.white),
                SizedBox(width: 10),
                Text("Prochain bus dans ", style: TextStyle(color: Colors.white)),
                Text("5 min", style: TextStyle(color: Color(0xFF8DC63F), fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
