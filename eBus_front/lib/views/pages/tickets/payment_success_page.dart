import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/services/dossier_service.dart';
import 'package:smart_bus/services/ticket_service.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? sessionId;

  const PaymentSuccessPage({
    super.key,
    this.sessionId,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  final TicketService _service = TicketService();
  final DossierService _dossierService = DossierService();

  _ConfirmState _state = _ConfirmState.loading;
  String? _sessionId;
  String? _message;

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
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionId = _resolveSessionId();
      print("[PaymentSuccess] session_id recupere=$_sessionId");
      _confirmPayment();
    });
  }

  String? _resolveSessionId() {
    if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
      return widget.sessionId;
    }

    final base = Uri.base;
    final querySession = base.queryParameters['session_id'];
    if (querySession != null && querySession.isNotEmpty) return querySession;

    final fragment = base.fragment;
    if (fragment.isNotEmpty) {
      final fragmentUri = Uri.tryParse(
        fragment.startsWith('/') ? fragment : '/$fragment',
      );
      final fragmentSession = fragmentUri?.queryParameters['session_id'];
      if (fragmentSession != null && fragmentSession.isNotEmpty) {
        return fragmentSession;
      }
    }

    return null;
  }

  Future<void> _confirmPayment() async {
    final sessionId = _sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      print("[PaymentSuccess] session_id manquant");
      setState(() {
        _state = _ConfirmState.error;
        _message = "Session Stripe introuvable.";
      });
      _pulseController.stop();
      return;
    }

    setState(() {
      _state = _ConfirmState.loading;
      _message = null;
    });
    _pulseController.repeat(reverse: true);

    try {
      print("[PaymentSuccess] appel API confirm sessionId=$sessionId");
      final status = await _service.confirmPayment(sessionId);
      print("[PaymentSuccess] reponse backend=$status");

      if (!mounted) return;
      if (status.trim().toUpperCase() == 'ACTIF') {
        await _reloadUserAndSubscription();
        _onSuccess();
      } else {
        _onPending();
      }
    } catch (e) {
      print("[PaymentSuccess] erreur confirmation=$e");
      if (!mounted) return;
      setState(() {
        _state = _ConfirmState.error;
        _message = "Impossible de confirmer le paiement pour le moment.";
      });
      _pulseController.stop();
    }
  }

  Future<void> _reloadUserAndSubscription() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      await _dossierService.getMyDossier(authState.user.id);
      await _service.getCurrentAbonnement(authState.user.id);
    }
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  void _onSuccess() {
    if (!mounted) return;
    setState(() => _state = _ConfirmState.success);
    _pulseController.stop();
    _checkController.forward();
  }

  void _onPending() {
    if (!mounted) return;
    setState(() {
      _state = _ConfirmState.pending;
      _message = "Paiement en cours de verification.";
    });
    _pulseController.stop();
  }

  void _redirectHome() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/homePage', (route) => false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

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
                if (_state == _ConfirmState.loading) _buildProgressBar(),
                if (_state == _ConfirmState.pending) _buildRefreshButton(),
                if (_state == _ConfirmState.success || _state == _ConfirmState.error)
                  _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (_state) {
      case _ConfirmState.loading:
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
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            ),
          ),
        );

      case _ConfirmState.success:
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
                  spreadRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
          ),
        );

      case _ConfirmState.pending:
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

      case _ConfirmState.error:
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.2),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: const Icon(Icons.error_outline_rounded,
              color: Colors.red, size: 50),
        );
    }
  }

  Widget _buildTitle() {
    final text = switch (_state) {
      _ConfirmState.loading => 'Confirmation en cours...',
      _ConfirmState.success => 'Abonnement actif !',
      _ConfirmState.pending => 'Verification en cours',
      _ConfirmState.error => 'Confirmation impossible',
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildSubtitle() {
    final text = _message ?? _defaultSubtitle();
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withOpacity(0.72),
        fontSize: 15,
        height: 1.65,
      ),
    );
  }

  String _defaultSubtitle() {
    return switch (_state) {
      _ConfirmState.loading =>
        'Nous verifions votre paiement aupres de Stripe.\nCela prend generalement quelques secondes.',
      _ConfirmState.success =>
        'Votre abonnement est maintenant actif.\nVous pouvez acceder aux services abonnes.',
      _ConfirmState.pending =>
        'Votre paiement est en cours de verification.\nVous pouvez rafraichir dans quelques instants.',
      _ConfirmState.error =>
        'Veuillez reessayer ou contacter le support si le probleme persiste.',
    };
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        backgroundColor: Colors.white12,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
        minHeight: 6,
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _confirmPayment,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text("Rafraichir"),
          style: _buttonStyle(AppColors.green),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _redirectHome,
          child: const Text("Continuer", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton.icon(
      onPressed: _redirectHome,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: const Text("Continuer"),
      style: _buttonStyle(AppColors.green),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

enum _ConfirmState { loading, success, pending, error }
