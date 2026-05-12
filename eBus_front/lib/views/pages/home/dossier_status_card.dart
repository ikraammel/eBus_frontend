import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/abonnement.dart';
import 'package:smart_bus/services/ticket_service.dart';
import 'package:smart_bus/views/pages/tickets/ticket_page.dart';

class DossierStatusCard extends StatelessWidget {
  final String? status;
  final String? rejectionReason;
  final int? userId; // pour charger le statut abonnement en temps réel

  const DossierStatusCard({
    super.key,
    this.status,
    this.rejectionReason,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final s = status?.toUpperCase().trim() ?? "";

    // ── Dossier VALIDE → charger l'abonnement actuel ──────────────────────
    if ((s == "VALIDE" || s == "VALIDÉ") && userId != null) {
      return FutureBuilder<Abonnement?>(
        future: TicketService().getCurrentAbonnement(userId!),
        builder: (ctx, snap) {
          // Pendant le chargement, on affiche un indicateur léger
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildShell(
              context,
              color: AppColors.green,
              icon: Icons.check_circle_rounded,
              message: "Dossier validé 🎉",
              actionButton: null,
              showLoader: true,
            );
          }
          final abo = snap.data;

          // ── Abonnement ACTIF : ne plus afficher le bouton paiement ───────
          if (abo != null && abo.isActif) {
            final jours = abo.joursRestants;
            return _buildShell(
              context,
              color: AppColors.green,
              icon: Icons.verified_rounded,
              message:
                  "🎉 Votre abonnement ${_fmt(abo.typeNom)} est actif !\n"
                  "Expire dans $jours jour${jours > 1 ? 's' : ''}.",
              actionButton: null, // ✅ Pas de bouton quand déjà actif
            );
          }

          // ── Paiement EN_ATTENTE : bouton "Finaliser" ─────────────────────
          if (abo != null && abo.isEnAttente) {
            return _buildShell(
              context,
              color: Colors.blue,
              icon: Icons.hourglass_top_rounded,
              message:
                  "⏳ Votre paiement est en attente de confirmation.\n"
                  "Cliquez ci-dessous pour finaliser ou réessayer.",
              actionButton: _btn(
                context,
                label: "Finaliser le paiement",
                icon: Icons.payment_rounded,
                color: Colors.blue,
              ),
            );
          }

          // ── Pas encore d'abonnement ou abonnement expiré/refusé ──────────
          return _buildShell(
            context,
            color: AppColors.green,
            icon: Icons.check_circle_rounded,
            message:
                "Dossier validé 🎉 Vous pouvez maintenant souscrire à un abonnement.",
            actionButton: _btn(
              context,
              label: "Procéder au paiement",
              icon: Icons.card_membership_rounded,
              color: AppColors.green,
            ),
          );
        },
      );
    }

    // ── Dossier REJETE ────────────────────────────────────────────────────
    if (s == "REJETE" || s == "REJETÉ") {
      return _buildShell(
        context,
        color: Colors.red,
        icon: Icons.cancel_rounded,
        message: "Votre dossier a été rejeté.",
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
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
          ),
        ),
      );
    }

    // ── EN_COURS ──────────────────────────────────────────────────────────
    if (s == "EN_COURS") {
      return _buildShell(
        context,
        color: Colors.orange,
        icon: Icons.hourglass_bottom,
        message:
            "Votre dossier est en cours de vérification par l'administration.",
        actionButton: null,
      );
    }

    // ── EN_ATTENTE (dossier pas encore validé) ────────────────────────────
    return _buildShell(
      context,
      color: Colors.blue,
      icon: Icons.info_rounded,
      message: "Votre dossier est en cours de traitement.",
      actionButton: null,
    );
  }

  // ── Shell commun ──────────────────────────────────────────────────────────
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
                    // Motif rejet
                    if (rejectionReason != null &&
                        rejectionReason!.trim().isNotEmpty) ...[
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TicketPage(openAbonnementsTab: true),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
