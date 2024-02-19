import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/db.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/controller/project_img.dart';
import 'package:portfolio/models/project_img.dart';
import 'package:portfolio/page/project%20img/add_project_img.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/neumorphism.dart';

class ProjectImage extends StatelessWidget {
  const ProjectImage({super.key});

  @override
  Widget build(context) {
    final pic = Get.put(ProjectImageController());
    pic.resetFetchedItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Images'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProjectImage()),
            ),
            icon: const Icon(Icons.upload),
          ),
          Obx(
            () {
              if (pic.projectNames.isNotEmpty) {
                return PopupMenuButton(
                  initialValue: pic.projectNames[0],
                  itemBuilder: (context) {
                    return pic.projectNames
                        .map((element) => PopupMenuItem(
                              value: element,
                              child: Text(element),
                            ))
                        .toList();
                  },
                  onSelected: (e) {
                    pic.selectedProject.value = e;
                  },
                );
              }
              return const IconButton(
                onPressed: null,
                icon: Icon(Icons.more_vert),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Obx(
          () {
            if (pic.selectedProject.value != '') {
              final data = pic.allImages;
              final images = data[pic.selectedProject.value];

              return ListView.builder(
                itemCount: images!.length,
                itemBuilder: (context, index) {
                  final current = images[index];

                  return _ProjectImgCard(item: current);
                },
              );
            }

            final dbc = Get.put(DbController());

            return FutureBuilder(
              future: pic.fetchAllProjectImg(dbc.apiQueryParamBase()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'Please select a project from 3 dot menu.',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error.toString();

                  return OnError(error: error);
                }

                return const OnLoad(msg: 'Fetching all project images');
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProjectImgCard extends StatelessWidget {
  const _ProjectImgCard({required this.item});

  final ProjectImgModel item;

  @override
  Widget build(context) {
    return NeuBox(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      borderRadius: 16,
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: item.url,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Colors.red,
              ),
              placeholder: (context, url) => Image.asset(
                'assets/image/cloud.gif',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(item.imgName),
              Row(
                children: [
                  Obx(
                    () {
                      final iec = Get.put(ImportExportController());
                      final model = ImportExport.projectImage(
                        name: item.imgName,
                        url: item.url,
                        projectName: item.projectName,
                      );
                      final alreadyExported = iec.alreadyExported(model);

                      return IconButton(
                        onPressed:
                            alreadyExported ? null : () => iec.export(model),
                        icon: Icon(
                          alreadyExported
                              ? FontAwesomeIcons.checkDouble
                              : FontAwesomeIcons.forward,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 202, 156, 239),
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          disabledBackgroundColor: Colors.white12,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete),
                    iconSize: 32,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.red.withAlpha(40),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
