class ProjectImgModel {
  const ProjectImgModel({
    required this.id,
    required this.url,
    required this.imgName,
    required this.projectName,
    required this.v,
  });

  final String id, url, imgName, projectName;
  final int v;
}

class ProjectImgServerModel {
  const ProjectImgServerModel(
      {required this.images, required this.projectNames});

  final List<String> projectNames;
  final Map<String, List<ProjectImgModel>> images;

  factory ProjectImgServerModel.fromJson(Map<String, dynamic> json) {
    final pn = json['projectNames'];
    final List<String> projectNames = [];
    for (final elm in pn) {
      projectNames.add(elm.toString());
    }

    final imgs = json['images'];
    Map<String, List<ProjectImgModel>> images = {};
    for (final name in projectNames) {
      final data = imgs[name];
      final List<ProjectImgModel> sub = [];

      for (final i in data) {
        final elm = ProjectImgModel(
          id: i['_id'],
          url: i['url'],
          imgName: i['imgName'],
          projectName: i['projectName'],
          v: i['__v'],
        );
        sub.add(elm);
      }

      images[name] = sub;
    }
    return ProjectImgServerModel(images: images, projectNames: projectNames);
  }
}
