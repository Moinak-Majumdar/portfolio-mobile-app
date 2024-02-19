import 'package:firebase_storage/firebase_storage.dart';

class FbStorageModel {
  const FbStorageModel({required this.allDirectories});

  final List<String> allDirectories;
}

class FbStorageItemModel {
  const FbStorageItemModel({
    required this.imgName,
    required this.projectName,
    required this.url,
  });

  final String imgName, projectName, url;
}

final _storageRef = FirebaseStorage.instance.ref();

Future<FbStorageModel> fetchFbStorage() async {
  try {
    final rootListResult = await _storageRef.listAll();
    final rootRef = rootListResult.prefixes;
    final List<String> allDirectory = [];

    for (final ref in rootRef) {
      allDirectory.add(ref.fullPath);
    }

    return FbStorageModel(allDirectories: allDirectory);
  } catch (e) {
    throw Exception(e);
  }
}

Future<List<FbStorageItemModel>> fetchFbStorageItem(String root) async {
  try {
    final List<FbStorageItemModel> allItems = [];

    final currentDirRef = await _storageRef.child(root).listAll();
    for (final item in currentDirRef.items) {
      final fullPath = item.fullPath.split('/');
      final url = await item.getDownloadURL();
      allItems.add(FbStorageItemModel(
        imgName: fullPath[1],
        projectName: fullPath[0],
        url: url,
      ));
    }

    return allItems;
  } catch (e) {
    throw Exception(e);
  }
}
