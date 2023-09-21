class CloudImgSchema {
  const CloudImgSchema({
    required this.id,
    required this.url,
    required this.imgName,
    required this.projectName,
    required this.v,
  });

  final String id, url, imgName, projectName;
  final int v;
}

class CloudSchema {
  const CloudSchema({required this.images, required this.projectNames});

  final List<String> projectNames;
  final Map<String, List<CloudImgSchema>> images;

  factory CloudSchema.fromJson(Map<String, dynamic> json) {
    final pn = json['projectNames'];
    final List<String> projectNames = [];
    for (final elm in pn) {
      projectNames.add(elm.toString());
    }

    final imgs = json['images'];
    Map<String, List<CloudImgSchema>> images = {};
    for (final name in projectNames) {
      final data = imgs[name];
      final List<CloudImgSchema> sub = [];

      for (final i in data) {
        final elm = CloudImgSchema(
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
    return CloudSchema(images: images, projectNames: projectNames);
  }
}
