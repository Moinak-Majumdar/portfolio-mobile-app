import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExportedImgSchema {
  ExportedImgSchema({
    required this.imgName,
    required this.projectName,
    required this.url,
  });
  String url, projectName, imgName;
}

class DocImgNotifier extends StateNotifier<List<ExportedImgSchema>> {
  DocImgNotifier() : super([]);

  void add(ExportedImgSchema img) {
    state = [...state, img];
  }

  void remove(String url) {
    state = state.where((element) => element.url != url).toList();
  }

  bool present(String url) {
    final List<String> urls = [];
    for (final element in state) {
      urls.add(element.url);
    }

    return urls.contains(url);
  }
}

final imgProvider =
    StateNotifierProvider<DocImgNotifier, List<ExportedImgSchema>>(
  (ref) => DocImgNotifier(),
);
