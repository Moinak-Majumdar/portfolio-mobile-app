import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moinak05_web_dev_dashboard/app/utils/smack_msg.dart';

import 'package:moinak05_web_dev_dashboard/provider/storage.dart';
import 'package:path_provider/path_provider.dart';

class ReDownloadMissingImage extends ConsumerWidget {
  const ReDownloadMissingImage(
      {super.key, required this.imgName, required this.url});

  final String url, imgName;

  @override
  Widget build(context, ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void showSmack() {
      SmackMsg(
        smack: '$imgName is downloaded successfully.',
        context: context,
        willCloseScreen: true,
      );
    }

    Future<void> handelDownload() async {
      final imgRef = FirebaseStorage.instance.refFromURL(url);
      final details = imgRef.fullPath.split('/');
      final imgName = details[1];
      final imgDir = details[0];
      final appDir = await getApplicationDocumentsDirectory();
      final workDir = Directory('${appDir.path}/storage');
      String workDirPath;

      if (await workDir.exists()) {
        workDirPath = workDir.path;
      } else {
        final newFolder = await workDir.create(recursive: true);
        workDirPath = newFolder.path;
      }

      final filePath = '$workDirPath/${imgRef.fullPath}';
      final file = await File(filePath).create(recursive: true);

      final downloadTask = imgRef.writeToFile(file);
      downloadTask.snapshotEvents.listen(
        (taskSnapshot) {
          switch (taskSnapshot.state) {
            case TaskState.running:
              break;
            case TaskState.paused:
              break;
            case TaskState.success:
              break;
            case TaskState.canceled:
              break;
            case TaskState.error:
              break;
          }
        },
      );

      await ref.read(storageProvider.notifier).explicitlyAddItem(
            imgName: imgName,
            dir: imgDir,
            image: file,
            url: url,
          );
      showSmack();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$imgName is missing from local storage. Consider re downloading..',
            style: textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) => Image.asset(
                  'assets/image/cloud.gif',
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    'Something went wrong..',
                    style: textTheme.titleMedium,
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: handelDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorScheme.secondaryContainer,
                  backgroundColor: Colors.black,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
