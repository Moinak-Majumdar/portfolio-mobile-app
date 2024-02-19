import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/controller/db.dart';
import 'package:portfolio/controller/profile_img.dart';

import 'package:portfolio/page/music/page.dart';
import 'package:portfolio/page/settings.dart';
import 'package:portfolio/widget/landing_drawer.dart';
import 'package:portfolio/widget/neumorphism.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final String randomQuot = (_quotes.toList()..shuffle()).first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.pacifico()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const MusicPlayer()),
              );
            },
            icon: const Icon(Icons.music_note),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const Settings()),
              );
            },
            icon: const Icon(Icons.settings_sharp),
          ),
        ],
      ),
      drawer: const LandingDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome moinak05',
                style: GoogleFonts.pacifico(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              NeuBox(
                padding: const EdgeInsets.all(8),
                borderRadius: 200,
                child: ClipOval(
                  child: SizedBox.fromSize(
                    size: const Size.fromRadius(160),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.saturation,
                      ),
                      child: Obx(
                        () {
                          final pic = Get.put(ProfileImgController());

                          return pic.isProfileImgAvailable.value
                              ? Image.file(
                                  File(pic.profileImgPath.value),
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/image/me.jpg',
                                  fit: BoxFit.cover,
                                );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              DefaultTextStyle(
                style: GoogleFonts.caveat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      randomQuot,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Obx(
                () {
                  final dc = Get.put(DbController());

                  return Text(
                    'App is currently using ${dc.isUsingTestDb.value ? '`Test`' : '`Production`'} database.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

const List<String> _quotes = [
  "Genius is one percent inspiration and ninety-nine percent perspiration.",
  "You can observe a lot just by watching.",
  "A house divided against itself cannot stand.",
  "Difficulties increase the nearer we get to the goal.",
  "Fate is in your hands and no one elses",
  "Be the chief but never the lord.",
  "Nothing happens unless first we dream.",
  "Well begun is half done.",
  "Life is a learning experience, only if you learn.",
  "Self-complacency is fatal to progress.",
  "Peace comes from within. Do not seek it without.",
  "What you give is what you get.",
  "We can only learn to love by loving.",
  "Life is change. Growth is optional. Choose wisely.",
  "You'll see it when you believe it.",
  "Today is the tomorrow we worried about yesterday.",
];
