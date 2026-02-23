import 'package:flutter/material.dart';

class ExpansionTileItems extends StatelessWidget {
  const ExpansionTileItems({super.key,required this.title,required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w500
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
