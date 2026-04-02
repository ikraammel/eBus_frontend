import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfos extends StatelessWidget {
  const AppInfos({super.key});

  Future<String> getVersion() async{
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Widget build(BuildContext context) {
     return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
         color: Colors.transparent,
         borderRadius: BorderRadius.circular(16),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.04),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
         ],
       ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informations de l'application",
            style: TextStyle(
              color: Colors.black, // Ton bleu eBus
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 15,),
          FutureBuilder<String>(
            future: getVersion(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildInfoRow("Version", "...");
              }

              if (snapshot.hasError) {
                print(snapshot.error);
                return _buildInfoRow("Version", "Erreur");
              }

              return _buildInfoRow("Version", snapshot.data ?? "");
            },
          ),
          SizedBox(height: 15,),
        ],
      ),
    );
  }
  Widget _buildInfoRow(String label,String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.blueGrey.shade600,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

      ],
    );
  }
}
