import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:portfolio/Hive/hive_flutter_cache.dart';
import 'package:portfolio/controller/db.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/flutter_project.dart';

List<String> badgeNameToBadge({required List<String> badgeNames}) {
  final List<String> badge = [];
  for (final bn in badgeNames) {
    badge.add('$bn.svg');
  }
  return badge;
}

const _boxName = "flutter-cache";
const _boxId = "saved-data";

Future<void> saveFlutterData({
  required BuildContext context,
  void Function()? onPageLeave,
  required FlutterProjectModel data,
}) async {
  if (onPageLeave != null) {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Save current progress before exit.",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _hiveSave(data);
              onPageLeave();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
          OutlinedButton(
            onPressed: () {
              onPageLeave();
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
            ),
            child: const Text("Don't save"),
          ),
        ],
      ),
    );
  } else {
    await _hiveSave(data);
  }
}

Future<FlutterProjectModel> getFlutterDataFromMemory() async {
  final box = await Hive.openBox<HiveFlutterCache>(_boxName);
  final data = box.get(_boxId);
  // await box.clear();
  await box.close();
  final List<ImportExport> img = [];
  ImportExport cover = const ImportExport.projectImage(
    name: "",
    projectName: "",
    url: "",
  );

  if (data != null) {
    cover = ImportExport.projectImage(
      name: data.coverImgName,
      projectName: data.name,
      url: data.coverImg,
    );
    for (int i = 0; i < data.img.length; i++) {
      img.add(
        ImportExport.projectImage(
          name: data.imgNames[i],
          projectName: data.name,
          url: data.img[i],
        ),
      );
    }

    return FlutterProjectModel(
      id: "",
      cover: cover,
      description: data.description,
      gitRepo: data.gitRepo,
      intro: data.intro,
      release: data.release,
      name: data.name,
      slug: data.slug,
      status: data.status,
      img: img,
      libraries: data.libraries,
      badgeNames: data.badgeNames,
      badge: badgeNameToBadge(badgeNames: data.badgeNames),
      v: 0,
    );
  } else {
    return FlutterProjectModel(
      id: "",
      cover: cover,
      description: "",
      gitRepo: "",
      intro: "",
      release: "",
      name: "",
      slug: "",
      status: "",
      img: img,
      badge: [],
      badgeNames: [],
      libraries: [],
      v: 0,
    );
  }
}

Future<FlutterServerResponse> addFlutterDataToMongo(
    FlutterProjectModel data) async {
  final dio = Dio();
  final dbc = Get.put(DbController());

  final img = [];
  for (final i in data.img) {
    img.add(i.url);
  }

  try {
    await dio.post(
      '${dotenv.env['SERVER']!}/addFlutter',
      queryParameters: {...dbc.apiQueryParamBase()},
      data: {
        "apiKey": dotenv.env['DB_KEY'],
        "name": data.name,
        "slug": data.slug,
        "intro": data.intro,
        "release": data.release,
        "status": data.status,
        "gitRepo": data.gitRepo,
        "description": data.description,
        "cover": data.cover.url,
        "img": img,
        "badge": data.badge,
        "libraries": data.libraries
      },
    );
    return FlutterServerResponse(
      message:
          "Flutter project : ${data.name} is successfully uploaded to mongo.",
      type: FlutterServerResType.success,
    );
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        return FlutterServerResponse(
          message:
              'Failed with status code: ${e.response!.statusCode} \n${e.response!.data['error']}',
          type: FlutterServerResType.error,
        );
      } else {
        return FlutterServerResponse(
          message: e.message.toString(),
          type: FlutterServerResType.error,
        );
      }
    } else {
      return FlutterServerResponse(
        message: e.toString(),
        type: FlutterServerResType.error,
      );
    }
  }
}

Future<FlutterServerResponse> updateFlutterDataAtMongo(
    FlutterProjectModel data) async {
  final dio = Dio();
  final dbc = Get.put(DbController());

  final List<String> img = [];
  for (final i in data.img) {
    img.add(i.url);
  }

  try {
    await dio.put(
      '${dotenv.env['SERVER']!}/updateFlutter',
      queryParameters: {...dbc.apiQueryParamBase()},
      data: {
        "apiKey": dotenv.env['DB_KEY'],
        "name": data.name,
        "status": data.status,
        "intro": data.intro,
        "release": data.release,
        "gitRepo": data.gitRepo,
        "slug": data.slug,
        "description": data.description,
        "cover": data.cover.url,
        "img": img,
        "libraries": data.libraries,
        "badge": data.badge,
        "docId": data.id,
      },
    );
    return FlutterServerResponse(
      message: "Flutter project : ${data.name} is updated successfully.",
      type: FlutterServerResType.success,
    );
  } catch (e) {
    print(e);
    if (e is DioException) {
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        return FlutterServerResponse(
          message:
              'Failed with status code: ${e.response!.statusCode} \n${e.response!.data['error']}',
          type: FlutterServerResType.error,
        );
      } else {
        return FlutterServerResponse(
          message: e.message.toString(),
          type: FlutterServerResType.error,
        );
      }
    } else {
      return FlutterServerResponse(
        message: e.toString(),
        type: FlutterServerResType.error,
      );
    }
  }
}

void resetFlutterData({
  required void Function() onReset,
  required BuildContext context,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        "Reset current progress ?",
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onReset();
            Navigator.pop(context);
          },
          child: const Text(
            "Reset",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        )
      ],
    ),
  );
}

// hl1 private.
Future<void> _hiveSave(FlutterProjectModel data) async {
  final box = await Hive.openBox<HiveFlutterCache>(_boxName);
  final List<String> imgUrls = [], imgNames = [];
  for (final item in data.img) {
    imgUrls.add(item.url);
    imgNames.add(item.name);
  }

  await box.put(
    _boxId,
    HiveFlutterCache(
      coverImg: data.cover.url,
      coverImgName: data.cover.name,
      description: data.description,
      gitRepo: data.gitRepo,
      intro: data.intro,
      img: imgUrls,
      imgNames: imgNames,
      release: data.release,
      name: data.name,
      slug: data.slug,
      status: data.status,
      badgeNames: data.badgeNames,
      libraries: data.libraries,
    ),
  );
}
