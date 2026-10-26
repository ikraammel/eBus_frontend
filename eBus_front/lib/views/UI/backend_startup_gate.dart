import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../services/backend_health_service.dart';
import '../../utils/dio_interceptor.dart';
import 'splash_screen.dart';

/// Holds the Navigator (including initial Stripe routes) until HTTP 200.
class BackendStartupGate extends StatefulWidget {
  const BackendStartupGate({
    super.key,
    required this.child,
    required this.onReady,
  });

  final Widget child;
  final VoidCallback onReady;

  @override
  State<BackendStartupGate> createState() => _BackendStartupGateState();
}

class _BackendStartupGateState extends State<BackendStartupGate> {
  CancelToken? _cancellation;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    if (_cancellation != null) return;
    final cancellation = CancelToken();
    _cancellation = cancellation;
    setState(() => _failed = false);
    try {
      await BackendHealthService(DioClient.dio).waitUntilReady(cancellation);
      if (mounted) {
        setState(() => _ready = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onReady();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      _cancellation = null;
    }
  }

  @override
  void dispose() {
    _cancellation?.cancel('Startup widget disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ready
      ? widget.child
      : SplashScreen(
          message: _failed
              ? 'Impossible de joindre le serveur après 120 secondes. '
                    'Vérifiez votre connexion puis réessayez.'
              : 'Connexion au serveur en cours...\n'
                    'Le premier chargement peut prendre quelques instants.',
          onRetry: _failed ? _connect : null,
        );
}
