import 'package:flutter/material.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/views/UI/statut_badge.dart';
import 'package:smart_bus/enums/enums.dart';

class UserObjetDetailPage extends StatelessWidget {
  final ObjetPerdu? objet;
  final int? objetId;

  const UserObjetDetailPage({
    super.key,
    this.objet,
    this.objetId,
  });

  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF43A047);
  static const Color bgColor = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    // Sécurité : Si l'objet est nul (ex: passage par ID non géré ici), on affiche une erreur
    if (objet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: const Center(child: Text("Données de l'objet manquantes")),
      );
    }

    final currentObjet = objet!;
    final isPerte = currentObjet.type == TypeAnnonce.PERTE;
    final statut = currentObjet.statut;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPerte
                  ? [const Color(0xFFE67E22), const Color(0xFFD35400)]
                  : [primaryColor, accentColor],
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isPerte ? 'Détail — Objet perdu' : 'Détail — Objet trouvé',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header curve effect
            Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isPerte
                      ? [const Color(0xFFD35400), const Color(0xFFD35400).withOpacity(0.8)]
                      : [accentColor, primaryColor],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _typeBadge(isPerte),
                        StatutBadge(statut: statut),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentObjet.nom ?? 'Sans nom',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentObjet.description,
                      style: const TextStyle(color: Color(0xFF607D8B), fontSize: 15, height: 1.5),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(),
                    ),
                    _detailRow(Icons.directions_bus_outlined, 'Ligne', currentObjet.ligne ?? 'N/A'),
                    _detailRow(Icons.calendar_month_outlined, 'Date', _formatDate(currentObjet.dateDeclaration)),

                    if (currentObjet.contact != null)
                      _detailRow(
                        Icons.alternate_email_rounded,
                        'Contact',
                        currentObjet.contact!,
                        valueColor: Colors.blue,
                      ),

                    const SizedBox(height: 30),
                    _statutMessage(statut, isPerte),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

  Widget _typeBadge(bool isPerte) {
    final color = isPerte ? const Color(0xFFE67E22) : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
      child: Text(
        isPerte ? 'PERDU' : 'TROUVÉ',
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10),
      ),
    );
  }

  Widget _statutMessage(StatutObjet statut, bool isPerte) {
    Color color;
    IconData icon;
    String title;
    String message;

    if (!isPerte && statut == StatutObjet.DISPONIBLE) {
      color = primaryColor;
      icon = Icons.check_circle_outline;
      title = "Objet disponible";
      message = "Veuillez vous présenter à l'agence commerciale muni d'une pièce d'identité.";
    } else if (isPerte && statut == StatutObjet.EN_ATTENTE) {
      color = const Color(0xFFE67E22);
      icon = Icons.hourglass_top;
      title = "Signalement enregistré";
      message = "Nous n'avons pas encore trouvé d'objet correspondant. Nous vous contacterons dès que possible.";
    } else if (statut == StatutObjet.RECUPERE) {
      color = Colors.blueGrey;
      icon = Icons.verified_user;
      title = "Dossier clôturé";
      message = "Cet objet a été restitué à son propriétaire.";
    } else {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: color.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valueColor ?? Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}
