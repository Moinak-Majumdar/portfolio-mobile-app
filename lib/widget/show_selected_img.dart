import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/controller/import_export.dart';

class ShowSelectedImg extends StatelessWidget {
  const ShowSelectedImg(
      {super.key, required this.selectedItem, this.height = 250});
  final ImportExport? selectedItem;
  final double height;

  @override
  Widget build(context) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: height,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black26, Colors.black38, Colors.black26],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: selectedItem != null
          ? Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: selectedItem!.url,
                  width: double.infinity,
                  height: height,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: Colors.red,
                  ),
                ),
                if (selectedItem != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Text(
                        selectedItem!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: Icon(
                Icons.photo,
                size: 45,
                color: Colors.white24,
              ),
            ),
    );
  }
}
