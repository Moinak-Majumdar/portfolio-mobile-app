import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:portfolio/controller/db.dart';
import 'package:portfolio/models/photography.dart';
import 'package:portfolio/page/photography/add_photography.dart';
import 'package:portfolio/utils/on_error.dart';
import 'package:portfolio/utils/on_load.dart';
import 'package:portfolio/widget/neumorphism.dart';

Future<List<PhotographyModel>> fetchAllPhotography() async {
  final dio = Dio();
  final dbc = Get.put(DbController());

  try {
    final res = await dio.post(
      '${dotenv.env['SERVER']!}/getAllPhotography',
      queryParameters: {...dbc.apiQueryParamBase()},
      data: {"apiKey": dotenv.env['DB_KEY']},
    );

    final serverData = PhotographyServerModel.fromJson(res.data);

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

class Photography extends StatelessWidget {
  const Photography({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photography'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPhotography()),
                );
              },
              icon: const Icon(Icons.upload))
        ],
      ),
      body: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder(
            future: fetchAllPhotography(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!;

                return GridView.custom(
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4,
                    pattern: const [
                      QuiltedGridTile(4, 2),
                      QuiltedGridTile(3, 2),
                      QuiltedGridTile(4, 2),
                      QuiltedGridTile(4, 2),
                    ],
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    childCount: data.length,
                    (context, index) => NeuBox(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      borderRadius: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: data[index].url,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error_outline_rounded,
                            size: 32,
                            color: Colors.red,
                          ),
                          placeholder: (context, url) => const Icon(
                            Icons.photo,
                            size: 32,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return OnError(error: snapshot.error.toString());
              }

              return const OnLoad(msg: 'Getting Photography...');
            },
          ),
        ),
      ),
    );
  }
}
