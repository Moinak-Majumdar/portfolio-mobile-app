import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:portfolio/models/project_img.dart';

class ProjectImageController extends GetxController {
  RxList<String> projectNames = <String>[].obs;
  RxString selectedProject = ''.obs;
  RxMap<String, List<ProjectImgModel>> allImages =
      <String, List<ProjectImgModel>>{}.obs;

  void resetFetchedItems() {
    projectNames.value = [];
    selectedProject.value = '';
    allImages.value = {};
  }

  Future<ProjectImgServerModel> fetchAllProjectImg(
      Map<String, dynamic> queryParams) async {
    try {
      final dio = Dio();

      final res = await dio.post(
        '${dotenv.env['SERVER']!}/getAllProjectImg',
        queryParameters: queryParams,
        data: {"apiKey": dotenv.env['DB_KEY']},
      );

      final serverData = ProjectImgServerModel.fromJson(res.data);

      if (res.statusCode == 200) {
        projectNames.value = [...serverData.projectNames];
        allImages.value = serverData.images;
      }

      return serverData;
    } catch (e) {
      throw Exception(e);
    }
  }
}
