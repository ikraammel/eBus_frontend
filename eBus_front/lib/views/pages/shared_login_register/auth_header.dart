import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key,required this.label1,required this.label2});

  final String label1;
  final String label2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Image.asset(
              'assets/logobus.png',
              height: 250,
              width: 300,
            ),
          ),
          const SizedBox(height: 1),
           Text(
            label1,
            style: TextStyle(
              color: Color(0xFF1A367C),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 5),
           Text(
            label2,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          SizedBox(height:20),
        ],
      ),
    );
  }
}
