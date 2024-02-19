import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/import_export.dart';
import 'package:portfolio/models/tailwind_play.dart';
import 'package:portfolio/page/tailwind%20play/qr_scan.dart';
import 'package:portfolio/utils/get_snack.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/tailwind_play_content.dart';

Future<TailwindPlayModel> getTailwindPlay(String token) async {
  final dio = Dio();

  try {
    final res = await dio.post(
      '${dotenv.env['SERVER']!}/getTailwindPlay',
      queryParameters: {"dbAdmin": true},
      data: {"apiKey": dotenv.env['DB_KEY'], "token": token},
    );
    final serverData = TailwindPlayServerModel.fromJson(res.data);
    return serverData.data;
  } catch (e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        throw Exception(
            'Failed with status code: ${e.response!.statusCode} \n${e.response!.data['error']}');
      } else {
        throw Exception(e);
      }
    } else {
      throw Exception(e);
    }
  }
}

class TailwindPlay extends StatefulWidget {
  const TailwindPlay({super.key});

  @override
  State<TailwindPlay> createState() => _TailwindPlayState();
}

class _TailwindPlayState extends State<TailwindPlay> {
  String? _token;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _tokenController;

  @override
  void initState() {
    _tokenController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void handelSearch() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _token = _tokenController.text;
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("T a i l w i n d P l a y"),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              onTap: () async {
                final token = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QrScan(),
                  ),
                );
                setState(() {
                  _tokenController.text = token;
                });
              },
              title: const Text(
                  "Scan qr or enter token to get Tailwind play content."),
              trailing: const Icon(
                Icons.qr_code,
                size: 32,
                color: Colors.cyan,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _tokenController,
                  maxLength: 8,
                  decoration: const InputDecoration(
                    label: Text('Token'),
                    hintText: 'A1B2C3D4',
                  ),
                  validator: (val) {
                    if (val == null || val == '') {
                      return 'Required *';
                    }
                    if (val.length > 8) {
                      return 'Token must contains 8 characters.';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton.icon(
                onPressed: handelSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
            if (_token != null)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 12,
                      left: 10,
                      right: 10,
                      bottom: 4,
                    ),
                    child: Divider(),
                  ),
                  FutureBuilder(
                    future: getTailwindPlay(_token!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TailwindPlayContent(content: data!.html),
                            Padding(
                              padding: const EdgeInsets.only(top: 8, right: 8),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final iec = Get.put(ImportExportController());
                                  iec.tailwindStorage.value = data.html;
                                  GetSnack.success(
                                    message:
                                        'Above shown tailwind play content is exported.',
                                  );
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.forward,
                                  size: 18,
                                ),
                                label: const Text('Export'),
                              ),
                            ),
                          ],
                        );
                      }

                      if (snapshot.hasError) {
                        final error = snapshot.error.toString();

                        return OnError(error: error);
                      }
                      return const OnLoad(msg: 'Loading ...');
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
