import 'package:flutter/material.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/views/UI/statut_badge.dart';
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/constants/constants.dart';
import 'package:smart_bus/services/objet_service.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';
import 'package:smart_bus/constants/app_colors.dart';

class UserObjetDetailPage extends StatelessWidget {
  final ObjetPerdu? objet;
  final int? objetId;

  const UserObjetDetailPage({
    super.key,
    this.objet,
    this.objetId,
  });

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "${AppConstants.baseUrl}/$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    if (objet != null) return _buildPage(context, objet!);

    return FutureBuilder<ObjetPerdu>(
      future: ObjetService().getById(objetId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SplashScreen();
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erreur"), backgroundColor: AppColors.darkBlue),
            body: const Center(child: Text("Impossible de charger les détails")),
          );
        }
        return _buildPage(context, snapshot.data!);
      },
    );
  }

  Widget _buildPage(BuildContext context, ObjetPerdu currentObjet) {
    final bool isPerte = currentObjet.type == TypeAnnonce.PERTE;
    final Color themeColor = isPerte ? AppColors.accentColor : AppColors.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: themeColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderImage(context, currentObjet, themeColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -35),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(25, 35, 25, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _typeLabel(isPerte, themeColor),
                        StatutBadge(statut: currentObjet.statut),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      currentObjet.nom ?? 'Objet sans nom',
                      style: const TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.w900, 
                        color: AppColors.darkBlue,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentObjet.description,
                      style: const TextStyle(
                        fontSize: 16, 
                        color: Color(0xFF607D8B), 
                        height: 1.6
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    ),
                    
                    Row(
                      children: [
                        _infoBox(Icons.directions_bus_rounded, "Ligne", currentObjet.ligneNom ?? 'N/A', themeColor),
                        const SizedBox(width: 15),
                        _infoBox(Icons.calendar_today_rounded, "Déclaré le", _formatDate(currentObjet.dateDeclaration), themeColor),
                      ],
                    ),

                    if (currentObjet.contact != null ||
                        (currentObjet.busImmatriculation != null && currentObjet.busImmatriculation!.isNotEmpty)) ...[
                      const SizedBox(height: 15),

                      if (currentObjet.contact != null)
                        _infoBox(
                          Icons.alternate_email_rounded,
                          "Contact",
                          currentObjet.contact!,
                          Colors.blue,
                          isFullWidth: true,
                        ),

                      if (currentObjet.busImmatriculation != null &&
                          currentObjet.busImmatriculation!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _infoBox(
                          Icons.confirmation_number_outlined,
                          "Immatriculation",
                          currentObjet.busImmatriculation!,
                          Colors.deepOrange,
                          isFullWidth: true,
                        ),
                      ],
                    ],
                    const SizedBox(height: 40),
                    _buildStatusInstruction(currentObjet.statut, isPerte, themeColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, ObjetPerdu objet, Color themeColor) {
    if (objet.imageUrl != null && objet.imageUrl!.isNotEmpty) {
      final url = getImageUrl(objet.imageUrl);
      return InkWell(
        onTap: () => _showFullScreenImage(context, url),
        child: Image.network(
          url, 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(objet, themeColor),
        ),
      );
    }
    return _buildPlaceholder(objet, themeColor);
  }

  Widget _buildPlaceholder(ObjetPerdu objet, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor, themeColor.withValues(alpha: 0.7)],
        ),
      ),
      child: Center(
        child: Icon(
          objet.type == TypeAnnonce.PERTE ? Icons.search_rounded : Icons.inventory_2_outlined,
          size: 100,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _infoBox(IconData icon, String label, String value, Color color, {bool isFullWidth = false}) {
    Widget content = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, 
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
    return isFullWidth ? SizedBox(width: double.infinity, child: content) : Expanded(child: content);
  }

  Widget _buildStatusInstruction(StatutObjet statut, bool isPerte, Color color) {
    String title = "";
    String msg = "";
    IconData icon = Icons.info_outline;

    if (statut == StatutObjet.DISPONIBLE) {
      title = "Objet disponible";
      msg = "Rendez-vous à l'agence commerciale Vectalia munis d'une pièce d'identité pour le récupérer.";
      icon = Icons.check_circle_rounded;
    } else if (statut == StatutObjet.EN_ATTENTE) {
      title = "Dossier enregistré";
      msg = "Nous n'avons pas encore trouvé d'objet correspondant. Nous reviendrons vers vous dès que possible.";
      icon = Icons.hourglass_empty_rounded;
    } else if (statut == StatutObjet.RECUPERE) {
      title = "Dossier clôturé";
      msg = "Cet objet a été restitué avec succès à son propriétaire.";
      icon = Icons.verified_rounded;
    } else {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 4),
                Text(msg, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeLabel(bool isPerte, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        isPerte ? "OBJET PERDU" : "OBJET TROUVÉ",
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(child: Image.network(url, fit: BoxFit.contain)),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}
