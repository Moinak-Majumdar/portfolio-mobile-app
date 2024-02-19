import 'package:flutter/material.dart';

class NeuBox extends StatelessWidget {
  const NeuBox({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(context) {
    return Container(
      padding: padding,
      margin: margin,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        color: Colors.grey.shade900,
        boxShadow: [
          const BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Colors.grey.shade800,
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeuBoxDark extends StatelessWidget {
  const NeuBoxDark({
    super.key,
    required this.child,
    this.borderRadius = 8,
    this.width = double.infinity,
    this.padding = const EdgeInsets.all(8),
    this.margin = const EdgeInsets.all(12),
    this.constraints,
  });
  final Widget child;
  final double borderRadius, width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;

  @override
  Widget build(context) {
    return NeuBox(
      margin: margin,
      padding: const EdgeInsets.all(6),
      borderRadius: borderRadius,
      child: Container(
        clipBehavior: Clip.hardEdge,
        width: constraints == null ? width : null,
        constraints: constraints,
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black26,
              Colors.black38,
              Colors.black26,
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius / 1.5),
        ),
        child: child,
      ),
    );
  }
}

class NeuListTile extends StatelessWidget {
  const NeuListTile({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final Widget? title, subtitle, leading, trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return NeuBox(
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: ListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
