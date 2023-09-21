import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.splash});

  final String splash;

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.inversePrimary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.5,
                child: const CircularProgressIndicator(),
              ),
              const SizedBox(height: 48),
              Text(
                splash,
                style: Theme.of(context).textTheme.headlineMedium,
                softWrap: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
