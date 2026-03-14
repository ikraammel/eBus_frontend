import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';

import '../../../../UI/list_tile_items.dart';
import '../../../../UI/switch_list_tile_items.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool notifyBusArrival = false;
  bool notifyDelays = false;
  bool notifyTickets = false;
  bool notifyClaims = false;
  bool notifyLostObjects = false;
  bool notifyOffers = false;
  bool notifyNews = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.darkBlue,
        ),
      body: SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 15),
      child: Column(
      children: [
        ListTileItems(
          title: 'Personnalisez vos notifications',
          subtitle: "Choisissez les alertes que vous souhaitez recevoir",
          color: Colors.blue[50],
          prefixIcon: Icons.notifications_none,
          prefixIconColor: AppColors.darkBlue,
        ),
        SwitchListTileItems(
          title: "Arrivée du bus",
          subtitle: "Recevoir une notification avant l'arrivée",
          value: notifyBusArrival,
          onChanged: (bool value) {
          setState(() {
            notifyBusArrival = value;
          });
          }
        ),
        SwitchListTileItems(
          title: "Retards et perturbations",
          subtitle: "Être alerté en cas de retard",
          value: notifyDelays,
          onChanged: (bool value) {
          setState(() {
            notifyDelays = value;
          });
          }
        ),
        SwitchListTileItems(
          title: "Tickets et paiements",
          subtitle: "Confirmation d'achat de tickets",
          value: notifyTickets,
          onChanged: (bool value) {
          setState(() {
            notifyTickets = value;
          });
          }
        ),SwitchListTileItems(
          title: "Réclamations",
          subtitle: "Mise à jour de vos réclamations",
          value: notifyClaims,
          onChanged: (bool value) {
          setState(() {
            notifyClaims = value;
          });
          }
        ),SwitchListTileItems(
          title: "Objets trouvés",
          subtitle: "Nouveaux objets correspondant à votre recherche",
          value: notifyLostObjects,
          onChanged: (bool value) {
          setState(() {
            notifyLostObjects = value;
          });
          }
        ),SwitchListTileItems(
          title: "Offres et promotions",
          subtitle: "Recevoir les offres spéciales",
          value: notifyOffers,
          onChanged: (bool value) {
          setState(() {
            notifyOffers = value;
          });
          }
        ),SwitchListTileItems(
          title: "Actualités eBus",
          subtitle: "Nouveautés et mises à jour",
          value: notifyNews,
          onChanged: (bool value) {
          setState(() {
            notifyNews = value;
          });
          }
        ),
        SizedBox(height: 30),
      ],
      ),
      ),
    )
    );
  }
}
