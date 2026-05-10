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
  final VoidCallback? onDelete;

  const ObjetCard({
    super.key,
    required this.objet,
    required this.isAdmin,
    this.isOwner = false,
    this.onTap,
    this.onMarquerRecupere,
    this.onMarquerDisponible,
    this.onDelete,
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
    final Color themeColor = isPerte ? AppColors.darkBlue : AppColors.green;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne supérieure avec le type uniquement
                  Row(
                    children: [
                      _buildTypeBadge(isPerte, themeColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(themeColor, isPerte),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              objet.nom ?? 'Objet sans nom',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              objet.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Informations ligne et date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoRow(Icons.directions_bus_outlined, 'Ligne ${objet.ligneNom ?? "N/A"}'),
                      _buildInfoRow(Icons.calendar_today_rounded, '${objet.dateDeclaration.day}/${objet.dateDeclaration.month}/${objet.dateDeclaration.year}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Ligne de statut en bas (comme dans les réclamations)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StatutBadge(statut: objet.statut),
                    ],
                  ),
                  if (isAdmin) ...[
                    const Divider(height: 24),
                    _buildAdminButtons(),
                  ]
                ],
              ),
            ),
          ),
        ),
        // Le bouton de suppression "X" rouge (identique aux réclamations)
        if (onDelete != null)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onDelete,
            ),
          ),
      ],
    );
  }

  Widget _buildTypeBadge(bool isPerte, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPerte ? "PERDU" : "TROUVÉ",
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImage(Color themeColor, bool isPerte) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: (objet.imageUrl != null && objet.imageUrl!.isNotEmpty)
            ? Image.network(
          getImageUrl(objet.imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, color: themeColor),
        )
            : Icon(
          isPerte ? Icons.search_rounded : Icons.inventory_2_outlined,
          color: themeColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAdminButtons() {
    if (objet.statut == StatutObjet.EN_ATTENTE) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onMarquerDisponible,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("VALIDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (objet.statut == StatutObjet.DISPONIBLE || objet.statut == StatutObjet.EN_ATTENTE_RECUPERATION) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onMarquerRecupere,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("MARQUER RÉCUPÉRÉ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
