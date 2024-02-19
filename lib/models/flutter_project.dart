import 'package:firebase_storage/firebase_storage.dart';
import 'package:portfolio/controller/import_export.dart';

class FlutterProjectModel {
  const FlutterProjectModel({
    required this.id,
    required this.cover,
    required this.description,
    required this.gitRepo,
    required this.intro,
    required this.name,
    required this.release,
    required this.slug,
    required this.status,
    required this.img,
    required this.badge,
    required this.libraries,
    required this.v,
  });

  final String id, name, slug, status, intro, description, release, gitRepo;
  final List<String> libraries, badge;
  final ImportExport cover;
  final List<ImportExport> img;
  final int v;
}

class FlutterProjectServerModel {
  const FlutterProjectServerModel({required this.allFlutter});
  final List<FlutterProjectModel> allFlutter;

  factory FlutterProjectServerModel.fromJson(List<dynamic> json) {
    final List<FlutterProjectModel> data = [];

    for (final project in json) {
      final List<ImportExport> img = [];
      final List<String> libraries = [];
      final List<String> badge = [];

      for (final item in project['img']) {
        final storageRef = FirebaseStorage.instance.refFromURL(item);
        final imgName = storageRef.name;

        img.add(ImportExport.projectImage(
          name: imgName,
          projectName: project["name"],
          url: item,
        ));
      }

      for (int i = 0; i < project['libraries'].length; i++) {
        libraries.add(project['libraries'][i]);
      }
      for (int i = 0; i < project['badge'].length; i++) {
        badge.add(project['badge'][i]);
      }

      final storageRef = FirebaseStorage.instance.refFromURL(project["cover"]);
      final coverImgName = storageRef.name;
      final coverImage = ImportExport.projectImage(
        name: coverImgName,
        projectName: project["name"],
        url: project["cover"],
      );

      data.add(
        FlutterProjectModel(
          id: project['_id'],
          cover: coverImage,
          description: project['description'],
          gitRepo: project['gitRepo'],
          intro: project['intro'],
          name: project['name'],
          release: project['release'],
          slug: project['slug'],
          status: project['status'],
          img: img,
          badge: badge,
          libraries: libraries,
          v: project['__v'],
        ),
      );
    }

    return FlutterProjectServerModel(allFlutter: data);
  }
}

enum FlutterServerResType { success, error }

class FlutterServerResponse {
  const FlutterServerResponse({required this.message, required this.type});
  final FlutterServerResType type;
  final String message;
}
