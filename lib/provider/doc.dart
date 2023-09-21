import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moinak05_web_dev_dashboard/models/doc.dart';

const initial = DocServerSchema(allDoc: []);

class DocNotifier extends StateNotifier<DocServerSchema> {
  DocNotifier() : super(initial);

  Future<DocServerSchema> getAllDoc() async {
    final url = Uri.https(dotenv.env['SERVER']!, 'getAllDoc');

    final body = {
      "apiKey": dotenv.env['DB_KEY'],
    };

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      state = DocServerSchema.fromJson(jsonDecode(response.body));
      return state;
    } else {
      throw Exception('Api Failed...');
    }
  }

  Future<DocResponse> addDoc({
    required String cover,
    required String description,
    required String gitRepo,
    required List<String> img,
    required String intro,
    required String liveUrl,
    required String name,
    required String role,
    required bool status,
    required List<String> tools,
    required String type,
  }) async {
    final List<String> toolsLogo = [];
    for (final elm in tools) {
      toolsLogo.add('$elm.svg');
    }

    final String slug = name.toLowerCase().replaceAll(' ', '');

    final url = Uri.https(dotenv.env['SERVER']!, 'addDoc');

    final body = {
      "apiKey": dotenv.env['DB_KEY'],
      "name": name,
      "slug": slug,
      "type": type,
      "role": role,
      "intro": intro,
      "liveUrl": liveUrl,
      "status": status ? 'completed' : 'under development',
      "gitRepo": gitRepo,
      "description": description,
      "cover": cover,
      "img": img,
      "tools": tools,
      "toolsLogo": toolsLogo,
    };

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    final data = DocResponse.fromJson(jsonDecode(response.body));

    // print(data.success);
    return data;
  }

  Future<DocResponse> updateDoc({
    required String cover,
    required String description,
    required String gitRepo,
    required List<String> img,
    required String intro,
    required String liveUrl,
    required String name,
    required String role,
    required bool status,
    required List<String> tools,
    required String type,
    required String docId,
  }) async {
    final List<String> toolsLogo = [];
    for (final elm in tools) {
      toolsLogo.add('$elm.svg');
    }

    final String slug = name.toLowerCase().replaceAll(' ', '');

    final url = Uri.https(dotenv.env['SERVER']!, 'updateDoc');

    final body = {
      "apiKey": dotenv.env['DB_KEY'],
      "docId": docId,
      "name": name,
      "slug": slug,
      "type": type,
      "role": role,
      "intro": intro,
      "liveUrl": liveUrl,
      "status": status ? 'completed' : 'under development',
      "gitRepo": gitRepo,
      "description": description,
      "cover": cover,
      "img": img,
      "tools": tools,
      "toolsLogo": toolsLogo,
    };

    final response = await http.put(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    final data = DocResponse.fromJson(jsonDecode(response.body));

    // print(jsonDecode(response.body));
    return data;
  }

  Future<DocResponse> deleteDoc({
    required String name,
    required String docId,
  }) async {
    final url = Uri.https(dotenv.env['SERVER']!, 'deleteDoc');

    final body = {
      "apiKey": dotenv.env['DB_KEY'],
      "docId": docId,
      "name": name,
    };

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    final data = DocResponse.fromJson(jsonDecode(response.body));

    return data;
  }
}

final docProvider = StateNotifierProvider<DocNotifier, DocServerSchema>(
  (ref) => DocNotifier(),
);

final docToolsProvider = Provider<List<String>>(
  (ref) => [
    "c",
    'cpp',
    'css',
    'dart',
    'express',
    'figma',
    'firebase',
    'flutter',
    'framer',
    'flutter',
    'graphQL',
    'heroku',
    'html',
    'java',
    'javascript',
    'mongodb',
    'mui',
    'mysql',
    'netlify',
    'next',
    'node',
    'php',
    'python',
    'react',
    'redux',
    'tailwind',
    'typescript',
    'vercel'
  ],
);
