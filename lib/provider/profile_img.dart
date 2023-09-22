import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:moinak05_web_dev_dashboard/hive_storage.dart';
import 'package:moinak05_web_dev_dashboard/models/storage.dart';

const boxName = 'userImage';

class ProfileImgNotifier extends StateNotifier<StorageSchema?> {
  ProfileImgNotifier() : super(null);

  Future<StorageSchema?> getInitial() async {
    final box = await Hive.openBox<HiveStorage>(boxName);
    final item = box.get('profile/_/default');
    await box.close();
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

  Future<void> addProfileImg({
    required String imgName,
    required String dir,
    required String localPath,
    required String url,
  }) async {
    state = StorageSchema(dir: dir, image: File(localPath), imgName: imgName);
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
}

final profileImgProvider =
    StateNotifierProvider<ProfileImgNotifier, StorageSchema?>(
  (ref) => ProfileImgNotifier(),
);
