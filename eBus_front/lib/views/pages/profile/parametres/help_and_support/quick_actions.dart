import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key,required this.text,required this.icon,this.color,this.onTap});

  final String text;
  final IconData icon;
  final Color? color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        title: Text(text),
        onTap: onTap,
        leading: Icon(icon,color: color,),
      ),
    );
  }
}
