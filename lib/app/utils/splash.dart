// hl5 design splash screen and take screenshot.

import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // Colors.white,
              Color.fromARGB(255, 36, 36, 62),
              Color.fromARGB(255, 48, 43, 99),
              Color.fromARGB(255, 15, 12, 41),
            ],
          ),
        ),
        child: Center(
          child: Image.asset('assets/icon/foreground.png'),
        ),
      ),
    );
  }
}
