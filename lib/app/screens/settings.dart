import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moinak05_web_dev_dashboard/app/widgets/change_profile.dart';
import 'package:moinak05_web_dev_dashboard/provider/cloud.dart';
import 'package:moinak05_web_dev_dashboard/provider/music.dart';
import 'package:moinak05_web_dev_dashboard/provider/photography.dart';
import 'package:moinak05_web_dev_dashboard/provider/storage.dart';
import 'package:path_provider/path_provider.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  late bool _isStorage;

  bool _isDownloading = false;
  bool _isClearing = false;

  @override
  void initState() {
    _isStorage =
        ref.read(storageProvider) == StorageOptions.offline ? true : false;
    super.initState();
  }

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        if (_isDownloading || _isClearing) {
          await leaveAlert();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Settings',
            style: GoogleFonts.pacifico(fontSize: 22),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const ChangeProfile(),
                  );
                },
                title: Text(
                  'Change Profile',
                  style: textTheme.titleLarge,
                ),
                trailing: const Icon(
                  Icons.account_circle_rounded,
                  size: 26,
                ),
                subtitle: Text(
                  'Change home screen image',
                  style: textTheme.bodySmall,
                ),
              ),
              SwitchListTile(
                value: ref.watch(audioPlayerAutoStartupProvider),
                onChanged: (value) async {
                  await ref
                      .read(audioPlayerAutoStartupProvider.notifier)
                      .changeStartupState(value);
                },
                title: Text(
                  'Startup Audio',
                  style: textTheme.titleLarge,
                ),
                subtitle: Text(
                  'Play music automatically when the app start.',
                  style: textTheme.bodySmall,
                ),
                thumbIcon: _thumb,
              ),
              CheckboxListTile(
                value: _isStorage,
                onChanged: (val) {
                  if (val != null) {
                    ref.read(storageProvider.notifier).storageSetting(
                          val ? StorageOptions.offline : StorageOptions.online,
                        );
                    setState(() {
                      _isStorage = val;
                    });
                  }
                  return;
                },
                title: Text(
                  'Offline Mode',
                  style: textTheme.titleLarge,
                ),
                subtitle: Text(
                  'Toggle the app between using Local Memory or Firebase storage, Extremely useful for saving firebase limited bandwidth.',
                  style: textTheme.bodySmall,
                ),
              ),
              ListTile(
                onTap: downloadStorage,
                title: Text(
                  'Download Data',
                  style: textTheme.titleLarge,
                ),
                trailing: _isDownloading
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : const Icon(
                        Icons.download,
                        size: 26,
                      ),
                subtitle: Text(
                  _isDownloading
                      ? 'Please wait ..'
                      : 'Download all firebase images and store locally',
                  style: textTheme.bodySmall,
                ),
              ),
              ListTile(
                onTap: clearMemory,
                title: Text(
                  'Clear memory',
                  style: textTheme.titleLarge,
                ),
                trailing: _isClearing
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : const Icon(
                        Icons.delete,
                        size: 26,
                      ),
                subtitle: Text(
                  _isClearing
                      ? 'Please wait ..'
                      : 'Delete all locally stored images',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void downloadStorage() async {
    setState(() => _isDownloading = true);
    List<String> imgUrls = [];
    final firebase = FirebaseStorage.instance;
    final appDir = await getApplicationDocumentsDirectory();
    final workDir = Directory('${appDir.path}/storage');
    String workDirPath;

    if (await workDir.exists()) {
      workDirPath = workDir.path;
    } else {
      final newFolder = await workDir.create(recursive: true);
      workDirPath = newFolder.path;
    }

    await ref.read(photographyProvider.notifier).fetch();
    final photographyServer = ref.read(photographyProvider);
    for (final url in photographyServer.data) {
      imgUrls.add(url.url);
    }

    await ref.read(cloudProvider.notifier).fetch();
    final cloudServer = ref.read(cloudProvider);
    for (final pn in cloudServer.projectNames) {
      final List<String> imgNames = [];
      for (final url in cloudServer.images[pn]!) {
        imgUrls.add(url.url);
        imgNames.add(url.imgName);
      }
    }

    for (final url in imgUrls) {
      final imgRef = firebase.refFromURL(url);
      final details = imgRef.fullPath.split('/');
      final imgName = details[1];
      final imgDir = details[0];
      final filePath = '$workDirPath/${imgRef.fullPath}';
      final file = await File(filePath).create(recursive: true);

      final downloadTask = imgRef.writeToFile(file);
      downloadTask.snapshotEvents.listen((taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            break;
          case TaskState.paused:
            smackMsg('Error occurred : Download Paused');
            break;
          case TaskState.success:
            break;
          case TaskState.canceled:
            smackMsg('Error occurred : Download Canceled');
            break;
          case TaskState.error:
            smackMsg('Error occurred : Download Failed');
            break;
        }
      });

      await ref.read(storageProvider.notifier).addStorageItem(
            imgName: imgName,
            dir: imgDir,
            localPath: file.path,
            url: url,
          );
    }
    setState(() => _isDownloading = false);
  }

  void clearMemory() async {
    setState(() => _isClearing = true);

    final appDir = await getApplicationDocumentsDirectory();
    final workDir = Directory('${appDir.path}/storage');
    if (await workDir.exists()) {
      workDir.deleteSync(recursive: true);
    }

    await ref.read(storageProvider.notifier).clearStorageItem();

    setState(() => _isClearing = false);
  }

  void smackMsg(String smack) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Text(
          smack,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Future<void> leaveAlert() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Please Wait'),
        content: const Text(
            'Please wait and do not close the app forcefully. Some operations are running in background this may take some time.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }
}

final MaterialStateProperty<Icon?> _thumb =
    MaterialStateProperty.resolveWith<Icon?>(
  (Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return const Icon(Icons.volume_up);
    }
    return const Icon(Icons.volume_off);
  },
);
