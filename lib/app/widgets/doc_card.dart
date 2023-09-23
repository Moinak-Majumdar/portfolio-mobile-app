import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_delete.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_details.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_update.dart';
import 'package:moinak05_web_dev_dashboard/models/doc.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';

class DocCard extends ConsumerWidget {
  const DocCard({super.key, required this.data});

  final DocSchema data;

  @override
  Widget build(context, ref) {
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 200, 200, 200),
      foregroundColor: Colors.black,
    );
    final isUsingStorage = ref.read(storageProvider);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => DocDetails(docData: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color.fromARGB(255, 225, 225, 225),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isUsingStorage == StorageOptions.offline
                    ? FutureBuilder(
                        future: ref
                            .read(storageProvider.notifier)
                            .getStorageItemByUrl(url: data.cover),
                        builder: ((ctx, snap) {
                          if (snap.hasData) {
                            return Image.file(
                              snap.data!.image,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            );
                          }

                          return Image.asset(
                            'assets/image/docLoader.gif',
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          );
                        }),
                      )
                    : FadeInImage.assetNetwork(
                        placeholder: 'assets/image/docLoader.gif',
                        image: data.cover,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 16, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    data.name,
                    style: GoogleFonts.pacifico(fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => DocUpdate(docData: data),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    style: buttonStyle,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => DocDelete(docData: data),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    style: buttonStyle,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
