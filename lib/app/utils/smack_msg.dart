import 'package:flutter/material.dart';

class SmackMsg {
  SmackMsg({
    required this.smack,
    required this.context,
    this.willCloseScreen = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    if (willCloseScreen) {
      Navigator.of(context).pop();
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.all(16),
        content: Text(
          smack,
          style: textTheme.titleMedium!.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  final String smack;
  final bool willCloseScreen;
  final BuildContext context;
}
