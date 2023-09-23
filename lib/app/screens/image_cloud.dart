import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/models/cloud.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/cloud_img_card.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/cloud_image_uploader.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/loader.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/on_error.dart';
import 'package:moinak05_web_dev_dashboard/provider/cloud.dart';

class ImageCloud extends ConsumerStatefulWidget {
  const ImageCloud({super.key});

  @override
  ConsumerState<ImageCloud> createState() => _ImageCloudState();
}

class _ImageCloudState extends ConsumerState<ImageCloud> {
  late Future<CloudSchema> _futureCloud;
  CloudSchema? _cloudData;
  String _selectedProject = 'dummy';

  @override
  void initState() {
    super.initState();
    _futureCloud = ref.read(cloudProvider.notifier).fetch();
    _selectedProject = 'dummy';
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    _cloudData = ref.watch(cloudProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Cloud',
          style: GoogleFonts.pacifico(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const ImageUploader(),
              );
            },
            icon: const Icon(
              Icons.file_upload_rounded,
            ),
          ),
          if (_cloudData != null)
            PopupMenuButton(
              initialValue: _selectedProject,
              itemBuilder: (context) {
                return _cloudData!.projectNames
                    .map((e) => PopupMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: textTheme.titleLarge,
                          ),
                        ))
                    .toList();
              },
              onSelected: (e) {
                setState(() {
                  _selectedProject = e;
                });
              },
            )
        ],
      ),
      body: FutureBuilder(
        future: _futureCloud,
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return OnError(error: snapshot.error.toString());
          }
          if (snapshot.hasData) {
            if (_selectedProject == 'dummy') {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Please select an option from 3 dot menu.',
                    style: GoogleFonts.pacifico(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              final images = _cloudData!.images[_selectedProject];
              if (images != null) {
                return ListView.builder(
                  itemCount: images.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemBuilder: (ctx, index) {
                    return CloudImgCard(details: images[index]);
                  },
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '$_selectedProject has no images to show, Select another option.',
                      style: GoogleFonts.pacifico(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            }
          }
          return const Loader(splash: 'Getting cloud ..');
        },
      ),
    );
  }
}
