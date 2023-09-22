import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moinak05_web_dev_dashboard/app/auth/tire2_auth.dart';
import 'package:moinak05_web_dev_dashboard/app/auth/online_login.dart';
import 'package:moinak05_web_dev_dashboard/app/auth/auth_error.dart';

class OnlineAuth extends StatelessWidget {
  const OnlineAuth({super.key});

  @override
  Widget build(context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AuthError(splash: 'Loading user data ..');
        }

        if (snapshot.hasError) {
          return const AuthError(splash: 'Authentication Error.');
        }

        if (snapshot.hasData) {
          return const Tire2Auth();
        }

        return const OnlineLoginScreen();
      },
    );
  }
}
