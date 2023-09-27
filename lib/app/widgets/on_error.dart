import 'package:flutter/material.dart';

class OnError extends StatelessWidget {
  const OnError({super.key, required this.error});
  final String error;
  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error,
            size: 42,
            color: colorScheme.error,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32, left: 22, right: 22),
            child: Text(
              error,
              style: textTheme.titleLarge!.copyWith(
                color: colorScheme.error,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
