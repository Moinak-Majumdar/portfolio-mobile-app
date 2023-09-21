import 'package:flutter_riverpod/flutter_riverpod.dart';

class HtmlNotifier extends StateNotifier<String> {
  HtmlNotifier() : super('');

  void exportHtml(String html) {
    state = html;
  }
}

final htmlProvider = StateNotifierProvider<HtmlNotifier, String>(
  (ref) => HtmlNotifier(),
);
