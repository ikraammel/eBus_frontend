import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/abonnement.dart';
import 'package:smart_bus/services/ticket_service.dart';

class DossierStatusCard extends StatelessWidget {
  final String? status;
  final String? rejectionReason;
  final int? userId;
  final VoidCallback? onOpenTickets;

  const DossierStatusCard({
    super.key,
    this.status,
    this.rejectionReason,
    this.userId,
    this.onOpenTickets,
  });

  @override
  Widget build(BuildContext context) {
    final s = _normalizeStatus(status);

    if (_isAccepted(s) && userId != null) {
      return FutureBuilder<Abonnement?>(
        future: TicketService().getCurrentAbonnement(userId!),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildShell(
              context,
              color: AppColors.green,
              icon: Icons.check_circle_rounded,
              message: "Dossier valide",
              actionButton: null,
              showLoader: true,
            );
          }
          final abo = snap.data;

          if (abo != null && abo.isActif) {
            final jours = abo.joursRestants;
            return _buildShell(
              context,
              color: AppColors.green,
              icon: Icons.verified_rounded,
              message:
                  "Votre abonnement ${_fmt(abo.typeNom)} est actif !\n"
                  "Expire dans $jours jour${jours > 1 ? 's' : ''}.",
              actionButton: null,
            );
          }

          if (abo != null && abo.isEnAttente) {
            return _buildShell(
              context,
              color: Colors.blue,
              icon: Icons.hourglass_top_rounded,
              message:
                  "Votre paiement est en attente de confirmation.\n"
                  "Nous verifierons automatiquement le statut de votre abonnement.",
              actionButton: null,
            );
          }

          return _buildShell(
            context,
            color: AppColors.green,
            icon: Icons.check_circle_rounded,
            message:
                "Dossier valide. Vous pouvez maintenant souscrire a un abonnement.",
            actionButton: _btn(
              context,
              label: "Proceder au paiement",
              icon: Icons.card_membership_rounded,
              color: AppColors.green,
            ),
          );
        },
      );
    }

    if (_isRejected(s)) {
      return _buildShell(
        context,
        color: Colors.red,
        icon: Icons.cancel_rounded,
        message: "Votre dossier a ete rejete.",
        rejectionReason: rejectionReason,
        actionButton: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/personalInfos'),
            icon: const Icon(Icons.edit_document, size: 18),
            label: const Text(
              "Modifier mes informations",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
          ),
        ),
      );
    }

    if (s == "EN_COURS") {
      return _buildShell(
        context,
        color: Colors.orange,
        icon: Icons.hourglass_bottom,
        message: "Votre dossier est en cours de verification par l'administration.",
        actionButton: null,
      );
    }

    return _buildShell(
      context,
      color: Colors.blue,
      icon: Icons.info_rounded,
      message: "Votre dossier est en cours de traitement.",
      actionButton: null,
    );
  }

  String _normalizeStatus(String? value) {
    return (value ?? "")
        .toUpperCase()
        .trim()
        .replaceAll("É", "E")
        .replaceAll("È", "E")
        .replaceAll("Ê", "E")
        .replaceAll("À", "A");
  }

  bool _isAccepted(String status) {
    return status == "VALIDE" || status == "ACCEPTED";
  }

  bool _isRejected(String status) {
    return status == "REJETE" || status == "REJECTED" || status == "REFUSE";
  }

  Widget _buildShell(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String message,
    required Widget? actionButton,
    String? rejectionReason,
    bool showLoader = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: color.darken(0.15),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (rejectionReason != null &&
                        rejectionReason.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Motif du rejet : $rejectionReason",
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (showLoader) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(
                          color: color,
                          backgroundColor: color.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (actionButton != null) ...[
            const SizedBox(height: 12),
            actionButton,
          ],
        ],
      ),
    );
  }

  Widget _btn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onOpenTickets,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
      ),
    );
  }

  String _fmt(String nom) {
    return nom
        .toLowerCase()
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
