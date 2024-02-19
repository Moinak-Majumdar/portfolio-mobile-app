import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// used to generate splash screen and take screenshots.

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade600,
              Colors.pink[200]!,
              Colors.pink[100]!,
              Colors.grey.shade300,
              Colors.purple[100]!,
              Colors.purple[200]!,
              Colors.grey.shade600,
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(12, 16),
                spreadRadius: 5,
                blurRadius: 64,
              ),
              BoxShadow(
                color: Colors.white24,
                offset: Offset(-16, -16),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.houseLaptop,
                size: 64,
                color: Colors.purple,
              ),
              const SizedBox(height: 32),
              Text(
                "Welcome Back !",
                style: GoogleFonts.comicNeue(
                  color: Colors.black87,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
