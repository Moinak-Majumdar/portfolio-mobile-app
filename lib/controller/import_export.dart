import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ImportExport {
  const ImportExport.photography({
    required this.name,
    required this.url,
    this.projectName = 'photography',
  });

  const ImportExport.projectImage({
    required this.name,
    required this.projectName,
    required this.url,
  });

  final String name, url, projectName;
}

class ImportExportController extends GetxController {
  RxSet<ImportExport> photographyStorage = <ImportExport>{}.obs;
  RxSet<ImportExport> projectImgStorage = <ImportExport>{}.obs;
  RxString tailwindStorage = ''.obs;

  void export(ImportExport item) {
    if (!alreadyExported(item)) {
      if (item.projectName == 'photography') {
        photographyStorage.add(item);
      } else {
        projectImgStorage.add(item);
      }
    }
  }

  bool alreadyExported(ImportExport item) {
    final List<String> urls = [];
    if (item.projectName == 'photography') {
      for (final elm in photographyStorage) {
        urls.add(elm.url);
      }
    } else {
      for (final elm in projectImgStorage) {
        urls.add(elm.url);
      }
    }

    return urls.contains(item.url);
  }
}

void openExportedProjectImgCollection({
  required BuildContext context,
  required void Function(ImportExport item) onImport,
  ImportExport? selectedItem,
  bool pop = false,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 8),
      child: Obx(
        () {
          final iec = Get.put(ImportExportController());

          if (iec.projectImgStorage.isEmpty) {
            return const SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    FontAwesomeIcons.waveSquare,
                    size: 60,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 16),
                  Text('OOPS! Nothing to import.')
                ],
              ),
            );
          }

          return GridView.custom(
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 2,
              pattern: const [
                QuiltedGridTile(1, 2),
                QuiltedGridTile(1, 2),
              ],
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              childCount: iec.projectImgStorage.length,
              (context, index) {
                final currentItem = iec.projectImgStorage.elementAt(index);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      onImport(iec.projectImgStorage.elementAt(index));
                      if (pop) Navigator.pop(context);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: currentItem.url,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error_outline_rounded,
                            size: 32,
                            color: Colors.red,
                          ),
                          placeholder: (context, url) => const Icon(
                            Icons.photo,
                            size: 32,
                            color: Colors.white60,
                          ),
                        ),
                        if (selectedItem == currentItem)
                          Container(
                            clipBehavior: Clip.hardEdge,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black45,
                            ),
                            child: const Icon(
                              FontAwesomeIcons.upRightFromSquare,
                              color: Color.fromARGB(255, 202, 156, 239),
                              size: 40,
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}

void openExportedPhotographyCollection({
  required BuildContext context,
  required void Function(ImportExport item) onImport,
  bool pop = false,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 8),
      child: Obx(
        () {
          final iec = Get.put(ImportExportController());

          if (iec.photographyStorage.isEmpty) {
            return const SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    FontAwesomeIcons.waveSquare,
                    size: 60,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 16),
                  Text('OOPS! Nothing to import.')
                ],
              ),
            );
          }

          return GridView.custom(
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 2,
              pattern: const [
                QuiltedGridTile(2, 1),
                QuiltedGridTile(2, 1),
              ],
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              childCount: iec.photographyStorage.length,
              (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    onImport(iec.photographyStorage.elementAt(index));
                    if (pop) Navigator.pop(context);
                  },
                  child: CachedNetworkImage(
                    imageUrl: iec.photographyStorage.elementAt(index).url,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error_outline_rounded,
                      size: 32,
                      color: Colors.red,
                    ),
                    placeholder: (context, url) => const Icon(
                      Icons.photo,
                      size: 32,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
