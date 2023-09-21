class PhotographySchema {
  const PhotographySchema({
    required this.id,
    required this.url,
    required this.name,
    required this.v,
  });

  final String id, url, name;
  final int v;
}

class PhotographyServerSchema {
  const PhotographyServerSchema({required this.data});
  final List<PhotographySchema> data;

  factory PhotographyServerSchema.fromJson(List<dynamic> json) {
    final List<PhotographySchema> data = [];
    for (final elm in json) {
      data.add(
        PhotographySchema(
          id: elm['_id'],
          url: elm['url'],
          name: elm['name'],
          v: elm['__v'],
        ),
      );
    }

    return PhotographyServerSchema(data: data);
  }
}
