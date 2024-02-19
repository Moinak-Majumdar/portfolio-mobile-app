import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/firebase/fb_storage.dart';
import 'package:portfolio/firebase/fb_upload.dart';
import 'package:portfolio/page/flutter/page.dart';
import 'package:portfolio/page/tailwind%20play/page.dart';
import 'package:portfolio/page/photography/page.dart';
import 'package:portfolio/page/project%20img/page.dart';
import 'package:portfolio/page/web/page.dart';
import 'package:url_launcher/url_launcher.dart';

const List<Map<String, dynamic>> navItems = [
  {
    "icon": Icon(
      FontAwesomeIcons.html5,
      size: 32,
      color: Colors.redAccent,
    ),
    "title": "Web projects",
    "page": Web(),
  },
  {
    "icon": FlutterLogo(),
    "title": "Flutter projects",
    "page": Flutter(),
  },
  {
    "icon": Icon(
      Icons.camera_alt_rounded,
      size: 32,
      color: Color.fromARGB(255, 212, 107, 238),
    ),
    "title": "Photography",
    "page": Photography(),
  },
  {
    "icon": FaIcon(
      FontAwesomeIcons.images,
      size: 32,
      color: Colors.deepOrangeAccent,
    ),
    "title": "Project Images",
    "page": ProjectImage(),
  },
  {
    "icon": FaIcon(
      FontAwesomeIcons.database,
      size: 30,
      color: Colors.amber,
    ),
    "title": "Firebase Storage",
    "page": FbStorage(),
  },
  {
    "icon": Icon(
      Icons.cloud_upload_rounded,
      size: 32,
      color: Colors.yellow,
    ),
    "title": "Firebase Upload",
    "page": FbUpload(),
  },
  {
    "icon": Icon(
      FontAwesomeIcons.code,
      size: 26,
      color: Colors.tealAccent,
    ),
    "title": "Tailwind Play",
    "page": TailwindPlay(),
  },
];

class LandingDrawer extends StatelessWidget {
  const LandingDrawer({super.key});

  Future<void> _launchUrl(String link) async {
    final url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception('Failed to launch $link');
    }
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade400,
                  Colors.pink[100]!,
                  Colors.purple[100]!,
                  Colors.grey.shade300,
                ],
              ),
            ),
            child: Center(
              child: DefaultTextStyle(
                style: GoogleFonts.pacifico(fontSize: 30, color: Colors.black),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TyperAnimatedText('Moinak05'),
                  ],
                ),
              ),
            ),
          ),
          for (final elm in navItems)
            ListTile(
              leading: elm['icon'],
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
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.link, size: 32),
            title: Text(
              'moinak05 - web',
              style: textTheme.titleLarge,
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
            leading: const Icon(Icons.update, size: 32),
            title: Text('Change Password', style: textTheme.titleLarge),
          ),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app_rounded,
              color: Color.fromARGB(255, 255, 76, 59),
              size: 32,
            ),
            tileColor: Colors.white12,
            title: const Text('Sign Out'),
            titleTextStyle: const TextStyle(
                color: Color.fromARGB(255, 255, 76, 59), fontSize: 22),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
