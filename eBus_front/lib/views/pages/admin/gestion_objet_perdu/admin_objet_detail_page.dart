import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_state.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/views/UI/statut_badge.dart';
import 'package:smart_bus/constants/constants.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';

class AdminObjetDetailPage extends StatefulWidget {
  final int objetId;
  final ObjetPerdu? objet;

  const AdminObjetDetailPage({super.key, required this.objetId, this.objet});

  @override
  State<AdminObjetDetailPage> createState() => _AdminObjetDetailPageState();
}

class _AdminObjetDetailPageState extends State<AdminObjetDetailPage> {
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
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

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "${AppConstants.baseUrl}/$cleanPath";
  }

  Future<void> _changeStatut(ObjetPerdu objet, StatutObjet nouveauStatut) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer le changement'),
        content: Text('Voulez-vous passer le statut à : ${nouveauStatut.name} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && objet.id != null) {
      setState(() => _isUpdating = true);
      context.read<ObjetPerduBloc>().add(
        UpdateObjetPerduStatus(id: objet.id!, newStatus: nouveauStatut.name),
      );
      
      // Petit délai pour laisser le temps au backend de traiter
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.read<ObjetPerduBloc>().add(const LoadObjetsPerdus());
        AppSnackBar.showSuccess(context, "Statut mis à jour");
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ObjetPerduBloc, ObjetPerduState>(
      builder: (context, state) {
        final currentObjet = widget.objet ?? _findObjet(state);

        if (state is ObjetPerduLoading && currentObjet == null) {
          return const SplashScreen();
        }

        if (currentObjet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Détail Admin")),
            body: const Center(child: Text("Objet introuvable")),
          );
        }

        return _buildPage(context, currentObjet);
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
            expandedHeight: 300,
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
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 50),
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
                      style: const TextStyle(fontSize: 16, color: Color(0xFF607D8B), height: 1.6),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    ),
                    
                    _adminInfoSection(currentObjet),
                    
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        _infoBox(Icons.directions_bus_rounded, "Ligne", currentObjet.ligneNom ?? 'N/A', themeColor),
                        const SizedBox(width: 15),
                        _infoBox(Icons.calendar_today_rounded, "Déclaré le", _formatDate(currentObjet.dateDeclaration), themeColor),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    _buildAdminActions(currentObjet),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminInfoSection(ObjetPerdu objet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("INFORMATIONS SIGNALEMENT", 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 15),
        _detailRow(Icons.person_outline, "Signalé par", objet.userNom ?? "Inconnu"),
        if (objet.contact != null)
          _detailRow(Icons.contact_mail_outlined, "Contact", objet.contact!, color: Colors.blue),
        if (objet.busImmatriculation != null)
          _detailRow(
            Icons.directions_bus,
            "Bus",
            objet.busImmatriculation!,
            color: Colors.deepOrange,
          ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.darkBlue),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  Widget _buildAdminActions(ObjetPerdu objet) {
    if (_isUpdating) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        if (objet.statut == StatutObjet.EN_ATTENTE)
          _actionButton("VALIDER & RENDRE DISPONIBLE", Colors.green, Icons.check_circle_outline, 
            () => _changeStatut(objet, StatutObjet.DISPONIBLE)),
        
        if (objet.statut == StatutObjet.DISPONIBLE || objet.statut == StatutObjet.EN_ATTENTE_RECUPERATION)
          _actionButton("MARQUER COMME RÉCUPÉRÉ", AppColors.darkBlue, Icons.done_all, 
            () => _changeStatut(objet, StatutObjet.RECUPERE)),
      ],
    );
  }

  Widget _actionButton(String label, Color color, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, ObjetPerdu objet, Color themeColor) {
    if (objet.imageUrl != null && objet.imageUrl!.isNotEmpty) {
      final url = getImageUrl(objet.imageUrl);
      return InkWell(
        onTap: () => _showFullScreenImage(context, url),
        child: Image.network(url, fit: BoxFit.cover),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor, themeColor.withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Icon(
          objet.type == TypeAnnonce.PERTE ? Icons.search_rounded : Icons.inventory_2_outlined,
          size: 100,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _infoBox(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
          ],
        ),
      ),
    );
  }

  Widget _typeLabel(bool isPerte, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPerte ? "OBJET PERDU" : "OBJET TROUVÉ",
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11),
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
            InteractiveViewer(child: Center(child: Image.network(url, fit: BoxFit.contain))),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}
