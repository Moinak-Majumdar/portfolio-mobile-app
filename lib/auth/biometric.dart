import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:portfolio/page/landing.dart';

class Biometric extends StatefulWidget {
  const Biometric({super.key});

  @override
  State<Biometric> createState() => _BiometricState();
}

class _BiometricState extends State<Biometric> {
  late final LocalAuthentication auth;

  bool _isBiometricSupported = false;

  @override
  void initState() {
    auth = LocalAuthentication();
    auth.isDeviceSupported().then((value) {
      setState(() {
        _isBiometricSupported = value;
      });
    });
    auth
        .authenticate(
      localizedReason: 'Please authenticate to use moinak05',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,
      ),
    )
        .then((value) {
      if (!value) {
        _onLocalAuthFailed();
      }
    }).catchError(
      (e) {
        _onLocalAuthFailed();
      },
    );
    super.initState();
  }

  @override
  Widget build(context) {
    return const LandingScreen();
  }

  void _onLocalAuthFailed() {
    showDialog(
      context: context,
      builder: (ctx) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          title: const Text(
            'Moinak05 is locked',
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _isBiometricSupported
                  ? 'Authentication is required to access Moinak05 portfolio dashboard app'
                  : 'This device is not supported biometric authentication (fingerprint, pin, pattern or face lock.). Please buy a new phone 😢😢',
              textAlign: TextAlign.start,
            ),
          ),
          actions: [
            if (_isBiometricSupported)
              TextButton.icon(
                onPressed: () async {
                  auth
                      .authenticate(
                    localizedReason: 'Please authenticate to use moinak05',
                    options: const AuthenticationOptions(
                      stickyAuth: true,
                      biometricOnly: false,
                    ),
                  )
                      .then(
                    (value) {
                      if (value) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
                icon: const Icon(Icons.lock_open),
                label: const Text('Unlock'),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
              )
            else
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.gavel),
                label: const Text('Force open'),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
              )
          ],
        ),
      ),
    );
  }
}
