import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:portfolio/models/website_status.dart';

import '../utils/get_snack.dart';

class WebSiteStatusController extends GetxController {
  RxBool devFlag = false.obs;
  RxString description = ''.obs;
  final dio = Dio();

  @override
  void onInit() async {
    try {
      final res = await dio.post(
        '${dotenv.env['SERVER']!}/getStatus',
        queryParameters: {"dbAdmin": true},
        data: {"apiKey": dotenv.env['DB_KEY']},
      );

      final serverData = WebSiteStatusServerModel.fromJson(res.data);
      devFlag.value = serverData.data.devFlag;
      description.value = serverData.data.description;
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
    super.onInit();
  }

  Future<void> updateWebSiteStatus(String des, bool status) async {
    dio.post(
      '${dotenv.env['SERVER']!}/updateStatus',
      queryParameters: {"dbAdmin": true},
      data: {
        "apiKey": dotenv.env['DB_KEY'],
        "mode": "Production",
        "description": des,
        "devFlag": status,
      },
    ).then((res) {
      if (res.statusCode == 200) {
        GetSnack.success(
          message: 'Website dev status is changed successfully!',
          position: SnackPosition.TOP,
        );
        description.value = des;
        devFlag.value = status;
      }
    }).catchError((e) {
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
    });
  }
}
