import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Loader extends StatelessWidget {
  const Loader({super.key, required this.splash});

  final String splash;

  @override
  Widget build(context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.black),
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Text(splash, style: GoogleFonts.pacifico(fontSize: 22)),
          )
        ],
      ),
    );
  }
}
