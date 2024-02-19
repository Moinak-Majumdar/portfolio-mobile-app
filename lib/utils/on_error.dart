import 'package:flutter/material.dart';

class OnError extends StatelessWidget {
  const OnError({
    super.key,
    required this.error,
    this.onReset,
    this.maxHeight = 300,
    this.showIcon = true,
  });
  final String error;
  final double maxHeight;
  final bool showIcon;
  final void Function()? onReset;

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon)
            Icon(
              Icons.error,
              size: 42,
              color: colorScheme.error,
            ),
          Container(
            margin: const EdgeInsets.only(top: 24, left: 14, right: 14),
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              minWidth: double.infinity,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(50, 255, 50, 50),
                  Color.fromARGB(40, 255, 50, 50),
                  Color.fromARGB(50, 255, 50, 50),
                ],
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Text(
                  error,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
          if (onReset != null) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Reset'),
            ),
          ]
        ],
      ),
    );
  }
}
