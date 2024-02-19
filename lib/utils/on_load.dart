import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnLoad extends StatelessWidget {
  const OnLoad({super.key, required this.msg});

  final String msg;

  @override
  Widget build(context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: DefaultTextStyle(
              style: GoogleFonts.pacifico(fontSize: 24),
              child: AnimatedTextKit(
                isRepeatingAnimation: false,
                animatedTexts: [
                  TyperAnimatedText(msg),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
