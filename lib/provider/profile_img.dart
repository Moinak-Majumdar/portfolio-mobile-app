import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:moinak05_web_dev_dashboard/hive_storage.dart';
import 'package:moinak05_web_dev_dashboard/models/storage.dart';
import 'package:path_provider/path_provider.dart';

const boxName = 'userImage';

class ProfileImgNotifier extends StateNotifier<StorageSchema?> {
  ProfileImgNotifier() : super(null);

  Future<StorageSchema?> isProfileImgAvailable() async {
    final box = await Hive.openBox<HiveStorage>(boxName);
    final item = box.get('profile/_/default');

    if (item != null) {
      state = StorageSchema(
        imgName: item.imgName,
        dir: item.dir,
        image: File(item.localPath),
      );
      return state;
    }
    throw Exception('profile not found');
  }

  Future<void> addProfileImg({required String localPath}) async {
    state = StorageSchema(
      dir: 'profile',
      image: File(localPath),
      imgName: 'default',
    );
    final box = await Hive.openBox<HiveStorage>(boxName);
    await box.put(
      'profile/_/default',
      HiveStorage(
        imgName: 'default',
        dir: 'profile',
        localPath: localPath,
        url: 'not needed',
      ),
    );
    await box.close();
  }

  Future<void> removeProfileImg() async {
    final appDir = await getApplicationDocumentsDirectory();
    final workDir = Directory('${appDir.path}/userData');

    if (await workDir.exists()) {
      workDir.deleteSync(recursive: true);
      final box = await Hive.openBox<HiveStorage>(boxName);
      await box.delete('profile/_/default');
      await box.close();
    }
    state = null;
  }
}

final profileImgProvider =
    StateNotifierProvider<ProfileImgNotifier, StorageSchema?>(
  (ref) => ProfileImgNotifier(),
);
