import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/services/ticket_service.dart';

class PaymentSuccessPage extends StatefulWidget {
  final int? abonnementId;
  final String? sessionId;

  const PaymentSuccessPage({
    super.key,
    this.abonnementId,
    this.sessionId,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  final TicketService _service = TicketService();

  _PollState _state = _PollState.polling;
  int _attempts = 0;
  static const int _maxAttempts = 15; // 30 secondes max
  Timer? _timer;

  late AnimationController _pulseController;
  late AnimationController _checkController;
  late Animation<double> _pulseAnim;
  late Animation<double> _checkAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _checkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _checkController, curve: Curves.elasticOut));

    if (widget.abonnementId != null) {
      _startConfirmation();
    } else {
      _onSuccess();
    }
  }

  /// Stratégie en 2 étapes :
  /// 1. Appel immédiat à /confirm avec le sessionId → activation directe si Stripe confirme
  /// 2. Si pas encore confirmé, on poll /status toutes les 2 secondes (backup)
  void _startConfirmation() async {
    // ── Étape 1 : confirmation directe via sessionId ───────────────────────
    if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
      print("[PaymentSuccess] Tentative de confirmation directe avec sessionId...");
      try {
        final status = await _service.confirmPayment(
          widget.abonnementId!,
          widget.sessionId!,
        );
        if (status == 'ACTIF') {
          _onSuccess();
          return;
        }
      } catch (_) {}
    }

    // ── Étape 2 : polling de secours ──────────────────────────────────────
    print("[PaymentSuccess] Lancement du polling de secours...");
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      _attempts++;
      if (_attempts > _maxAttempts) {
        _timer?.cancel();
        _onTimeout();
        return;
      }

      try {
        // On réessaie aussi /confirm à chaque tentative si sessionId dispo
        if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
          final status = await _service.confirmPayment(
            widget.abonnementId!,
            widget.sessionId!,
          );
          if (status == 'ACTIF') {
            _timer?.cancel();
            _onSuccess();
            return;
          }
        } else {
          // Fallback : poll simple du statut
          final status =
              await _service.getAbonnementStatus(widget.abonnementId!);
          if (status == 'ACTIF') {
            _timer?.cancel();
            _onSuccess();
            return;
          }
        }
      } catch (_) {}

      // Mise à jour du compteur affiché
      if (mounted) setState(() {});
    });
  }

  void _onSuccess() {
    if (!mounted) return;
    setState(() => _state = _PollState.success);
    _pulseController.stop();
    _checkController.forward();
    Future.delayed(const Duration(seconds: 2), _redirectHome);
  }

  void _onTimeout() {
    if (!mounted) return;
    setState(() => _state = _PollState.timeout);
    _pulseController.stop();
    // Pas de redirection auto sur timeout → l'utilisateur clique "Continuer"
  }

  void _redirectHome() {
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/homePage', (route) => false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(),
                const SizedBox(height: 36),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(),
                const SizedBox(height: 40),
                if (_state == _PollState.polling) _buildProgressBar(),
                if (_state != _PollState.polling) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _redirectHome,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text("Continuer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (_state) {
      case _PollState.polling:
        return ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkBlue.withOpacity(0.35),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3),
            ),
          ),
        );

      case _PollState.success:
        return ScaleTransition(
          scale: _checkAnim,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.green, const Color(0xFF5AB82E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: AppColors.green.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 6),
              ],
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 60),
          ),
        );

      case _PollState.timeout:
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withOpacity(0.2),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: const Icon(Icons.hourglass_bottom_rounded,
              color: Colors.orange, size: 50),
        );
    }
  }

  Widget _buildTitle() {
    final text = switch (_state) {
      _PollState.polling => 'Confirmation en cours…',
      _PollState.success => 'Abonnement activé ! 🎉',
      _PollState.timeout => 'Paiement reçu',
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3),
    );
  }

  Widget _buildSubtitle() {
    final text = switch (_state) {
      _PollState.polling =>
        'Nous vérifions votre paiement auprès de Stripe…\nCela prend généralement quelques secondes.',
      _PollState.success =>
        'Votre abonnement est maintenant actif.\nBienvenue à bord ! 🚌',
      _PollState.timeout =>
        'Votre paiement a bien été reçu par Stripe.\nL\'activation peut prendre quelques instants supplémentaires.\nVous pouvez revenir vérifier dans quelques minutes.',
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 15,
          height: 1.65),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _attempts / _maxAttempts,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tentative $_attempts / $_maxAttempts',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }
}

enum _PollState { polling, success, timeout }
