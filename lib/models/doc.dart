class DocSchema {
  const DocSchema({
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
      status,
      cover;

  final List<String> img, tools, toolsLogo;
  final int v;
}

class DocServerSchema {
  const DocServerSchema({required this.allDoc});
  final List<DocSchema> allDoc;

  factory DocServerSchema.fromJson(List<dynamic> json) {
    final List<DocSchema> data = [];

    for (final elm in json) {
      final List<String> img = [];
      final List<String> tools = [];
      final List<String> toolsLogo = [];

      for (final item in elm['img']) {
        img.add(item);
      }

      for (int i = 0; i < elm['tools'].length; i++) {
        tools.add(elm['tools'][i]);
        toolsLogo.add(elm['toolsLogo'][i]);
      }

      data.add(
        DocSchema(
          id: elm['_id'],
          cover: elm['cover'],
          description: elm['description'],
          gitRepo: elm['gitRepo'],
          intro: elm['intro'],
          liveUrl: elm['liveUrl'],
          name: elm['name'],
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

    return DocServerSchema(allDoc: data);
  }
}

class DocResponse {
  const DocResponse({
    required this.errors,
    required this.success,
    required this.error,
  });
  final List<String> errors;
  final String error;
  final bool success;

  factory DocResponse.fromJson(Map<String, dynamic> json) {
    final String err;
    final bool ok;
    final List<String> validationErr = [];

    err = json['error'] ?? '';
    ok = json['success'] != null ? true : false;
    if (json['errors'] != null) {
      for (final elm in json['errors']) {
        validationErr.add(elm);
      }
    }

    return DocResponse(errors: validationErr, success: ok, error: err);
  }
}
