import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.onTap,
    required this.loading,
    required this.title,
    this.onLoadText,
    this.showDisable = false,
    this.leadingIcon,
    this.margin,
    this.borderRadius,
  });
  final void Function()? onTap;
  final bool loading;
  final String? onLoadText;
  final String title;
  final bool showDisable;
  final IconData? leadingIcon;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            if (showDisable) ...[
              Colors.black26,
              Colors.black38,
              Colors.black26,
            ] else ...[
              Colors.purple[300]!,
              Colors.purple[200]!,
              Colors.purple[300]!,
            ]
          ],
        ),
        borderRadius: borderRadius,
      ),
      child: MaterialButton(
        onPressed: loading ? null : onTap,
        height: double.infinity,
        child: loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onLoadText != null) ...[
                    Text(
                      onLoadText!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                  Transform.scale(
                    scale: 0.6,
                    child:
                        const CircularProgressIndicator(color: Colors.white60),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(
                      leadingIcon!,
                      color: showDisable ? Colors.white24 : Colors.white,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: showDisable ? Colors.white24 : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
