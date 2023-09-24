import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/provider/doc_img.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';

class ImgImporter extends ConsumerWidget {
  const ImgImporter({
    super.key,
    required this.onTap,
    required this.selectedUrl,
    this.disabled = false,
  });

  final void Function(String) onTap;
  final String selectedUrl;
  final bool disabled;

  @override
  Widget build(context, ref) {
    final colorScheme = Theme.of(context).colorScheme;

    List<ExportedImgSchema> options = ref.read(imgProvider);
    final isUsingStorage = ref.read(storageProvider);

    void importImg() {
      showModalBottomSheet(
        useSafeArea: true,
        backgroundColor: colorScheme.onPrimary,
        context: context,
        builder: (ctx) {
          if (options.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (ctx, i) => InkWell(
                  onTap: () {
                    onTap(options[i].url);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        Center(
                          child: isUsingStorage == StorageOptions.offline
                              ? FutureBuilder(
                                  future: ref
                                      .read(storageProvider.notifier)
                                      .getStorageItem(
                                        dir: options[i].projectName,
                                        imgName: options[i].imgName,
                                      ),
                                  builder: (ctx, snap) {
                                    if (snap.hasData) {
                                      return Image.file(
                                        snap.data!.image,
                                        fit: BoxFit.fill,
                                        height: 250,
                                        width: double.infinity,
                                      );
                                    }

                                    return Image.asset(
                                      'assets/image/cloud.gif',
                                      fit: BoxFit.fill,
                                      height: 250,
                                      width: double.infinity,
                                    );
                                  },
                                )
                              : CachedNetworkImage(
                                  imageUrl: options[i].url,
                                  placeholder: (context, url) =>
                                      Image.asset('assets/image/cloud.gif'),
                                  fit: BoxFit.fill,
                                  height: 250,
                                  width: double.infinity,
                                  errorWidget: (context, url, error) =>
                                      Text('Failed to load image !'),
                                ),
                        ),
                        if (options[i].url == selectedUrl)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.blueGrey,
                              size: 65,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Icon(
                Icons.question_mark,
                color: Colors.blueGrey,
                size: 64,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
                child: Text(
                  'No image to import, Please export some from Image Cloud.',
                  style: GoogleFonts.pacifico().copyWith(
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          );
        },
      );
    }

    return IconButton(
      onPressed: disabled ? null : importImg,
      icon: const Icon(
        Icons.import_export,
      ),
      style: IconButton.styleFrom(
          backgroundColor: colorScheme.surfaceVariant, elevation: 5),
    );
  }
}
