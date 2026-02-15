import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key,required this.label1,required this.label2,this.image});

  final String label1;
  final String label2;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 35,),
          if(image != null)
            Center(
              child: Image.asset(
                image!,
                height: 100,
                width: 200,
              ),
            ),

           SizedBox(height: 30,),

           Center(
             child: Text(
              label1,
              style: TextStyle(
                color: Color(0xFF1A367C),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
                       ),
           ),
          const SizedBox(height: 5),
           Center(
             child: Text(
              label2,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
                       ),
           ),
          SizedBox(height:20),
        ],
      ),
    );
  }
}
