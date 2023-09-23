import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/screens/photography_view.dart';
import 'package:moinak05_web_dev_dashboard/models/photography.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/loader.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/on_error.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/photography_uploader.dart';
import 'package:moinak05_web_dev_dashboard/provider/photography.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';

class PhotographyScreen extends ConsumerStatefulWidget {
  const PhotographyScreen({super.key});

  @override
  ConsumerState<PhotographyScreen> createState() => _PhotographyScreenState();
}

class _PhotographyScreenState extends ConsumerState<PhotographyScreen> {
  late Future<PhotographyServerSchema> _futurePhotography;
  PhotographyServerSchema? _photographyData;
  late StorageOptions _isUsingStorage;

  @override
  void initState() {
    _isUsingStorage = ref.read(storageProvider);
    _futurePhotography = ref.read(photographyProvider.notifier).fetch();
    super.initState();
  }

  @override
  Widget build(context) {
    _photographyData = ref.watch(photographyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Photography', style: GoogleFonts.pacifico()),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const PhotographyUploader(),
              );
            },
            icon: const Icon(
              Icons.file_upload_rounded,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _futurePhotography,
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return OnError(error: snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final data = _photographyData!.data;

            if (data.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'There is no photography to show.',
                    style: GoogleFonts.pacifico(),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: MasonryGridView.builder(
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => ViewPhotography(
                            path: _isUsingStorage == StorageOptions.offline
                                ? data[index].name
                                : data[index].url,
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _isUsingStorage == StorageOptions.offline
                            ? FutureBuilder(
                                future: ref
                                    .read(storageProvider.notifier)
                                    .getStorageItem(
                                      dir: 'photography',
                                      imgName: data[index].name,
                                    ),
                                builder: (ctx, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.file(
                                      snapshot.data!.image,
                                      fit: BoxFit.fill,
                                    );
                                  }
                                  return Image.asset(
                                    'assets/image/photography.gif',
                                    fit: BoxFit.fill,
                                  );
                                },
                              )
                            : FadeInImage.assetNetwork(
                                placeholder: 'assets/image/photography.gif',
                                image: data[index].url,
                                fit: BoxFit.fill,
                              ),
                      ),
                    );
                  },
                ),
              );
            }
          }
          return const Loader(splash: 'Getting photography ..');
        },
      ),
    );
  }
}
