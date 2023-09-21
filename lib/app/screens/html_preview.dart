import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/provider/html.dart';

class HtmlPreview extends ConsumerWidget {
  const HtmlPreview({super.key, required this.body});
  final String body;

  @override
  Widget build(context, ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void exportData() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: const Text(
              'Html export is done, ready to used in new doc addition or doc updation.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                ref.read(htmlProvider.notifier).exportHtml(body);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.primaryContainer,
              ),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Html Preview",
          style: GoogleFonts.pacifico(fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Html(
                data: body,
                style: {
                  "*": Style(
                      color: const Color.fromARGB(255, 23, 25, 27),
                      fontSize: FontSize(14)),
                  "b": Style(
                    fontWeight: FontWeight.w800,
                    fontSize: FontSize(16),
                  ),
                  "i": Style(
                    fontSize: FontSize(16),
                  ),
                  "em": Style(
                    fontSize: FontSize(16),
                  ),
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: exportData,
                  icon: const Icon(Icons.import_export),
                  label: Text(
                    'Export Html',
                    style: textTheme.titleMedium!.copyWith(
                      color: colorScheme.primaryContainer,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(width: 8)
              ],
            )
          ],
        ),
      ),
    );
  }
}
