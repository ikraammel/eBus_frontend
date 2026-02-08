import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Mot de passe oublié ?',
            style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold
            ),
          ),
        ]
    );
  }
}
