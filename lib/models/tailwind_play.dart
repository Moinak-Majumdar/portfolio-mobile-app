class TailwindPlayModel {
  const TailwindPlayModel({
    required this.id,
    required this.html,
    required this.token,
    required this.v,
  });
  final String id, token, html;
  final int v;
}

class TailwindPlayServerModel {
  const TailwindPlayServerModel({required this.data});
  final TailwindPlayModel data;

  factory TailwindPlayServerModel.fromJson(Map<String, dynamic> json) {
    final TailwindPlayModel elm = TailwindPlayModel(
      id: json['_id'],
      html: json['html'],
      token: json['token'],
      v: json['__v'],
    );

    return TailwindPlayServerModel(data: elm);
  }
}
