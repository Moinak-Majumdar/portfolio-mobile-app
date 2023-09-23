import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:moinak05_web_dev_dashboard/hive_storage.dart';
import 'package:moinak05_web_dev_dashboard/models/storage.dart';
import 'package:path_provider/path_provider.dart';

enum StorageOptions {
  online,
  offline,
}

const boxName = 'storage';

class StorageNotifier extends StateNotifier<StorageOptions> {
  StorageNotifier() : super(StorageOptions.offline);

  void storageSetting(StorageOptions option) {
    state = option;
  }

  Future<bool> isDataAvailableLocally() async {
    final box = await Hive.openBox<HiveStorage>(boxName);
    final records = box.values.toList();

    if (records.isNotEmpty) {
      return true;
    } else {
      state = StorageOptions.online;
      return false;
    }
  }

//hl1 used at when user download images from settings.
  Future<void> addStorageItem({
    required String imgName,
    required String dir,
    required String localPath,
    required String url,
  }) async {
    final box = await Hive.openBox<HiveStorage>(boxName);
    await box.put(
      '$dir/_/$imgName',
      HiveStorage(
        imgName: imgName,
        dir: dir,
        localPath: localPath,
        url: url,
      ),
    );
    await box.close();
  }

//hl4 used at when user upload new image (photography / cloud image).
  Future<void> explicitlyAddItem({
    required String imgName,
    required String dir,
    required File image,
    required String url,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final workDir = Directory('${appDir.path}/storage/$dir');
    String workDirPath;

    if (await workDir.exists()) {
      workDirPath = workDir.path;
    } else {
      final newFolder = await workDir.create(recursive: true);
      workDirPath = newFolder.path;
    }

    final copy = await image.copy('$workDirPath/$imgName');

    await addStorageItem(
      imgName: imgName,
      dir: dir,
      localPath: copy.path,
      url: url,
    );
  }

//hl6 used at when user removed a image (photography / cloud image)
  Future<void> explicitlyRemoveItem({
    required String imgName,
    required String dir,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final workDir = Directory('${appDir.path}/storage/$dir');
    if (await workDir.exists()) {
      final file = File('${workDir.path}/$imgName');

      await file.delete();
      final box = await Hive.openBox<HiveStorage>(boxName);
      await box.delete('$dir/_/$imgName');
      await box.close();
    }

    return;
  }

// hl3 find local image by name and associate doc / photography.
  Future<StorageSchema> getStorageItem({
    required String dir,
    required String imgName,
  }) async {
    final box = await Hive.openBox<HiveStorage>(boxName);
    final data = box.get('$dir/_/$imgName');
    if (data != null) {
      return StorageSchema(
        imgName: data.imgName,
        dir: data.dir,
        image: File(data.localPath),
      );
    }
    await box.close();
    throw Exception('Not found');
  }

// hl5  find local image by firebase url.
  Future<StorageSchema> getStorageItemByUrl({required String url}) async {
    final box = await Hive.openBox<HiveStorage>(boxName);
    final records = box.values.toList();
    if (records.isNotEmpty) {
      final item = records.where((element) => element.url == url).toList();

      return StorageSchema(
        dir: item[0].dir,
        image: File(item[0].localPath),
        imgName: item[0].imgName,
      );
    }
    await box.close();
    throw Exception('Not Found');
  }

// hl2  clear local stored items.
  Future<void> clearStorageItem() async {
    final box = await Hive.openBox<HiveStorage>(boxName);
    await box.clear();
    await box.close();
  }
}

final storageProvider = StateNotifierProvider<StorageNotifier, StorageOptions>(
  (ref) => StorageNotifier(),
);

final docStorageBucket = Provider((ref) => 'docImages');
