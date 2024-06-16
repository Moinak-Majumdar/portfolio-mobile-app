import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:url_launcher/url_launcher.dart';

class Email extends StatelessWidget {
  const Email({super.key});

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final dbStream = FirebaseFirestore.instance
        .collection('Email')
        .orderBy('time', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text("Client Messages")),
      body: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: dbStream,
            builder: (ctx, snapShot) {
              if (snapShot.hasError) {
                return OnError(error: snapShot.error.toString());
              }

              if (snapShot.hasData) {
                return ListView(
                  children: snapShot.data!.docs.map(
                    (DocumentSnapshot doc) {
                      final data = doc.data()! as Map<String, dynamic>;
                      final dateTime = getVisibleDate(data['time']);

                      return NeuBox(
                        margin: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: textTheme.titleMedium,
                                children: [
                                  TextSpan(
                                    text: 'Name: ',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: data['name'],
                                  )
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: textTheme.titleMedium,
                                children: [
                                  TextSpan(
                                    text: 'From: ',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: data['email'],
                                  )
                                ],
                              ),
                            ),
                            Text(
                              dateTime,
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data['subject'],
                              style: textTheme.titleMedium!.copyWith(
                                color: Colors.pink.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['message'],
                              style: textTheme.bodyMedium,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await _launchUrl(
                                      data['email'],
                                      data['name'],
                                    );
                                  },
                                  icon: Icon(
                                    Icons.reply,
                                    color: Colors.grey.shade900,
                                  ),
                                  label: Text(
                                    "Reply",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ).toList(),
                );
              }

              return const OnLoad(msg: 'Fetching email ...');
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String email, String name) async {
    final mail = Uri.encodeComponent(email);
    final sub = Uri.encodeComponent("Thanks for reaching me");
    final body = 'Hey $name,\n\n I am Moinak Majumdar, creator of';
    final url = Uri.parse("mailto:$mail?subject=$sub&body=$body");
    await launchUrl(url);
  }

  String getVisibleDate(Timestamp timeStamp) {
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final d = timeStamp.toDate();
    final t = TimeOfDay.fromDateTime(d);
    final time =
        "${t.hourOfPeriod}:${t.minute}${t.hourOfPeriod >= 12 ? 'PM' : 'AM'}";
    final date = "${d.day}, ${months[d.month]} ${d.year}";

    return "$date : $time";
  }
}
