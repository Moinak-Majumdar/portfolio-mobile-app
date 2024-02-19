import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/fb_storage.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';

class FbStorageItems extends StatelessWidget {
  const FbStorageItems({super.key, required this.root});

  final String root;

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(root),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: fetchFbStorageItem(root),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data;

              return ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  final currentItem = data[index];

                  return ListTile(
                    title:
                        Text(currentItem.imgName, style: textTheme.titleMedium),
                    subtitle: Text(
                      '${currentItem.url.substring(81, 120)} ...',
                      style: textTheme.bodySmall!.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    trailing: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: currentItem.url,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error_outline_rounded,
                          size: 32,
                          color: Colors.red,
                        ),
                        placeholder: (context, url) => const Icon(
                          Icons.loop,
                          size: 32,
                          color: Colors.white12,
                        ),
                      ),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => exportDialog(
                        item: currentItem,
                        root: root,
                        textTheme: textTheme,
                        colorScheme: colorScheme,
                      ),
                    ),
                  );
                },
              );
            }

            if (snapshot.hasError) {
              final error = snapshot.error.toString();

              return OnError(error: error);
            }

            return OnLoad(msg: 'Fetching $root ...');
          },
        ),
      ),
    );
  }
}

Widget exportDialog({
  required FbStorageItemModel item,
  required String root,
  required TextTheme textTheme,
  required ColorScheme colorScheme,
}) {
  return AlertDialog(
    title: Text(
      item.imgName,
      style: textTheme.headlineSmall!.copyWith(color: colorScheme.primary),
    ),
    content: Text(
      'Export url : ${item.url.substring(81, 120)} ...',
      style: const TextStyle(color: Colors.white70),
    ),
    actions: [
      Obx(
        () {
          final iec = Get.put(ImportExportController());

          final model = root == 'photography'
              ? ImportExport.photography(
                  name: item.imgName,
                  url: item.url,
                )
              : ImportExport.projectImage(
                  name: item.imgName,
                  url: item.url,
                  projectName: item.projectName,
                );
          final alreadyExported = iec.alreadyExported(model);

          return ElevatedButton.icon(
            onPressed: alreadyExported ? null : () => iec.export(model),
            icon: alreadyExported
                ? const Icon(Icons.done_all)
                : const Icon(
                    FontAwesomeIcons.forward,
                    size: 18,
                  ),
            label: const Text('Export'),
          );
        },
      ),
    ],
  );
}
