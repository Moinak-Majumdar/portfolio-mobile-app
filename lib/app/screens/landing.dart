import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/music_player.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/settings.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/landing_drawer.dart';

import 'package:moinak05_web_dev_dashboard/provider/profile_img.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';

const List<String> quotes = [
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

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(context, ref) {
    final textTheme = Theme.of(context).textTheme;
    final random = (quotes.toList()..shuffle()).first;

    final profile = ref.watch(profileImgProvider);

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
      drawer: const SideDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome moinak05',
              style: GoogleFonts.pacifico(
                fontSize: 30,
                color: Colors.black,
              ),
            ),
            ClipOval(
              child: SizedBox.fromSize(
                size: const Size.fromRadius(200),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.saturation,
                  ),
                  child: FutureBuilder(
                    future: ref
                        .read(profileImgProvider.notifier)
                        .isProfileImgAvailable(),
                    builder: (ctx, snap) {
                      if (snap.hasData) {
                        final data = snap.data;
                        return data != null
                            ? Image.file(
                                data.image,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/image/me.jpg',
                                fit: BoxFit.cover,
                              );
                      }
                      if (profile != null) {
                        return Image.file(
                          profile.image,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Image.asset(
                          'assets/image/me.jpg',
                          fit: BoxFit.cover,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            DefaultTextStyle(
              style: GoogleFonts.caveat(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              child: AnimatedTextKit(
                isRepeatingAnimation: false,
                animatedTexts: [
                  TypewriterAnimatedText(
                    random,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future:
                  ref.read(storageProvider.notifier).isDataAvailableLocally(),
              builder: (ctx, snap) {
                if (snap.hasData) {
                  if (snap.data == false) {
                    return Text(
                      'App is set to online mode. To save bandwidth download data and turn on offline mode from settings.',
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    );
                  }
                }
                return const SizedBox(height: 0, width: 0);
              },
            )
          ],
        ),
      ),
    );
  }
}
