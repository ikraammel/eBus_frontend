import 'package:flutter/material.dart';
import 'package:smart_bus/enums/enums.dart';
import 'package:smart_bus/models/objet_perdu.dart';
import 'package:smart_bus/models/statut_objet.dart';
import '../../constants/app_colors.dart' show AppColors;
import '../../constants/constants.dart';
import 'statut_badge.dart';

class ObjetCard extends StatelessWidget {
  final ObjetPerdu objet;
  final bool isAdmin;
  final bool isOwner;
  final VoidCallback? onTap;
  final VoidCallback? onMarquerRecupere;
  final VoidCallback? onMarquerDisponible;
  final VoidCallback? onCestMonObjet;

  const ObjetCard({
    super.key,
    required this.objet,
    required this.isAdmin,
    this.isOwner = false,
    this.onTap,
    this.onMarquerRecupere,
    this.onMarquerDisponible,
    this.onCestMonObjet,
  });

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "${AppConstants.baseUrl}/$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    final bool isPerte = objet.type == TypeAnnonce.PERTE;
    final StatutObjet statut = objet.statut;
    final Color themeColor = isPerte ? AppColors.darkBlue : AppColors.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: (objet.imageUrl != null && objet.imageUrl!.isNotEmpty)
                            ? Image.network(
                          getImageUrl(objet.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, color: themeColor),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                        )
                            : Icon(
                          isPerte ? Icons.search_rounded : Icons.inventory_2_outlined,
                          color: themeColor,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            objet.nom ?? 'Objet sans nom',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            objet.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.darkBlue.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _infoIcon(Icons.directions_bus_outlined, 'Ligne ${objet.ligneNom ?? "N/A"}'),
                    const SizedBox(width: 20),
                    _infoIcon(Icons.directions_bus, objet.busImmatriculation ?? 'Bus N/A'),
                    const SizedBox(width: 20),
                    _infoIcon(
                      Icons.calendar_today_rounded,
                      '${objet.dateDeclaration.day}/${objet.dateDeclaration.month}/${objet.dateDeclaration.year}',
                    ),
                  ],
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  if (objet.userNom != null) _info('Signalé par: ${objet.userNom}'),
                  if (objet.contact != null) _info('Contact: ${objet.contact}', color: AppColors.primaryColor),
                ],
                const SizedBox(height: 18),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    Widget details = Expanded(
      child: OutlinedButton.icon(
        icon: Icon(Icons.info_outline, size: 18, color: AppColors.primaryColor),
        label: Text('Détails', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );

    if (isAdmin) {
      return Row(
        children: [
          details,
          const SizedBox(width: 12),
          if (objet.statut == StatutObjet.EN_ATTENTE)
            Expanded(
              child: ElevatedButton(
                onPressed: onMarquerDisponible,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("VALIDER", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else if (objet.statut == StatutObjet.DISPONIBLE || objet.statut == StatutObjet.EN_ATTENTE_RECUPERATION)
            Expanded(
              child: ElevatedButton(
                onPressed: onMarquerRecupere,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("RÉCUPÉRÉ", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      );
    }
    return Row(children: [details]);
  }

  Widget _typeBadge(bool isPerte) {
    final color = isPerte ? AppColors.darkBlue : AppColors.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPerte ? Icons.error_outline : Icons.check_circle_outline, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            isPerte ? "PERDU" : "TROUVÉ",
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _infoIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.darkBlue.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.darkBlue.withOpacity(0.7))),
      ],
    );
  }

  Widget _info(String text, {Color color = AppColors.darkBlue}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}