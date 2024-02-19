import 'package:flutter/material.dart';

class TitledText extends StatelessWidget {
  const TitledText({
    super.key,
    required this.title,
    this.titleSize = 18,
    required this.children,
  });
  final String title;
  final double titleSize;
  final List<InlineSpan> children;

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        text: "$title : ",
        style: TextStyle(
          fontSize: titleSize,
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        children: children,
      ),
    );
  }
}
