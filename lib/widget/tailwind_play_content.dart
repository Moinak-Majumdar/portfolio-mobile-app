import 'package:flutter/material.dart';
import 'package:portfolio/widget/neumorphism.dart';

class TailwindPlayContent extends StatelessWidget {
  const TailwindPlayContent({super.key, required this.content});
  final String content;

  @override
  Widget build(context) {
    return NeuBoxDark(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      borderRadius: 24,
      constraints: const BoxConstraints(
        maxHeight: 300,
        minWidth: double.infinity,
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
