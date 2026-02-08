import 'package:flutter/material.dart';

class SwitchAuthPage extends StatelessWidget {
  const SwitchAuthPage({super.key, required this.questionText, required this.actionText, required this.onTap});

  final String questionText;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(questionText),
        GestureDetector(
          onTap: onTap,
          child: Text(actionText,
            style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold
            ),
          )
        ),
      ],
    );
  }
}
