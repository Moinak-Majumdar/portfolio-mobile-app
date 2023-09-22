import 'package:flutter/material.dart';

class AuthError extends StatelessWidget {
  const AuthError({super.key, required this.splash});

  final String splash;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
                style: Theme.of(context).textTheme.headlineSmall,
                softWrap: true,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
