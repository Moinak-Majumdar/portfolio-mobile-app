import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/auth/online_auth.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/add_doc.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/all_doc.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/html_play.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/image_cloud.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/photography.dart';
import 'package:url_launcher/url_launcher.dart';

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

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

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
            titleTextStyle: TextStyle(color: colorScheme.error, fontSize: 22),
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
    );
  }
}
