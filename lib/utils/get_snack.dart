import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GetSnack {
  GetSnack.normal({
    required this.message,
    required this.icon,
    required this.title,
    this.position = SnackPosition.TOP,
    this.color = const Color.fromARGB(255, 207, 170, 238),
  }) {
    _showSnackBar(
      message: message,
      icon: icon,
      title: title,
      color: color,
      position: position,
    );
  }

  GetSnack.success({
    required this.message,
    this.icon = Icons.done_all,
    this.title = "Success !",
    this.position = SnackPosition.TOP,
    this.color = const Color.fromARGB(255, 105, 240, 174),
  }) {
    _showSnackBar(
      message: message,
      icon: icon,
      title: title,
      color: color,
      position: position,
    );
  }

  GetSnack.error({
    required this.message,
    this.icon = Icons.error,
    this.title = "Error !",
    this.position = SnackPosition.TOP,
    this.color = const Color.fromARGB(255, 244, 67, 54),
  }) {
    _showSnackBar(
      message: message,
      icon: icon,
      title: title,
      color: color,
      position: position,
    );
  }

  final String title, message;
  final IconData icon;
  final SnackPosition position;
  final Color color;
}

void _showSnackBar({
  required String message,
  required IconData icon,
  required String title,
  required SnackPosition position,
  required Color color,
}) {
  Get.showSnackbar(
    GetSnackBar(
      titleText: Text(
        title,
        style: GoogleFonts.comicNeue(
          fontSize: 26,
          color: color,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
      duration: const Duration(seconds: 5),
      isDismissible: true,
      backgroundColor: const Color.fromARGB(255, 35, 35, 35),
      borderRadius: 16,
      snackPosition: position,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      icon: Icon(
        icon,
        size: 36,
        color: color,
      ),
      borderColor: color,
    ),
  );
}
