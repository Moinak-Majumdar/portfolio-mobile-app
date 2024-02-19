class PhotographyModel {
  const PhotographyModel({
    required this.id,
    required this.url,
    required this.name,
    required this.v,
  });

  final String id, url, name;
  final int v;
}

class PhotographyServerModel {
  const PhotographyServerModel({required this.data});
  final List<PhotographyModel> data;

  factory PhotographyServerModel.fromJson(List<dynamic> json) {
    final List<PhotographyModel> data = [];
    for (final elm in json) {
      data.add(
        PhotographyModel(
          id: elm['_id'],
          url: elm['url'],
          name: elm['name'],
          v: elm['__v'],
        ),
      );
    }

    return PhotographyServerModel(data: data);
  }
}
