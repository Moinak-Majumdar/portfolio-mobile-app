import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/auth/biometric.dart';
import 'package:portfolio/auth/login.dart';
import 'package:portfolio/page/landing.dart';
import 'package:portfolio/utils/get_snack.dart';

class FirebaseLogin extends StatelessWidget {
  const FirebaseLogin({super.key, required this.useBiometric});
  final bool useBiometric;

  @override
  Widget build(context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          GetSnack.error(message: 'Authentication Error.');
        }

        if (snapshot.hasData) {
          if (useBiometric) {
            return const Biometric();
          } else {
            return const LandingScreen();
          }
        }

        return const LoginScreen();
      },
    );
  }
}
