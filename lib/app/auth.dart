import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/landing.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/login.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/splash.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(splash: 'Loading user data ..');
        }

        if (snapshot.hasError) {
          return const SplashScreen(splash: 'Authentication Error.');
        }

        if (snapshot.hasData) {
          return const LandingScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
