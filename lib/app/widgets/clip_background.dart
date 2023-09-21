import 'package:flutter/material.dart';

class ClipBackground extends StatelessWidget {
  const ClipBackground({super.key});

  @override
  Widget build(context) {
    final screen = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ClipPath(
            clipper: WaveTop(),
            child: Container(
              height: screen.height - 150,
              color: colorScheme.surface,
            ),
          ),
        ),
        ClipPath(
          clipper: WaveTop(),
          child: Container(
            height: 100,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class WaveTop extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    debugPrint(size.width.toString());
    final path = Path();
    path.lineTo(0, size.height);

    final firstStart = Offset(size.width / 5, size.height);

    final firstEnd = Offset(size.width / 2.25, size.height - 50.0);

    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    final secondStart =
        Offset(size.width - (size.width / 3.24), size.height - 105);

    final secondEnd = Offset(size.width, size.height - 10);

    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(
        size.width, 0); //end with this path if you are making wave at bottom
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
