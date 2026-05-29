import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/user.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../constants/constants.dart';

class HeaderPage extends StatefulWidget {
  const HeaderPage({
    super.key,
    required this.currentUser,
    this.showBackButton = true,
    this.allowEditAvatar = false,
  });

  final User? currentUser;
  final bool showBackButton;
  final bool allowEditAvatar;

  @override
  State<HeaderPage> createState() => _HeaderPageState();
}

class _HeaderPageState extends State<HeaderPage> {

  // ── Affiche le BottomSheet de choix source photo ─────────────────────────
  Future<void> _showPickerOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur de drag
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Modifier la photo de profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            _sourceOption(
              ctx,
              icon: Icons.photo_library_rounded,
              label: 'Choisir depuis la galerie',
              color: AppColors.darkBlue,
              source: ImageSource.gallery,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _sourceOption(
              ctx,
              icon: Icons.camera_alt_rounded,
              label: 'Prendre une photo',
              color: AppColors.green,
              source: ImageSource.camera,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption(
      BuildContext ctx, {
        required IconData icon,
        required String label,
        required Color color,
        required ImageSource source,
      }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: () async {
        Navigator.pop(ctx); // ferme le BottomSheet
        await _pickAndUpload(source);
      },
    );
  }

  // ── Sélectionne la photo et déclenche l'upload ────────────────────────────
  Future<void> _pickAndUpload(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (image != null && mounted && widget.currentUser != null) {
      context.read<AuthBloc>().add(AuthUpdateAvatarRequested(
        id: widget.currentUser!.id,
        photo: image,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // Écoute les états pour afficher snackbar ou erreur
      listener: (context, state) {
        if (state is AuthProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Photo de profil mise à jour !'),
              ]),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${state.error}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, authState) {
        final isLoading = authState is AuthLoading;

        // Utilise l'user mis à jour si dispo, sinon widget.currentUser
        final user = authState is AuthAuthenticated
            ? authState.user
            : authState is AuthProfileUpdated
            ? authState.user
            : widget.currentUser;

        // Construction de l'URL complète de la photo
        final photoUrl = user?.photoUrl ?? '';
        final fullUrl = photoUrl.isNotEmpty
            ? '${AppConstants.baseUrl}${photoUrl.startsWith('/') ? photoUrl : '/$photoUrl'}'
            : '';
        final canEditAvatar = widget.allowEditAvatar;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, bottom: 40, left: 20, right: 20),
          decoration: const BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showBackButton && Navigator.canPop(context))
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                )
              else
                const SizedBox(height: 48),

              const SizedBox(height: 20),

              Row(
                children: [
                  // ── Avatar cliquable ───────────────────────────────────────
                  GestureDetector(
                    onTap: canEditAvatar ? () => _showPickerOptions(context) : null,
                    child: Stack(
                      children: [
                        // Anneau blanc
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white24,
                            // Affiche un spinner si upload en cours
                            child: isLoading
                                ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                                : ClipOval(
                              child: fullUrl.isNotEmpty
                                  ? Image.network(
                                fullUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                // Timestamp pour forcer le refresh après upload
                                key: ValueKey(fullUrl),
                                errorBuilder: (_, __, ___) =>
                                    _initialesWidget(user),
                              )
                                  : _initialesWidget(user),
                            ),
                          ),
                        ),

                        if (canEditAvatar)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black38, blurRadius: 4),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ── Infos utilisateur ──────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user?.nom ?? ''} ${user?.prenom ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        if (user?.role.toString().contains('ADMIN') ?? false)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ADMINISTRATEUR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Initiales quand pas de photo ──────────────────────────────────────────
  Widget _initialesWidget(User? user) {
    final initiales =
        '${user?.nom.isNotEmpty == true ? user!.nom[0].toUpperCase() : ''}'
        '${user?.prenom.isNotEmpty == true ? user!.prenom[0].toUpperCase() : ''}';
    return Container(
      width: 90,
      height: 90,
      color: Colors.white24,
      alignment: Alignment.center,
      child: Text(
        initiales,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
