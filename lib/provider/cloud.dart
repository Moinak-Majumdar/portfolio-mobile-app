import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moinak05_web_dev_dashboard/models/cloud.dart';

const initial = CloudSchema(
  images: {
    "dummy": [],
  },
  projectNames: ['dummy'],
);

class CloudNotifier extends StateNotifier<CloudSchema> {
  CloudNotifier() : super(initial);

  Future<CloudSchema> fetch() async {
    final url = Uri.https(dotenv.env['SERVER']!, 'getAllCloudImg');

    final body = {
      "apiKey": dotenv.env['DB_KEY'],
    };

    final response = await http.post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      state = CloudSchema.fromJson(jsonDecode(response.body));
      return state;
    } else {
      throw Exception('Api Failed...');
    }
  }
}

final cloudProvider = StateNotifierProvider<CloudNotifier, CloudSchema>(
  (ref) => CloudNotifier(),
);
