import 'package:flutter/material.dart';

enum BackgroundShape {
  wave,
  oval,
}

class Background extends StatefulWidget {
  const Background({
    super.key,
    required this.shape,
    required this.style,
    this.topHeight = 120,
    this.bottomHeigh = 150,
  });

  final BackgroundShape shape;
  final Gradient style;
  final double topHeight, bottomHeigh;
  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  late CustomClipper<Path> clipper;

  @override
  void initState() {
    setState(() {
      switch (widget.shape) {
        case BackgroundShape.wave:
          clipper = WaveTop();
          break;
        case BackgroundShape.oval:
          clipper = Oval();
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(context) {
    final screen = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ClipPath(
            clipper: clipper,
            child: Container(
              height: screen.height - widget.bottomHeigh,
              color: colorScheme.surface,
            ),
          ),
        ),
        ClipPath(
          clipper: clipper,
          child: Container(
            height: widget.topHeight,
            decoration: BoxDecoration(
              gradient: widget.style,
            ),
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

class Oval extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
