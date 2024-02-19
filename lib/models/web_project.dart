import 'package:firebase_storage/firebase_storage.dart';
import 'package:portfolio/controller/import_export.dart';

class WebProjectModel {
  const WebProjectModel({
    required this.id,
    required this.cover,
    required this.description,
    required this.gitRepo,
    required this.intro,
    required this.liveUrl,
    required this.name,
    required this.role,
    required this.slug,
    required this.status,
    required this.type,
    required this.img,
    required this.tools,
    required this.toolsLogo,
    required this.v,
  });

  final String id,
      name,
      type,
      role,
      intro,
      liveUrl,
      gitRepo,
      slug,
      description,
      status;

  final List<String> tools, toolsLogo;
  final ImportExport cover;
  final List<ImportExport> img;
  final int v;
}

class WebProjectServerModel {
  const WebProjectServerModel({required this.allWeb});
  final List<WebProjectModel> allWeb;

  factory WebProjectServerModel.fromJson(List<dynamic> json) {
    final List<WebProjectModel> data = [];

    for (final elm in json) {
      final List<ImportExport> img = [];
      final List<String> tools = [];
      final List<String> toolsLogo = [];
      final String projectName = elm['name'];

      for (final item in elm['img']) {
        final storageRef = FirebaseStorage.instance.refFromURL(item);
        final imgName = storageRef.name;

        img.add(ImportExport.projectImage(
          name: imgName,
          projectName: projectName,
          url: item,
        ));
      }

      for (int i = 0; i < elm['tools'].length; i++) {
        tools.add(elm['tools'][i]);
        toolsLogo.add(elm['toolsLogo'][i]);
      }

      final storageRef = FirebaseStorage.instance.refFromURL(elm["cover"]);
      final coverImgName = storageRef.name;
      final coverImage = ImportExport.projectImage(
        name: coverImgName,
        projectName: projectName,
        url: elm["cover"],
      );

      data.add(
        WebProjectModel(
          id: elm['_id'],
          cover: coverImage,
          description: elm['description'],
          gitRepo: elm['gitRepo'],
          intro: elm['intro'],
          liveUrl: elm['liveUrl'],
          name: projectName,
          role: elm['role'],
          slug: elm['slug'],
          status: elm['status'],
          type: elm['type'],
          img: img,
          tools: tools,
          toolsLogo: toolsLogo,
          v: elm['__v'],
        ),
      );
    }

    return WebProjectServerModel(allWeb: data);
  }
}

enum WebServerResType { success, error }

class WebServerResponse {
  const WebServerResponse({required this.message, required this.type});
  final WebServerResType type;
  final String message;
}
