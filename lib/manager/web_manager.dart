import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:portfolio/Hive/hive_web_cache.dart';
import 'package:portfolio/controller/db.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/web_project.dart';

const _boxName = "web-cache";
const _boxId = "saved-data";

Future<void> saveWebData({
  required BuildContext context,
  void Function()? onPageLeave,
  required WebProjectModel data,
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

Future<WebProjectModel> getWebDataFromMemory() async {
  final box = await Hive.openBox<HiveWebCache>(_boxName);
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

    return WebProjectModel(
      id: "",
      cover: cover,
      description: data.description,
      gitRepo: data.gitRepo,
      intro: data.intro,
      liveUrl: data.liveUrl,
      name: data.name,
      role: data.role,
      slug: data.slug,
      status: data.status,
      type: data.type,
      img: img,
      tools: data.tools,
      toolsLogo: data.tools,
      v: 0,
    );
  } else {
    return WebProjectModel(
      id: "",
      cover: cover,
      description: "",
      gitRepo: "",
      intro: "",
      liveUrl: "",
      name: "",
      role: "",
      slug: "",
      status: "",
      type: "",
      img: img,
      tools: [],
      toolsLogo: [],
      v: 0,
    );
  }
}

Future<WebServerResponse> addNewWebDataToMongo(WebProjectModel data) async {
  final dio = Dio();
  final dbc = Get.put(DbController());

  final img = [];
  for (final i in data.img) {
    img.add(i.url);
  }

  try {
    await dio.post(
      '${dotenv.env['SERVER']!}/addWeb',
      queryParameters: {...dbc.apiQueryParamBase()},
      data: {
        "apiKey": dotenv.env['DB_KEY'],
        "name": data.name,
        "slug": data.slug,
        "type": data.type,
        "role": data.role,
        "intro": data.intro,
        "liveUrl": data.liveUrl,
        "status": data.status,
        "gitRepo": data.gitRepo,
        "description": data.description,
        "cover": data.cover.url,
        "img": img,
        "tools": data.tools,
        "toolsLogo": data.toolsLogo,
      },
    );
    return WebServerResponse(
      message:
          "Web ${data.type} : ${data.name} is successfully uploaded to mongo.",
      type: WebServerResType.success,
    );
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        return WebServerResponse(
          message:
              'Failed with status code: ${e.response!.statusCode} \n${e.response!.data['error']}',
          type: WebServerResType.error,
        );
      } else {
        return WebServerResponse(
          message: e.message.toString(),
          type: WebServerResType.error,
        );
      }
    } else {
      return WebServerResponse(
        message: e.toString(),
        type: WebServerResType.error,
      );
    }
  }
}

Future<WebServerResponse> updateWebDataAtMongo(WebProjectModel data) async {
  final dio = Dio();
  final dbc = Get.put(DbController());

  final img = [];
  for (final i in data.img) {
    img.add(i.url);
  }

  try {
    await dio.put(
      '${dotenv.env['SERVER']!}/updateWeb',
      queryParameters: {...dbc.apiQueryParamBase()},
      data: {
        "apiKey": dotenv.env['DB_KEY'],
        "docId": data.id,
        "name": data.name,
        "slug": data.slug,
        "type": data.type,
        "role": data.role,
        "intro": data.intro,
        "liveUrl": data.liveUrl,
        "status": data.status,
        "gitRepo": data.gitRepo,
        "description": data.description,
        "cover": data.cover.url,
        "img": img,
        "tools": data.tools,
        "toolsLogo": data.toolsLogo,
      },
    );
    return WebServerResponse(
      message: "Web ${data.type} : ${data.name} is successfully updated.",
      type: WebServerResType.success,
    );
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        return WebServerResponse(
          message:
              'Failed with status code: ${e.response!.statusCode} \n${e.response!.data['error']}',
          type: WebServerResType.error,
        );
      } else {
        return WebServerResponse(
          message: e.message.toString(),
          type: WebServerResType.error,
        );
      }
    } else {
      return WebServerResponse(
        message: e.toString(),
        type: WebServerResType.error,
      );
    }
  }
}

void resetWebData({
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
Future<void> _hiveSave(WebProjectModel data) async {
  final box = await Hive.openBox<HiveWebCache>(_boxName);
  final List<String> imgUrls = [], imgNames = [];
  for (final item in data.img) {
    imgUrls.add(item.url);
    imgNames.add(item.name);
  }

  await box.put(
    _boxId,
    HiveWebCache(
      coverImg: data.cover.url,
      coverImgName: data.cover.name,
      description: data.description,
      gitRepo: data.gitRepo,
      intro: data.intro,
      img: imgUrls,
      imgNames: imgNames,
      liveUrl: data.liveUrl,
      name: data.name,
      role: data.role,
      slug: data.slug,
      status: data.status,
      tools: data.tools,
      type: data.type,
    ),
  );
}
