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
                      print(data);
                      final time = data['time'] is Timestamp
                          ? formatTimestamp(data['time'])
                          : data['time'];

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
                                      fontWeight: FontWeight.bold,
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: data['email'],
                                  )
                                ],
                              ),
                            ),
                            Text(
                              time,
                              style: textTheme.titleSmall!.copyWith(
                                color: colorScheme.primary,
                              ),
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

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String getOrdinalSuffix(int day) {
      if (day >= 11 && day <= 13) return "th";
      switch (day % 10) {
        case 1:
          return "st";
        case 2:
          return "nd";
        case 3:
          return "rd";
        default:
          return "th";
      }
    }

    const List<String> months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];

    String dayWithSuffix = "${dateTime.day}${getOrdinalSuffix(dateTime.day)}";
    String month = months[dateTime.month - 1];
    String year = dateTime.year.toString();
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? "PM" : "AM";

    return "$dayWithSuffix $month, $year - $hour:$minute $period";
  }
}
