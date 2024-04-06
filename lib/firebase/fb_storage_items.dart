import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/fb_storage.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/neumorphism.dart';

class FbStorageItems extends StatelessWidget {
  const FbStorageItems({super.key, required this.root});

  final String root;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(root),
      ),
      body: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: fetchFbStorageItem(root),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data;

                return ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    final item = data[index];

                    return _ItemCard(item: item, root: root);
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
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.root});
  final FbStorageItemModel item;
  final String root;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
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

    return Obx(
      () {
        final alreadyExported = iec.alreadyExported(model);

        return NeuListTile(
          title: Text(item.imgName, style: textTheme.titleMedium),
          subtitle: Text(
            '${item.url.substring(81, 120)} ...',
            style: textTheme.bodySmall!.copyWith(
              color: Colors.white54,
            ),
          ),
          trailing: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.url,
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
          highlight: alreadyExported,
          onTap: alreadyExported
              ? null
              : () => showDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: Text(
                        model.name,
                        style: textTheme.titleLarge!
                            .copyWith(color: colorScheme.primary),
                        textAlign: TextAlign.start,
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Export url : ${model.url.substring(81, 120)} ...',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      actions: [
                        Obx(
                          () {
                            final iec = Get.put(ImportExportController());

                            return TextButton.icon(
                              onPressed: () {
                                iec.export(model);
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                FontAwesomeIcons.forward,
                                size: 18,
                              ),
                              label: const Text('Export'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
