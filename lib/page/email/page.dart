import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/neumorphism.dart';
import 'package:url_launcher/url_launcher.dart';

class Email extends StatefulWidget {
  const Email({super.key});

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  final dbStream = FirebaseFirestore.instance
      .collection('Email')
      .orderBy('time', descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
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

                        return GestureDetector(
                          onTap: () async {
                            await _launchUrl(data["email"], data['sub']);
                          },
                          child: NeuBox(
                            margin: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${data["name"]}  <${data["email"]}>',
                                  style: GoogleFonts.montserrat().copyWith(
                                    color: Colors.grey.shade300,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  dateTime,
                                  style: GoogleFonts.montserrat(),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  data['subject'],
                                  style: GoogleFonts.lato().copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['message'],
                                  style: GoogleFonts.lato().copyWith(
                                    color: Colors.grey.shade200,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  );
                }

                return const OnLoad(msg: 'Fetching email ...');
              }),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String email, String subject) async {
    final mail = Uri.encodeComponent(email);
    final sub = Uri.encodeComponent(subject);
    final url = Uri.parse("mailto:$mail?subject=$sub");
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
