import 'package:flutter/material.dart';

import '../../home/home_page.dart';

class GuestButton extends StatelessWidget {
  const GuestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
          );
        },
        child: Text("Continuer en tant qu’invité",style:
        TextStyle(color: Colors.green),),
      ),
    );
  }
}
