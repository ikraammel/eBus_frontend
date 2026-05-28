import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/constants.dart';
import '../../../../models/dossier.dart';
import '../../../../services/admin_dossier_service.dart';
import '../../../../utils/shared_prefs_helper.dart';

class AdminDossierDetailPage extends StatelessWidget {
  final Dossier dossier;

  const AdminDossierDetailPage({super.key, required this.dossier});

  @override
  Widget build(BuildContext context) {
    final isEtudiant = _isEtudiant;

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
            if (dossier.email != null && dossier.email!.isNotEmpty)
              _buildInfoTile(Icons.email, "Email", dossier.email!),
            if (dossier.tel != null && dossier.tel!.isNotEmpty)
              _buildInfoTile(Icons.phone, "Telephone", dossier.tel!),
            if (dossier.adresse != null && dossier.adresse!.isNotEmpty)
              _buildInfoTile(Icons.location_on, "Adresse", dossier.adresse!),
            if (dossier.typeAbonnement != null && dossier.typeAbonnement!.isNotEmpty)
              _buildInfoTile(Icons.card_membership, "Type abonnement", dossier.typeAbonnement!),
            _buildInfoTile(Icons.badge, "CIN", dossier.cin ?? "N/A"),
            if (isEtudiant && dossier.cne != null && dossier.cne!.isNotEmpty)
              _buildInfoTile(Icons.school, "CNE/Massar", dossier.cne!),
            
            const SizedBox(height: 25),
            _buildSectionTitle("Documents justificatifs"),
            const SizedBox(height: 15),
            
            _buildPhotoViewer(context),
            _buildDocumentViewer(context, "CIN (Recto/Verso)", dossier.cinUrl),
            
            // Correction : Utilisation du champ correct carteScolaireUrl pour les étudiants
            if (isEtudiant) ...[
              if (dossier.carteScolaireUrl != null && dossier.carteScolaireUrl!.isNotEmpty)
                _buildDocumentViewer(context, "Carte scolaire", dossier.carteScolaireUrl),
              if (dossier.attestationScolaireUrl != null && dossier.attestationScolaireUrl!.isNotEmpty)
                _buildDocumentViewer(context, "Attestation de scolarite", dossier.attestationScolaireUrl),
            ],
            
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

  bool get _isEtudiant {
    final type = (dossier.typeAbonnement ?? "")
        .toUpperCase()
        .trim()
        .replaceAll("É", "E")
        .replaceAll("È", "E")
        .replaceAll("Ê", "E");
    return type.contains("SCOLAIRE") ||
        type.contains("ETUDIANT") ||
        (dossier.cne != null && dossier.cne!.isNotEmpty);
  }

  Widget _buildPhotoViewer(BuildContext context) {
    if (dossier.photoUrl != null && dossier.photoUrl!.isNotEmpty) {
      return _buildDocumentViewer(context, "Photo", dossier.photoUrl, required: true);
    }

    return FutureBuilder<Dossier?>(
      future: AdminDossierService().getDossierById(dossier.id),
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?.photoUrl;
        if (photoUrl != null && photoUrl.isNotEmpty) {
          return _buildDocumentViewer(context, "Photo", photoUrl, required: true);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildDocumentViewer(context, "Photo", null, required: true);
      },
    );
  }

  Widget _buildDocumentViewer(
    BuildContext context,
    String label,
    String? url, {
    bool required = false,
  }) {
    if (url == null || url.isEmpty) {
      if (!required) return const SizedBox.shrink();
      return _buildMissingDocument(label);
    }

    final String fullUrl = _buildFullUrl(url);

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
              child: FutureBuilder<String?>(
                future: SharedPrefsHelper.getToken(),
                builder: (context, snapshot) {
                  final token = snapshot.data;

                  return Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    headers: token != null
                        ? {'Authorization': 'Bearer $token'}
                        : null,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMissingDocument(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade100,
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported, size: 42, color: Colors.grey),
              SizedBox(height: 8),
              Text("Document non disponible", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _buildFullUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final base = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
        : AppConstants.baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
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
              child: Center(
                child: FutureBuilder<String?>(
                  future: SharedPrefsHelper.getToken(),
                  builder: (context, snapshot) {
                    final token = snapshot.data;

                    return Image.network(
                      url,
                      fit: BoxFit.contain,
                      headers: token != null
                          ? {'Authorization': 'Bearer $token'}
                          : null,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 64,
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                    );
                  },
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
