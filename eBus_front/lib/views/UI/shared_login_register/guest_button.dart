import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../constants/app_colors.dart';

class GuestButton extends StatelessWidget {
  const GuestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.darkBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: AppColors.darkBlue,
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/homePage");
        },
        child: const Text(
          "Continuer en tant qu’invité",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}