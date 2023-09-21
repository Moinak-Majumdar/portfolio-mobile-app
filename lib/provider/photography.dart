import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moinak05_web_dev_dashboard/models/photography.dart';

const initial = PhotographyServerSchema(
  data: [],
);

class PhotographyNotifier extends StateNotifier<PhotographyServerSchema> {
  PhotographyNotifier() : super(initial);

  Future<PhotographyServerSchema> fetch() async {
    final url = Uri.https(dotenv.env['SERVER']!, 'getAllPhotography');

    final body = {
      "apiKey": dotenv.env['DB_KEY'],
    };

    final response = await http.post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      state = PhotographyServerSchema.fromJson(jsonDecode(response.body));
      return state;
    } else {
      throw Exception('Api Failed...');
    }
  }
}

final photographyProvider =
    StateNotifierProvider<PhotographyNotifier, PhotographyServerSchema>(
  (ref) => PhotographyNotifier(),
);
