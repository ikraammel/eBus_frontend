import 'package:flutter/material.dart';
import 'package:smart_bus/models/User.dart';

import '../../../constants/constants.dart';

class HeaderPage extends StatelessWidget {
  const HeaderPage({super.key,required this.currentUser});
  final User? currentUser;

  @override
  Widget build(BuildContext context) {
    print("Photo URL: ${currentUser?.photoUrl}");
    print("Full URL: ${AppConstants.baseUrl}/${currentUser?.photoUrl}");
    String fullUrl = '${AppConstants.baseUrl}${currentUser!.photoUrl!.startsWith('/') ? currentUser!.photoUrl : '/${currentUser!.photoUrl}'}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50, bottom: 40, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B3C83), Color(0xFF76BC41)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back,color: Colors.white,)
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white24,
                  backgroundImage: (currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty)
                      ? NetworkImage(
                    fullUrl,
                  )
                      : null,
                  child: (currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty)
                      ? Text(
                    (currentUser?.nom.isNotEmpty == true && currentUser?.prenom.isNotEmpty == true)
                        ? "${currentUser!.nom[0].toUpperCase()}${currentUser!.prenom[0].toUpperCase()}"
                        : "JD",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser != null ?
                        '${currentUser?.nom}  ${currentUser?.prenom}'
                            : "User",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                        ),
                      ),Text(
                          currentUser != null ?
                          '${currentUser?.email}'
                              : "User",
                          style: TextStyle(color: Colors.white70, fontSize: 14)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
