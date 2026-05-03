import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/constants.dart';
import '../../../../models/dossier.dart';

class AdminDossierDetailPage extends StatelessWidget {
  final Dossier dossier;

  const AdminDossierDetailPage({super.key, required this.dossier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${dossier.prenom} ${dossier.nom}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Informations personnelles"),
            _buildInfoTile(Icons.person, "Nom complet", "${dossier.prenom} ${dossier.nom}"),
            _buildInfoTile(Icons.badge, "CIN", dossier.cin ?? "N/A"),
            if (dossier.cne != null && dossier.cne!.isNotEmpty)
              _buildInfoTile(Icons.school, "CNE/Massar", dossier.cne!),
            
            const SizedBox(height: 25),
            _buildSectionTitle("Documents justificatifs"),
            const SizedBox(height: 15),
            
            _buildDocumentViewer(context, "Photo de profil", dossier.photoUrl),
            _buildDocumentViewer(context, "CIN (Recto/Verso)", dossier.cinUrl),
            
            // Correction : Utilisation du champ correct carteScolaireUrl pour les étudiants
            if (dossier.carteScolaireUrl != null && dossier.carteScolaireUrl!.isNotEmpty)
              _buildDocumentViewer(context, "Carte scolaire / Attestation", dossier.carteScolaireUrl),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkBlue),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDocumentViewer(BuildContext context, String label, String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    final String fullUrl = "${AppConstants.baseUrl}${url.startsWith('/') ? '' : '/'}$url";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showFullScreenImage(context, fullUrl),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(url), fit: BoxFit.contain),
                ),
              ),
            ),
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
}
