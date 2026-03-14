import 'package:flutter/material.dart';
import 'package:smart_bus/views/pages/admin/login/login_page_admin.dart';

import '../../../constants/app_colors.dart';

class AdministratorAccess extends StatelessWidget {
  const AdministratorAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginPageAdmin())
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Accès administrateur',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}