import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/views/pages/claims/claims_list.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/claims/claims_bloc.dart';
import '../../../bloc/claims/claims_event.dart';
import '../../../bloc/claims/claims_state.dart';
import '../../../enums/enums.dart';
import '../../../enums/reclamation_status.dart';
import '../../../models/Reclamation.dart';
import '../../UI/confirm_delete_dialog.dart';
import '../../../utils/app_snack_bar.dart';

class ClaimCard extends StatelessWidget {
  final Reclamation claim;
  final VoidCallback? onDelete;

  const ClaimCard({super.key, required this.claim, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isProcessed = claim.status == ReclamationStatus.TRAITEE;

    return BlocSelector<AuthBloc, AuthState, bool>(
      selector: (state) {
        // L'utilisateur est admin
        if (state is AuthAuthenticated) {
          return state.user.role == Role.ADMIN;
        }
        return false;
      },
      builder: (context, isAdmin) {
        return BlocListener<ClaimsBloc, ClaimsState>(
          listener: (context, state) {
            if (state is ClaimsDeleted) {
              AppSnackBar.showSuccess(context, "Réclamation supprimée avec succès");
              // Recharge la liste après suppression
              context.read<ClaimsBloc>().add(LoadClaims());
            } else if (state is ClaimsUpdated) {
              AppSnackBar.showSuccess(context, "Statut mis à jour avec succès");
              context.read<ClaimsBloc>().add(LoadClaims());
            } else if (state is ClaimsError) {
              AppSnackBar.showError(context, state.error);
            }
          },
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isProcessed
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: isProcessed ? Colors.green : Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                claim.titre ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              if (claim.ligneId != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "Ligne ${claim.ligneId}",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                claim.description ?? "",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          claim.date != null
                              ? "${claim.date!.day}/${claim.date!.month}/${claim.date!.year}"
                              : "",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isProcessed
                                ? Colors.green.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: isAdmin
                              ? DropdownButton<ReclamationStatus>(
                            value: claim.status,
                            underline: const SizedBox(),
                            items: ReclamationStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status.label,
                                  style: TextStyle(
                                    color: status == ReclamationStatus.TRAITEE
                                        ? Colors.green
                                        : Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null && newStatus != claim.status) {
                                context.read<ClaimsBloc>().add(
                                  UpdateClaim(
                                    id: claim.id!,
                                    patch: {
                                      'status': newStatus.toString().split('.').last
                                    },
                                  ),
                                );
                              }
                            },
                          )
                              : Text(
                            claim.status?.label ?? "",
                            style: TextStyle(
                              color: isProcessed ? Colors.green : Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              if (isAdmin)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onDelete ??
                            () {
                          showDialog(
                            context: context,
                            builder: (_) => ConfirmDeleteDialog(
                              title: "Supprimer la réclamation",
                              content: "Êtes-vous sûr de vouloir supprimer cette réclamation ?",
                              onConfirm: () {
                                context.read<ClaimsBloc>().add(DeleteClaim(claim.id!));
                              },
                            ),
                          );
                        },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}