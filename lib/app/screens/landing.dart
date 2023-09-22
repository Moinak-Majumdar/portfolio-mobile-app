import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/auth/online_auth.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/add_doc.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/html_play.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/image_cloud.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/music_player.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/photography.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/all_doc.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/settings.dart';

import 'package:moinak05_web_dev_dashboard/provider/profile_img.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';
import 'package:url_launcher/url_launcher.dart';

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
const List<Map<String, dynamic>> navItems = [
  {
    "icon": Icons.format_list_numbered_rounded,
    "title": "All Doc",
    "page": AllDocScreen(),
  },
  {
    "icon": Icons.plus_one,
    "title": "Add New Doc",
    "page": AddDoc(),
  },
  {
    "icon": Icons.linked_camera_rounded,
    "title": "Photography",
    "page": PhotographyScreen(),
  },
  {
    "icon": Icons.cloud_upload_rounded,
    "title": "Image Cloud",
    "page": ImageCloud(),
  },
  {
    "icon": Icons.code,
    "title": "HTML Play",
    "page": HtmlPlayground(),
  },
];

Future<void> _launchUrl(String link) async {
  final url = Uri.parse(link);
  if (!await launchUrl(url)) {
    throw Exception('Failed to launch $link');
  }
}

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(context, ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final random = (quotes.toList()..shuffle()).first;

    final profile = ref.watch(profileImgProvider);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
        drawer: Drawer(
          backgroundColor: colorScheme.background,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              DrawerHeader(
                child: Center(
                  child: DefaultTextStyle(
                    style: GoogleFonts.pacifico(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                    child: AnimatedTextKit(
                      isRepeatingAnimation: false,
                      animatedTexts: [
                        TyperAnimatedText('Navigation'),
                      ],
                    ),
                  ),
                ),
              ),
              for (final elm in navItems)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ListTile(
                    leading: Icon(
                      elm['icon'],
                      size: 32,
                      color: Colors.black,
                    ),
                    title: Text(
                      elm['title'],
                      style: textTheme.titleLarge,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => elm['page']),
                        ),
                      );
                    },
                  ),
                ),
              const Spacer(),
              ListTile(
                leading: Icon(
                  Icons.link,
                  color: colorScheme.secondary,
                  size: 32,
                ),
                title: Text(
                  'moinak05 - web',
                  style: textTheme.titleLarge!.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
                onTap: () {
                  _launchUrl('https://moinak05.vercel.app');
                },
              ),
              ListTile(
                onTap: () {
                  final auth = FirebaseAuth.instance;
                  auth
                      .sendPasswordResetEmail(
                    email: auth.currentUser!.email!,
                  )
                      .then(
                    (value) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'Password reset link sent to ${auth.currentUser!.email}',
                            style: textTheme.titleLarge,
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: colorScheme.secondaryContainer,
                              ),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                leading: Icon(
                  Icons.update,
                  color: colorScheme.secondary,
                  size: 32,
                ),
                title: Text(
                  'Change Password',
                  style: textTheme.titleLarge!.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app_rounded,
                  color: colorScheme.error,
                  size: 32,
                ),
                tileColor: colorScheme.errorContainer,
                title: const Text('Sign Out'),
                titleTextStyle:
                    TextStyle(color: colorScheme.error, fontSize: 22),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const OnlineAuth(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(360),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.saturation,
                    ),
                    child: FutureBuilder(
                      future:
                          ref.read(profileImgProvider.notifier).getInitial(),
                      builder: (ctx, snap) {
                        if (snap.hasData) {
                          final data = snap.data;
                          return data != null
                              ? Image.file(
                                  data.image,
                                  height: 460,
                                  width: 460,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/image/me.jpg',
                                  fit: BoxFit.cover,
                                );
                        }
                        if (snap.hasError) {
                          return Image.asset(
                            'assets/image/me.jpg',
                            fit: BoxFit.cover,
                          );
                        }
                        return Image.file(
                          profile!.image,
                          height: 460,
                          width: 460,
                          fit: BoxFit.cover,
                        );
                      },
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
                  future: ref.read(storageProvider.notifier).isDataAtStorage(),
                  builder: (ctx, snap) {
                    if (snap.hasData) {
                      if (snap.data == false) {
                        return Text(
                          'Images will not be rendered as data is not available. Disable offline mode in settings or download data.',
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
        ),
      ),
    );
  }
}
