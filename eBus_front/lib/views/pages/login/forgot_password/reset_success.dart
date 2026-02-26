import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';

class ResetSuccess extends StatelessWidget {
  const ResetSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Réussi !',
            style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Votre mot de passe a été réinitialisé avec succès.',
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: (){
                Navigator.pushReplacementNamed(context, "/loginPage");
              },
              child: Text(
                'Se Connecter',
                style: TextStyle(
                  color: AppColors.green,
                ),
              )
          ),
          ]
      ),
    );
  }
}
