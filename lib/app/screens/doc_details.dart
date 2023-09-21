import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:moinak05_web_dev_dashboard/app/screens/doc_delete.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/doc_update.dart';

import 'package:moinak05_web_dev_dashboard/models/doc.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUrl(String link) async {
  final url = Uri.parse(link);
  if (!await launchUrl(url)) {
    throw Exception('Failed to launch $link');
  }
}

class DocDetails extends ConsumerWidget {
  const DocDetails({super.key, required this.docData});

  final DocSchema docData;

  @override
  Widget build(context, ref) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = GoogleFonts.pacifico(color: Colors.black, fontSize: 18);
    final isUsingStorage = ref.read(storageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          docData.name,
          style: GoogleFonts.pacifico(),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  'Update',
                  style: textTheme.titleMedium,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => DocUpdate(docData: docData),
                  ),
                ),
              ),
              PopupMenuItem(
                child: Text(
                  'Delete',
                  style: textTheme.titleMedium,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => DocDelete(docData: docData),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // hl3 cover.
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: isUsingStorage
                      ? FutureBuilder(
                          future: ref
                              .read(storageProvider.notifier)
                              .getStorageItemByUrl(url: docData.cover),
                          builder: (ctx, snapshot) {
                            if (snapshot.hasData) {
                              print(snapshot.data!.imgName);
                              return Image.file(
                                snapshot.data!.image,
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
                          })
                      : FadeInImage.assetNetwork(
                          placeholder: 'assets/image/docLoader.gif',
                          image: docData.cover,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
              // hl3 Intro.
              const SizedBox(height: 18),
              Text(
                docData.intro,
                style: textTheme.titleLarge,
              ),
              // hl3 status.
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: "Status : ",
                  style: titleStyle,
                  children: [
                    TextSpan(
                      text: docData.status,
                      style: textTheme.titleLarge!.copyWith(
                        color: docData.status == 'completed'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              //hl3 role .
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: "Role : ",
                  style: titleStyle,
                  children: [
                    TextSpan(
                      text: docData.role,
                      style: textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              // hl3 links.
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Links : ',
                    style: titleStyle,
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      _launchUrl(docData.gitRepo);
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('GitHub'),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      _launchUrl(docData.liveUrl);
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Live'),
                  ),
                ],
              ),
              // hl4  tools viewer.
              ToolsViewer(tools: docData.tools),
              const SizedBox(height: 20),
              // hl2  image slider.
              ImageSlider(
                images: docData.img,
              ),
              // hl5  description.
              const SizedBox(height: 16),
              Text(
                'Description :',
                style: titleStyle,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Html(
                  data: docData.description,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ToolsViewer extends StatelessWidget {
  const ToolsViewer({super.key, required this.tools});
  final List<String> tools;

  List<List<String>> toSubArr(Size size) {
    final toolsCounter = size.width < 450 ? 4 : 5;
    final List<List<String>> toolsManager = [];

    for (int i = 0; i < tools.length; i += toolsCounter) {
      toolsManager.add(
        tools.sublist(
          i,
          i + toolsCounter < tools.length ? i + toolsCounter : tools.length,
        ),
      );
    }
    return toolsManager;
  }

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Size size = MediaQuery.of(context).size;
    final subArray = toSubArr(size);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        for (final tool in subArray)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (final elm in tool)
                Container(
                  height: 100,
                  width: 74,
                  margin: EdgeInsets.symmetric(
                    horizontal: size.width < 450 ? 10 : 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(2, 3),
                        )
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/language/$elm.svg',
                        semanticsLabel: elm,
                        height: 50,
                        width: 50,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 6),
                      Text(elm, style: textTheme.bodyLarge)
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class ImageSlider extends ConsumerStatefulWidget {
  const ImageSlider({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  ConsumerState<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends ConsumerState<ImageSlider> {
  late bool _isUsingStorage;
  int _screenShotIndex = 1;
  final titleStyle = GoogleFonts.pacifico(color: Colors.black, fontSize: 18);

  @override
  void initState() {
    _isUsingStorage = ref.read(storageProvider);
    super.initState();
  }

  @override
  Widget build(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Text(
            "Screen Shots : $_screenShotIndex/${widget.images.length}",
            style: titleStyle,
          ),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 225,
            aspectRatio: 16 / 9,
            initialPage: 0,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _screenShotIndex = index + 1;
              });
            },
          ),
          items: widget.images.map(
            (e) {
              return Builder(
                builder: (ctx) => Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isUsingStorage
                      ? FutureBuilder(
                          future: ref
                              .read(storageProvider.notifier)
                              .getStorageItemByUrl(url: e),
                          builder: (ctx, snapshot) {
                            if (snapshot.hasData) {
                              return Image.file(
                                snapshot.data!.image,
                                fit: BoxFit.cover,
                              );
                            }
                            return Image.asset(
                              'assets/image/docLoader.gif',
                              fit: BoxFit.cover,
                            );
                          })
                      : FadeInImage.assetNetwork(
                          placeholder: 'assets/image/docLoader.gif',
                          image: e,
                          fit: BoxFit.cover,
                        ),
                ),
              );
            },
          ).toList(),
        )
      ],
    );
  }
}
