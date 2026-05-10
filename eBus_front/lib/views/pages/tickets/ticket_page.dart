import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/abonnement.dart';
import 'package:smart_bus/models/ticket.dart';
import 'package:smart_bus/models/type_abonnement.dart';
import 'package:smart_bus/services/ticket_service.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketPage extends StatefulWidget {
  /// Si true, on ouvre directement l'onglet Abonnements (depuis notif verte).
  final bool openAbonnementsTab;
  const TicketPage({super.key, this.openAbonnementsTab = false});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> with TickerProviderStateMixin {
  final TicketService _service = TicketService();

  late Future<List<dynamic>> _offersFuture;
  Future<Abonnement?>? _currentAboFuture;
  Future<List<Abonnement>>? _historiqueFuture;

  bool _isLoading = false;
  bool _showHistorique = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // openAbonnementsTab=true → onglet 0 (Abonnements), sinon 1 (Tickets)
    final initialIndex = widget.openAbonnementsTab ? 0 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _offersFuture = _service.getAllOffers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCancelledPayment();
      _loadUserAbonnement();
    });
  }

  void _loadUserAbonnement() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final userId = state.user.id;
      setState(() {
        _currentAboFuture = _service.getCurrentAbonnement(userId);
        _historiqueFuture = _service.getHistoriqueAbonnements(userId);
      });
    }
  }

  void _checkCancelledPayment() {
    final uri = Uri.base;
    if (uri.queryParameters['payment'] == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Paiement annulé. Vous pouvez réessayer."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  String _formatTitle(String title) {
    if (title.isEmpty) return title;
    return title
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String _countdownLabel(Abonnement abo) {
    final jours = abo.joursRestants;
    if (jours == 0) return "Expiré";
    if (jours < 30) return "$jours jour${jours > 1 ? 's' : ''} restant${jours > 1 ? 's' : ''}";
    final mois = (jours / 30).floor();
    final reste = jours % 30;
    if (reste == 0) return "$mois mois restant${mois > 1 ? 's' : ''}";
    return "$mois mois et $reste jour${reste > 1 ? 's' : ''} restant${reste > 1 ? 's' : ''}";
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkBlue.withOpacity(0.1),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.darkBlue, size: 32),
              ),
              const SizedBox(height: 16),
              const Text("Connexion requise",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Connectez-vous pour souscrire à un abonnement.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/loginPage');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Se connecter",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubscribe(TypeAbonnement item) async {
    final userId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.id;
    final confirmed = await _showConfirmDialog(item);
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final stripeUrl = await _service.subscribe(userId, item.id!);
      if (stripeUrl != null && stripeUrl.startsWith('http')) {
        final Uri url = Uri.parse(stripeUrl);
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception("URL invalide");
      }
    } catch (e) {
      if (mounted) {
        // Afficher le message métier (ex: "Vous avez déjà un abonnement actif")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConfirmDialog(TypeAbonnement item) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.darkBlue, Color(0xFF2A50B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.credit_card_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(_formatTitle(item.nom),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                "${item.prix.toStringAsFixed(2)} MAD / ${item.dureeMois} mois",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Vous allez être redirigé vers Stripe pour finaliser le paiement.",
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.lock_outline, size: 16),
                      label: const Text("Payer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final bool isGuest = authState is! AuthAuthenticated;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB), // identique à HomePage
          body: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, _) => [_buildSliverAppBar()],
                body: FutureBuilder<List<dynamic>>(
                  future: _offersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreen();
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text("Erreur de chargement",
                                style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(
                                  () { _offersFuture = _service.getAllOffers(); }),
                              child: const Text("Réessayer"),
                            ),
                          ],
                        ),
                      );
                    }
                    final list = snapshot.data ?? [];
                    final abonnements =
                        list.whereType<TypeAbonnement>().toList();
                    final tickets = list.whereType<Ticket>().toList();
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAbonnementsTab(abonnements, isGuest),
                        _buildTicketsTab(tickets),
                      ],
                    );
                  },
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Redirection vers Stripe…"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }



  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.darkBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            // Dégradé cohérent avec le header de la HomePage
            gradient: LinearGradient(
              colors: [Color(0xFF1A367C), Color(0xFF2A50B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.withOpacity(0.1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tickets & Abonnements",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Choisissez l'offre qui vous convient",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.green,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(icon: Icon(Icons.card_membership_rounded), text: "Abonnements"),
          Tab(
              icon: Icon(Icons.confirmation_number_outlined),
              text: "Tickets"),
        ],
      ),
    );
  }



  Widget _buildAbonnementsTab(List<TypeAbonnement> items, bool isGuest) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Bannière invité
        if (isGuest) ...[
          _buildGuestBanner(),
          const SizedBox(height: 4),
        ],

        // ── Abonnement actif courant ────────────────────────────────────────
        if (!isGuest && _currentAboFuture != null)
          FutureBuilder<Abonnement?>(
            future: _currentAboFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(),
                );
              }
              final abo = snap.data;
              if (abo != null) return _buildCurrentAbonnementBanner(abo);
              return const SizedBox.shrink();
            },
          ),

        // ── Offres disponibles ─────────────────────────────────────────────
        if (items.isEmpty)
          _buildEmpty("Aucun abonnement disponible")
        else
          ...items.map((item) => _buildAbonnementCard(item, isGuest)),

        // ── Historique ─────────────────────────────────────────────────────
        if (!isGuest && _historiqueFuture != null) ...[
          const SizedBox(height: 8),
          _buildHistoriqueSection(),
        ],
      ],
    );
  }

  /// Bannière verte/orange/rouge indiquant l'état de l'abonnement courant
  Widget _buildCurrentAbonnementBanner(Abonnement abo) {
    Color color;
    IconData icon;
    String title;
    String subtitle;

    if (abo.isActif) {
      final jours = abo.joursRestants;
      color = jours < 10 ? Colors.orange : AppColors.green;
      icon = jours < 10
          ? Icons.warning_amber_rounded
          : Icons.verified_rounded;
      title = "Abonnement actif — ${_formatTitle(abo.typeNom)}";
      subtitle = _countdownLabel(abo);
    } else if (abo.isEnAttente) {
      color = Colors.blue;
      icon = Icons.hourglass_top_rounded;
      title = "Paiement en attente de confirmation";
      subtitle = "Vous recevrez une confirmation dès validation de Stripe.";
    } else if (abo.isRefuse) {
      color = Colors.red;
      icon = Icons.cancel_rounded;
      title = "Abonnement refusé";
      subtitle = "Votre paiement n'a pas été accepté. Réessayez.";
    } else {
      // EXPIRE
      color = Colors.grey;
      icon = Icons.history_rounded;
      title = "Abonnement expiré — ${_formatTitle(abo.typeNom)}";
      subtitle = "Renouvelez votre abonnement ci-dessous.";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color.darken(0.1),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style:
                        TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue.withOpacity(0.08),
            AppColors.green.withOpacity(0.08)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.darkBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Connectez-vous pour souscrire à un abonnement.",
              style: TextStyle(color: AppColors.darkBlue, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/loginPage'),
            child: const Text("Connexion",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAbonnementCard(TypeAbonnement item, bool isGuest) {
    final isScolaire = item.nom.toUpperCase().contains('SCOLAIRE');
    final accentColor =
        isScolaire ? const Color(0xFF9C27B0) : AppColors.darkBlue;
    final label = _formatTitle(item.nom);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header coloré
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Icon(
                    isScolaire
                        ? Icons.school_rounded
                        : Icons.card_membership_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(
                        "${item.dureeMois} mois de validité",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${item.prix.toStringAsFixed(0)} MAD",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Corps de la carte
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildFeature(
                        Icons.check_circle_outline, "Accès illimité"),
                    const SizedBox(width: 8),
                    _buildFeature(
                        Icons.check_circle_outline, "Toutes lignes"),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => isGuest
                        ? _showLoginRequiredDialog()
                        : _handleSubscribe(item),
                    icon: Icon(
                        isGuest
                            ? Icons.lock_outline
                            : Icons.credit_card_rounded,
                        size: 18),
                    label: Text(
                        isGuest ? "Se connecter" : "S'abonner maintenant"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.green),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }



  Widget _buildHistoriqueSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showHistorique = !_showHistorique),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded,
                    color: AppColors.darkBlue, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Historique des abonnements",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue),
                  ),
                ),
                Icon(
                  _showHistorique
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (_showHistorique)
          FutureBuilder<List<Abonnement>>(
            future: _historiqueFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("Aucun historique.",
                      style: TextStyle(color: Colors.grey[500])),
                );
              }
              return Column(
                children: list
                    .map((a) => _buildHistoriqueItem(a))
                    .toList(),
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHistoriqueItem(Abonnement abo) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (abo.status) {
      case 'ACTIF':
        statusColor = abo.joursRestants > 0 ? AppColors.green : Colors.grey;
        statusLabel = abo.joursRestants > 0 ? 'Actif' : 'Expiré';
        statusIcon = abo.joursRestants > 0
            ? Icons.check_circle_rounded
            : Icons.history_rounded;
        break;
      case 'EN_ATTENTE':
        statusColor = Colors.blue;
        statusLabel = 'En attente';
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'EXPIRE':
        statusColor = Colors.grey;
        statusLabel = 'Expiré';
        statusIcon = Icons.history_rounded;
        break;
      case 'REFUSE':
        statusColor = Colors.red;
        statusLabel = 'Refusé';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = abo.status;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatTitle(abo.typeNom),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  "${abo.dateDebut} → ${abo.dateFin}",
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${abo.prix.toStringAsFixed(0)} MAD",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildTicketsTab(List<Ticket> tickets) {
    if (tickets.isEmpty) return _buildEmpty("Aucun ticket disponible");
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Info banner cohérent avec les couleurs de la home
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Les tickets sont disponibles à la montée auprès du chauffeur.",
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        ...tickets.map((t) => _buildTicketCard(t)),
      ],
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green.withOpacity(0.1),
            ),
            child: const Icon(Icons.confirmation_number_outlined,
                color: AppColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatTitle(ticket.typeTicket),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text("Ticket unitaire",
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${ticket.prix} MAD",
              style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}


extension _ColorExt on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
