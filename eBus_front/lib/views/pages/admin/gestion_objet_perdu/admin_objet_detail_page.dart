import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_state.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/views/UI/statut_badge.dart';

class AdminObjetDetailPage extends StatefulWidget {
  final int objetId;
  const AdminObjetDetailPage({super.key, required this.objetId});

  @override
  State<AdminObjetDetailPage> createState() => _AdminObjetDetailPageState();
}

class _AdminObjetDetailPageState extends State<AdminObjetDetailPage> {

  @override
  void initState() {
    super.initState();
    // On s'assure d'avoir les données les plus récentes
    context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
  }

  ObjetPerdu? _findObjet(ObjetPerduState state) {
    if (state is ObjetPerduLoadSuccess) {
      try {
        return state.objets.firstWhere((o) => o.id == widget.objetId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _changeStatut(ObjetPerdu objet, StatutObjet nouveauStatut) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Passer le statut à : ${nouveauStatut.name} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm == true && objet.id != null) {
      context.read<ObjetPerduBloc>().add(
        UpdateObjetPerduStatus(
          id: objet.id!,
          newStatus: nouveauStatut.name,
        ),
      );

      context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Statut mis à jour avec succès"))
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail Objet (Admin)"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ObjetPerduBloc, ObjetPerduState>(
        builder: (context, state) {
          final objet = _findObjet(state);

          if (state is ObjetPerduLoading && objet == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (objet == null) {
            return const Center(child: Text("Objet introuvable ou déjà supprimé."));
          }

          final isPerte = objet.type == TypeAnnonce.PERTE;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPerte ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPerte ? "🔴 PERTE" : "🔵 TROUVÉ",
                        style: TextStyle(
                          color: isPerte ? Colors.orange : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatutBadge(statut: objet.statut),
                  ],
                ),

                const SizedBox(height: 25),

                // Titre et Description
                Text(
                  objet.nom ?? 'Sans nom',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  objet.description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(),
                ),

                // Informations détaillées
                _row(Icons.directions_bus, "Ligne", objet.ligne ?? "N/A"),
                _row(Icons.calendar_today, "Date",
                    "${objet.dateDeclaration.day}/${objet.dateDeclaration.month}/${objet.dateDeclaration.year}"),


                _row(Icons.person, "Signalé par", objet.userNom ?? "Utilisateur inconnu"),

                if (objet.contact != null)
                  _row(Icons.contact_phone, "Contact", objet.contact!, color: Colors.blue),

                const SizedBox(height: 40),


                if (objet.statut == StatutObjet.EN_ATTENTE)
                  _actionButton(
                    "VALIDER & RENDRE DISPONIBLE",
                    Colors.green,
                    () => _changeStatut(objet, StatutObjet.DISPONIBLE),
                  ),


                if (objet.statut == StatutObjet.DISPONIBLE ||
                    objet.statut == StatutObjet.EN_ATTENTE_RECUPERATION)
                  _actionButton(
                    "MARQUER COMME RÉCUPÉRÉ",
                    const Color(0xFF2E7D32),
                    () => _changeStatut(objet, StatutObjet.RECUPERE),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: TextStyle(color: color, fontWeight: color != null ? FontWeight.bold : FontWeight.normal)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPressed,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
