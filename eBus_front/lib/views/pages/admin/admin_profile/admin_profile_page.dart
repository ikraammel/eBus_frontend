import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth/auth_bloc.dart';
import '../../../../bloc/auth/auth_state.dart';
import '../../../../main.dart';
import '../../../../services/local_storage_service.dart';
import '../../../UI/splash_screen.dart';
import '../../profile/header_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  @override
  Widget build(BuildContext context) {
    final storage = getIt<LocalStorageService>();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  HeaderPage(currentUser: user),
                ],
              ),
            ),
          );
        }
        return SplashScreen();
      },
    );
  }
}
