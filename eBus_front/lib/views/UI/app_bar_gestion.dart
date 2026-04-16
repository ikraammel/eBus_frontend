import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_bus/enums/claims_sort_type.dart';

import '../../constants/app_colors.dart';

class AppBarGestion extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final Color bgColor;
  final Function()? onPressed;
  final List<PopupMenuButton<ClaimsSortType>>? actions;


  const AppBarGestion({
    super.key,
    required this.title,
    this.bgColor = AppColors.darkBlue,
    this.onPressed, this.actions
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor,
      actions: actions,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              color: Colors.white,
              onPressed: onPressed,
              icon: Icon(
                CupertinoIcons.plus,
                size: 20,
              ),
            ),
          )
        ],
      ),

    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
