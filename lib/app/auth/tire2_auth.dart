import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/landing.dart';

import 'package:local_auth/local_auth.dart';

class Tire2Auth extends ConsumerStatefulWidget {
  const Tire2Auth({super.key});

  @override
  ConsumerState<Tire2Auth> createState() => _Tire2AuthState();
}

class _Tire2AuthState extends ConsumerState<Tire2Auth> {
  late final LocalAuthentication auth;

  bool _isLocalAuthSupported = false;

  @override
  void initState() {
    auth = LocalAuthentication();
    auth.isDeviceSupported().then((value) {
      setState(() {
        _isLocalAuthSupported = value;
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
        .then(
      (value) {
        if (!value) {
          _onLocalAuthFailed();
        }
      },
    ).catchError(
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

  Future<void> _localReAuthenticate() async {
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
              _isLocalAuthSupported
                  ? 'Authentication is required to access Moinak05 app'
                  : 'This device is not supported biometric authentication (fingerprint, pin, pattern or face lock.). Please buy a new phone 😢😢',
              textAlign: TextAlign.start,
            ),
          ),
          actions: [
            if (_isLocalAuthSupported)
              TextButton.icon(
                onPressed: _isLocalAuthSupported ? _localReAuthenticate : null,
                icon: const Icon(Icons.lock_open),
                label: const Text('Unlock'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
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
                  backgroundColor: Colors.black,
                  foregroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
              )
          ],
        ),
      ),
    );
  }
}
