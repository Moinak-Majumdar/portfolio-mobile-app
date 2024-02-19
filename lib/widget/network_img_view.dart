import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImgView extends StatelessWidget {
  const NetworkImgView({
    super.key,
    required this.url,
    this.height,
    this.borderRadius,
    this.padding,
  });
  final String url;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(context) {
    return Container(
      padding: padding,
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorWidget: (context, url, error) => const Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: Colors.red,
          ),
          placeholder: (context, url) => Image.asset(
            'assets/image/cloud.gif',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
