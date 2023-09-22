import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const colorizeColors = [
  Colors.purple,
  Colors.blue,
  Colors.yellow,
  Colors.red,
];

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(context) {
    final colorizeTextStyle = GoogleFonts.monoton(fontSize: 50);

    return Center(
      child: AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(
            'AWESOME',
            textStyle: colorizeTextStyle,
            colors: colorizeColors,
            textAlign: TextAlign.center,
          ),
          ColorizeAnimatedText(
            'OPTIMISTIC',
            textStyle: colorizeTextStyle,
            colors: colorizeColors,
            textAlign: TextAlign.center,
          ),
          ColorizeAnimatedText(
            'DIFFERENT',
            textStyle: colorizeTextStyle,
            colors: colorizeColors,
            textAlign: TextAlign.center,
          ),
        ],
        repeatForever: true,
      ),
    );
  }
}
