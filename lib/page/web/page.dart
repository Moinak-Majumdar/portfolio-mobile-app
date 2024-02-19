import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/db.dart';
import 'package:portfolio/models/web_project.dart';
import 'package:portfolio/page/web/add_web.dart';
import 'package:portfolio/page/web/details.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/network_img_view.dart';
import 'package:portfolio/widget/neumorphism.dart';

Future<WebProjectServerModel> _fetchAllWebProject() async {
  final dio = Dio();
  final dbc = Get.put(DbController());

  try {
    final res = await dio.post(
      '${dotenv.env['SERVER']!}/getAllWeb',
      queryParameters: dbc.apiQueryParamBase(),
      data: {"apiKey": dotenv.env['DB_KEY']},
    );

    final serverData = WebProjectServerModel.fromJson(res.data);

    return serverData;
  } catch (e) {
    throw Exception(e);
  }
}

class Web extends StatelessWidget {
  const Web({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Projects'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWeb()),
              );
            },
            icon: const Icon(Icons.add, size: 30),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: _fetchAllWebProject(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data;

              return ListView.builder(
                itemCount: data!.allWeb.length,
                itemBuilder: (context, index) {
                  return _WebProjectCard(item: data.allWeb[index]);
                },
              );
            }

            if (snapshot.hasError) {
              final error = snapshot.error.toString();

              return OnError(error: error);
            }

            return const OnLoad(msg: 'Fetching all web project');
          },
        ),
      ),
    );
  }
}

class _WebProjectCard extends StatelessWidget {
  const _WebProjectCard({required this.item});

  final WebProjectModel item;

  @override
  Widget build(context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WebDetails(data: item)),
        );
      },
      child: NeuBox(
        margin: const EdgeInsets.fromLTRB(14, 10, 12, 12),
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        borderRadius: 16,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkImgView(
                url: item.cover.url,
                height: 200,
                borderRadius: BorderRadius.circular(8),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: RichText(
                  text: TextSpan(
                    text: "${item.name} : ",
                    style: textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: item.intro,
                        style: textTheme.labelLarge!
                            .copyWith(color: Colors.white70),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
