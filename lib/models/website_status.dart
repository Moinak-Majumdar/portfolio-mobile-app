class WebSiteStatusModel {
  const WebSiteStatusModel({
    required this.id,
    required this.name,
    required this.mode,
    required this.description,
    required this.devFlag,
    required this.v,
  });
  final String id, name, mode, description;
  final bool devFlag;
  final int v;
}

class WebSiteStatusServerModel {
  const WebSiteStatusServerModel({required this.data});
  final WebSiteStatusModel data;

  factory WebSiteStatusServerModel.fromJson(Map<String, dynamic> json) {
    final WebSiteStatusModel elm = WebSiteStatusModel(
      id: json['_id'],
      name: json['name'],
      mode: json['mode'],
      description: json['description'],
      devFlag: json['devFlag'],
      v: json['__v'],
    );

    return WebSiteStatusServerModel(data: elm);
  }
}
