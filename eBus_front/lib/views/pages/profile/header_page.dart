import 'package:flutter/material.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/user.dart';
import '../../../constants/constants.dart';

class HeaderPage extends StatelessWidget {
  const HeaderPage({super.key, required this.currentUser, this.showBackButton = true});
  final User? currentUser;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    String? photoUrl = currentUser?.photoUrl;
    String fullUrl = "";
    if (photoUrl != null && photoUrl.isNotEmpty) {
      fullUrl = '${AppConstants.baseUrl}${photoUrl.startsWith('/') ? photoUrl : '/$photoUrl'}';
    }

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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBackButton && Navigator.canPop(context))
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            )
          else
            const SizedBox(height: 48), // Spacer to maintain layout when button is hidden
          
          const SizedBox(height: 20),

          Row(
            children: [
              // Avatar amélioré
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white24,
                  backgroundImage: fullUrl.isNotEmpty
                      ? NetworkImage(fullUrl)
                      : null,
                  child: fullUrl.isEmpty
                      ? Text(
                    "${currentUser?.nom.isNotEmpty == true ? currentUser!.nom[0].toUpperCase() : ''}"
                        "${currentUser?.prenom.isNotEmpty == true ? currentUser!.prenom[0].toUpperCase() : ''}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentUser?.nom ?? ''} ${currentUser?.prenom ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentUser?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
  }
}
